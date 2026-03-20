# Global Codex Guidelines

## Git Commit Rules

### Co-Authorship Policy

- **NEVER** add Codex as a co-author to git commits
- **NEVER** include "Co-Authored-By" lines referencing AI in commit messages
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
