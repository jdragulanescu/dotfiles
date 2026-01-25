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
