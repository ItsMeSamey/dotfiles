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
New important knowledge → write to <project|workspace-dir>/AGENTS.md (use minified speak; like this file)
Tools only for tasks. Never to communicate in session
unless requested; NO: preamble in response, code comments, explanation summary, commits
NO getting sidelined

# user-specific
Don't curl binaries; confirm with user and request them to install packages first
Zig → 0.16.0; not in your tranining; explore /home/a/.local/lib/zig/std/ /home/a/projects/zig/new_version.html
js → bun over node/npm
python → uv for venv
`

const DATE_RE = /  Today's date: .+/

export default async () => ({
  "experimental.chat.system.transform": (input, output) => {
    if (!input.sessionID) return
    for (let i = 0; i < output.system.length; i++) {
      let s = output.system[i]
      s = s.replace(DATE_RE, `  Date: ${new Date().toLocaleDateString("en-US", { month: "short", year: "numeric" })}`)
      const envEnd = s.indexOf("</env>")
      if (envEnd !== -1) {
        s = CUSTOM_PROMPT + s.slice(envEnd)
      }
      output.system[i] = s
    }
  },
})
