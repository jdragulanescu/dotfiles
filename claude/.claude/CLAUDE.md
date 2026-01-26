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

## Shell Command Aliases

The user has modern CLI tool replacements configured. When running Bash commands, use these instead of standard tools:

### Standard Command Overrides
| Standard | Replacement | Notes |
|----------|-------------|-------|
| `find` | `fd` | Modern find alternative with simpler syntax |
| `grep` | `rg` | ripgrep - faster grep with better defaults |
| `ls` | `eza` | Modern ls with icons and git integration |
| `cd` | `z` | zoxide - smarter cd with frecency tracking |

### Usage Examples
- Use `fd pattern` instead of `find . -name "pattern"`
- Use `rg pattern` instead of `grep -r pattern`
- Use `eza -la` instead of `ls -la`

### Additional Modern Tools Available
- `bat` - cat replacement with syntax highlighting
- `fzf` - fuzzy finder for interactive selection
