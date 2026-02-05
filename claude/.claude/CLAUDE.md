# Global Claude Code Guidelines

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

## Session Titles

- Always start your very first response in a new session with `Title: <concise summary>` on its own line
- The title should be 5-10 words summarizing what the session is about
- Examples: `Title: Fix authentication bug in login flow`, `Title: Add dark mode to dashboard`
- After the title line, continue with your normal response
- This only applies to the first response in a session — do not repeat it in subsequent messages
