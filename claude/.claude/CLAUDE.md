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

## Shell Commands — CRITICAL

**The user has `find` and `grep` aliased to `fd` and `rg`. These have COMPLETELY DIFFERENT syntax. Using standard find/grep syntax WILL FAIL.**

### MANDATORY: Use fd instead of find

**NEVER use find syntax. It will break.**

```bash
# WRONG - will fail (find syntax doesn't work with fd)
find . -name "*.js"
find . -type f -name "config*"
find src -name "*.ts" -exec cat {} \;

# CORRECT - use fd syntax
fd ".js$"
fd "config" --type f
fd ".ts$" src --exec cat {}
```

**fd syntax quick reference:**

- `fd pattern` — search for pattern in filenames
- `fd pattern path` — search in specific path
- `fd -e js` — filter by extension
- `fd -t f` — files only (`-t d` for directories)
- `fd -H` — include hidden files
- `fd -I` — include gitignored files
- `fd pattern --exec cmd {}` — execute command on results

### MANDATORY: Use rg instead of grep

**NEVER use grep syntax. It will break.**

```bash
# WRONG - will fail (grep syntax doesn't work with rg)
grep -r "pattern" .
grep -rn "TODO" --include="*.js"
grep -E "regex" file.txt

# CORRECT - use rg syntax
rg "pattern"
rg "TODO" -g "*.js"
rg "regex" file.txt
```

**rg syntax quick reference:**

- `rg pattern` — search recursively (default)
- `rg pattern path` — search in specific path
- `rg -g "*.js" pattern` — filter by glob
- `rg -t js pattern` — filter by type
- `rg -i pattern` — case insensitive
- `rg -l pattern` — list files only
- `rg -C 3 pattern` — show 3 lines context

### MANDATORY: Use builtin cd for scripting

**`cd` is aliased to `z` (zoxide). Zoxide is for interactive use only and will fail in scripts or command chains.**

```bash
# WRONG - will fail (zoxide not meant for scripting)
cd /some/path && command
(cd /some/path && command)

# CORRECT - use builtin cd
builtin cd /some/path && command
(builtin cd /some/path && command)

# BEST - avoid cd entirely when possible
fd -e md . /some/path | xargs ...
rg "pattern" /some/path
```

**When to use `builtin cd`:**

- Command chaining: `builtin cd /path && cmd`
- Subshells: `(builtin cd /path && cmd)`
- Any non-interactive directory change

**When `z` is fine:**

- Interactive terminal use only

### Other Modern Tools

| Instead of | Use   | Notes                              |
| ---------- | ----- | ---------------------------------- |
| `ls`       | `eza` | aliased, or use `lsa`, `ll`        |
| `cat`      | `bat` | syntax highlighting                |
| `cd`       | `z`   | interactive only, see section above |
