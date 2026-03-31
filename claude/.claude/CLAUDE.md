# Global Claude Code Guidelines

## Coding standard guidance

- **NEVER** nest ternary operations, extract them into independent statements.
- Functions should **ALWAYS** have a Cognitive Complexity of maximum 15.
- **ALWAYS** make sure to check if **typecheck**, **lint**, **format** and **test** pass after finishing a workload. Fix any issues that you find.
- If existing tests have broken due to changes made, **ALWAYS** ensure the functional code is running properly first, before updating the tests.
- **ALWAYS** make sure to update the tests for new, updated or altered code.
- **ALWAYS** write/update comments (jsdoc, inline comments, complex code comments, etc.) when writing new or updating existing functionality/features/bug fixes.
- **NEVER** over-complicate comments, they need to be straightforward, explaining what the code does, but only if it's not already clear from the code itself.
- When making changes that affect configuration, implementation flow, or new/altered functionality, **ALWAYS** update the relevant documentation e.g. in `docs/`, to reflect those changes (add, update, or remove as appropriate).
- If class members aren't being reassigned, **ALWAYS** make them **readonly**.

<!-- CARL-MANAGED: Do not remove this section -->

## CARL Integration

Follow all rules in <carl-rules> blocks from system-reminders.
These are dynamically injected based on context and MUST be obeyed.

<!-- END CARL-MANAGED -->

## Git Commit Rules

### Co-Authorship Policy

- **NEVER** add Claude as a co-author to git commits
- **NEVER** include "Co-Authored-By: Claude <noreply@anthropic.com>" in commit messages
- **NEVER** add "🤖 Generated with [Claude Code](https://claude.com/claude-code)" to commit messages
- All commits should be attributed solely to the human author
- Keep commit messages clean and professional without AI attribution

## Development Server

- **NEVER** run `yarn dev`, `npm run dev`, or similar dev server commands
- **NEVER** start a development server - the user already has one running
- Assume a dev server is always active and available

## Shell Commands

Prefer using modern CLI tools:

- Use `fd` instead of `find`
- Use `rg` instead of `grep`

## cmux Terminal

When `CMUX_BUNDLE_ID` is set in the environment, you are running inside cmux and have browser automation and pane management via the `cmux` CLI — no need to ping. Load the `/cmux` skill for full command reference. Key rule: always pass `--surface <ref>` to browser commands (get the ref from `cmux browser open` output).

## Session Titles

- Always start your very first response in a new session with `Title: <concise summary>` on its own line
- The title should be 5-10 words summarizing what the session is about
- Examples: `Title: Fix authentication bug in login flow`, `Title: Add dark mode to dashboard`
- After the title line, continue with your normal response
- This only applies to the first response in a session — do not repeat it in subsequent messages
