local augroup = vim.api.nvim_create_augroup('user-java-jdtls', { clear = true })

local function mason_path(...)
  return table.concat({ vim.fn.stdpath('data'), 'mason', ... }, '/')
end

local function glob(pattern)
  return vim.fn.glob(pattern, true, true)
end

local function java_bundles()
  local bundles = {}

  vim.list_extend(bundles, glob(mason_path('packages', 'java-debug-adapter', 'extension', 'server', 'com.microsoft.java.debug.plugin-*.jar')))
  vim.list_extend(bundles, glob(mason_path('packages', 'java-test', 'extension', 'server', 'com.microsoft.java.test.plugin-*.jar')))

  return bundles
end

local function executable(path)
  return vim.fn.executable(path) == 1
end

local function first_jdk(candidates)
  for _, path in ipairs(candidates) do
    if executable(path .. '/bin/java') and executable(path .. '/bin/javac') then
      return path
    end
  end
end

local function java_runtimes()
  local runtimes = {}

  if executable('/usr/lib/jvm/java-21-openjdk/bin/javac') then
    table.insert(runtimes, {
      name = 'JavaSE-21',
      path = '/usr/lib/jvm/java-21-openjdk',
      default = true,
    })
  end

  return runtimes
end

local function on_attach(_, bufnr)
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then
    return
  end

  local function nmap(keys, fn, desc)
    vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'Java: ' .. desc })
  end

  local function vmap(keys, fn, desc)
    vim.keymap.set('v', keys, fn, { buffer = bufnr, desc = 'Java: ' .. desc })
  end

  nmap('<leader>jo', jdtls.organize_imports, 'organize imports')
  nmap('<leader>jv', jdtls.extract_variable, 'extract variable')
  nmap('<leader>jc', jdtls.extract_constant, 'extract constant')
  vmap('<leader>jv', function()
    jdtls.extract_variable(true)
  end, 'extract variable')
  vmap('<leader>jc', function()
    jdtls.extract_constant(true)
  end, 'extract constant')
  vmap('<leader>jm', function()
    jdtls.extract_method(true)
  end, 'extract method')

  nmap('<leader>ju', jdtls.update_project_config, 'update project config')

  if pcall(require, 'dap') then
    jdtls.setup_dap({ hotcodereplace = 'auto' })
    nmap('<leader>jt', jdtls.test_nearest_method, 'test nearest method')
    nmap('<leader>jT', jdtls.test_class, 'test class')
  end
end

local function start_jdtls()
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then
    return
  end

  local root_markers = {
    '.git',
    'mvnw',
    'gradlew',
    'pom.xml',
    'build.gradle',
    'build.gradle.kts',
    'settings.gradle',
    'settings.gradle.kts',
  }
  local root_dir = jdtls.setup.find_root(root_markers) or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(root_dir:gsub('/$', ''), ':t'):gsub('[^%w_.-]', '_')
  local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspaces/' .. project_name

  local jdtls_cmd = mason_path('bin', 'jdtls')
  if vim.fn.executable(jdtls_cmd) ~= 1 then
    jdtls_cmd = vim.fn.exepath('jdtls')
  end
  if jdtls_cmd == '' then
    vim.notify('jdtls is not installed. Run :MasonInstall jdtls', vim.log.levels.WARN)
    return
  end

  local extended_capabilities = jdtls.extendedClientCapabilities
  extended_capabilities.resolveAdditionalTextEditsSupport = true
  extended_capabilities.progressReportProvider = true

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  if cmp_ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  local jdtls_jdk = first_jdk({
    vim.env.JDTLS_JAVA_HOME or '',
    '/usr/lib/jvm/java-21-openjdk',
  })

  local cmd = { jdtls_cmd, '-data', workspace_dir }
  if jdtls_jdk then
    cmd = {
      jdtls_cmd,
      '--java-executable',
      jdtls_jdk .. '/bin/java',
      '-data',
      workspace_dir,
    }
  end

  jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        references = { includeDecompiledSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        inlayHints = {
          parameterNames = { enabled = 'all' },
        },
        configuration = {
          runtimes = java_runtimes(),
          updateBuildConfiguration = 'interactive',
        },
        import = {
          gradle = {
            enabled = true,
            wrapper = { enabled = true },
          },
          maven = {
            enabled = true,
          },
        },
        saveActions = {
          organizeImports = false,
        },
        completion = {
          enabled = true,
          chain = { enabled = true },
          guessMethodArguments = true,
          maxResults = 100,
          postfix = { enabled = true },
          importOrder = {
            'java',
            'javax',
            'jakarta',
            'org',
            'com',
            '',
          },
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.jupiter.api.Assumptions.*',
            'org.mockito.Mockito.*',
            'org.assertj.core.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.List',
            'jdk.*',
            'org.gnome.*',
            'org.gtk.*',
            'org.w3c.dom.css.*',
            'org.w3c.dom.html.*',
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          useBlocks = true,
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
          },
          hashCodeEquals = {
            useJava7Objects = true,
          },
        },
      },
    },
    init_options = {
      bundles = java_bundles(),
      extendedClientCapabilities = extended_capabilities,
    },
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'java',
  callback = start_jdtls,
})
