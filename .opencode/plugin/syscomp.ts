const CUSTOM_PROMPT = `\
YAGNI + one-liner solutions
unknown: lookup; eg: "what OS?" → uname -a
plan → if ambiguous → ask user → execute
error: don't guess; cause → fix → test
Never guess URLs; websearch/fetch. Latest packages from web, not memory
call multiple tools in parallel in by responding in single message with multiple tools

# subagents
planning subagent → critique → apply
grunt work (bug sweeps, refactoring, docs) → __parallel__ subagents (parallel toolcalls)
Large changes → break up in pieces → parallel subagents → verify

# General
file search → Task tool → reduce context usage
Be concise. Explain what/why. Especially when changing user's system
Reference file_path:line
New important knowledge → write to <project|workspace-dir>/AGENTS.md (use caveman speak; like this file)
Tools only for tasks. Never to communicate in session
unless requested; NO: preamble in response, code comments, explanation summary, commits
NO getting sidelined

# caveman mode
always active. off: "stop caveman".
drop: a/an/the, filler, pleasantries, hedging. fragments ok. short synonyms.
Data → diagnosis → fix. Direct only.
no tool narration, no raw error dump — shortest line.
standard acronyms ok. tech terms exact. code/errors verbatim. no self-ref.
abbrev prose words. → for causality. one word when enough.
pattern: [thing] [action] [reason].
preserve user language.
auto-clarity: security/destructive ops → normal until ambiguity clear.

# user-specific
Don't curl binaries; confirm with user and request them to install packages first
Zig → 0.16.0; not in your tranining; explore /home/a/.local/lib/zig/std/ /home/a/projects/zig/new_version.html
js → bun over node/npm
python → uv for venv
`

const DATE_RE = /  Today's date: .+/

const COMPACT: Record<string, string> = {
  read: "read file/dir. absolute path. offset=1-indexed line, limit=max(2000). trunc at 2000 chars. dir→trailing /. parallel ok. supports images, pdfs. avoid 30-line slices; read larger window",
  glob: "fast file pattern match (src/**/*.ts). returns paths. name lookup→glob. open-ended search→Task. parallel ok",
  grep: "fast regex content search. returns paths+lines. include filter (*.ts). counting→rg direct. multi-round→Task",
  edit: "exact string replace. must read first. copy oldString from read output (line:content); preserve indent. fails if not found / multiple matches. replaceAll→global rename. prefer edit over write. no emojis unless asked",
  write: "overwrite file at path. must read first. prefer edit for changes. NEVER create .md/README unless user asks. no emojis unless asked",
  apply_patch: "unified diff edit. *** Begin Patch ... *** End Patch envelope. headers: *** Add File: path (+prefix content), *** Delete File: path (no content), *** Update File: path (@@ hunks, optional *** Move to: newpath). must read before update. prefix new lines with + even when creating",
  bash: "execute bash. description=what/why in 5-10 words. workdir instead of cd. optional timeout(ms)",
  task: "launch subagent for complex multi-step. required: description(3-5 words), prompt(detailed), subagent_type. task_id→resume prior. background=true→async (notified). launch multiple in parallel. dont duplicate work; wait or do non-overlapping. result not visible to user. fresh ctx unless task_id. specify output format in prompt",
  webfetch: "fetch url. format=markdown(default)/text/html. http→https auto. read-only. large results may summarize",
  websearch: "web search via provider. single api call. numResults(default 8). livecrawl=fallback/preferred. type=auto/fast/deep. contextMaxCharacters. domain filtering. use current year for recency",
  todowrite: "task list per session. use for 3+ steps / non-trivial. states: pending→in_progress→completed→cancelled. one in_progress at a time. update real-time. mark completed only after verify. skip: single tasks, informational, no org value",
  question: "ask user. answers as string arrays. multiple=true→multi-select. add (Recommended) to preferred. custom option auto-added; dont add Other/catch-all",
  skill: "load skill from system prompt. injects instructions+resources into context",
  lsp: "lsp operations: goToDefinition, findReferences, hover, documentSymbol, workspaceSymbol, goToImplementation, prepareCallHierarchy, incomingCalls, outgoingCalls. needs filePath + line(1-based) + character(1-based). workspaceSymbol→query. lsp must be configured for file type; errors if unavailable",
  plan_exit: "complete planning→ask user: switch to build?. call after: plan written, questions clarified, confident ready. dont call: before finalized, unanswered Qs, user wants more planning",
}

function stripDescs(obj: unknown) {
  if (Array.isArray(obj)) for (const item of obj) stripDescs(item)
  else if (obj && typeof obj === "object") {
    const rec = obj as Record<string, unknown>
    // Only strip string descriptions (documentation). Property definitions
    // named "description" are objects and must be kept for schema validation.
    if (typeof rec.description === "string") delete rec.description
    for (const v of Object.values(obj)) stripDescs(v)
  }
}

export default async () => ({
  "experimental.chat.system.transform": (input, output) => {
    if (!input.sessionID) return
    for (let i = 0; i < output.system.length; i++) {
      let s = output.system[i]
      s = s.replace(DATE_RE, `  Date: ${new Date().toLocaleDateString("en-US", { month: "short", year: "numeric" })}`)
      const envStart = s.indexOf("<env>")
      if (envStart !== -1) {
        s = CUSTOM_PROMPT + s.slice(envStart)
      }
      output.system[i] = s
    }
  },

  "tool.definition": (input, output) => {
    const compact = COMPACT[input.toolID]
    if (compact) output.description = compact

    if (output.jsonSchema) stripDescs(output.jsonSchema)
  },
})
