---
description: "Generate a journal summary of AI coding activities"
model: haiku
allowed-tools:
  [
    "Bash(ls:*)",
    "Bash(find:*)",
    "Bash(stat:*)",
    "Bash(cat:*)",
    "Bash(head:*)",
    "Bash(tail:*)",
    "Bash(mkdir:*)",
    "Bash(date:*)",
    "Bash(sort:*)",
    "Bash(grep:*)",
    "Bash(wc:*)",
    "Bash(cut:*)",
    "Bash(jq:*)",
    "Read",
    "Write",
  ]
---

# Claude Command: AI Journal

Generate a daily journal summary from the activity log in `~/.journal/raw/`.

## Usage

```
/ai-journal              # Summarize all days since last summary (up to yesterday)
/ai-journal 2026-01-22   # Specific date (YYYY-MM-DD)
/ai-journal --week       # Past 7 days summary
```

## Process

1. **Determine target date(s)**:
   - If `$ARGUMENTS` contains a date (YYYY-MM-DD format), use that specific date
   - If `$ARGUMENTS` contains `--week`, process last 7 days
   - **Default behavior (no arguments)**: Find all missing days since the last summary

     a. Find the most recent summary file (summaries are in ~/.journal/summaries/YYYY/MM/):
     ```bash
     find ~/.journal/summaries -path "*/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*.md" -type f 2>/dev/null | sort | tail -1
     ```

     b. Extract the date from the filename (YYYY-MM-DD.md)

     c. Calculate all dates from (last_summary_date + 1 day) through yesterday

     d. For each date in range, check if raw log exists (`~/.journal/raw/YYYY-MM-DD.jsonl`)

     e. Process each date that has a raw log file but no summary yet

     f. If no existing summaries found, default to just yesterday

2. **Check for activity logs**:
   ```bash
   # Check if raw log exists for target date
   ls -la ~/.journal/raw/YYYY-MM-DD.jsonl
   ```

3. **Parse the JSONL log file**:
   ```bash
   # Read all entries for the date
   cat ~/.journal/raw/YYYY-MM-DD.jsonl
   ```

4. **Analyze entries**:
   - Entries with `"type":"prompt"` contain user prompts
   - Entries with `"type":"stop"` contain response summaries
   - Match prompts and stops by `session_id`
   - Group by `project` field
   - Note `agent` field (claude-code, cursor, vscode, unknown)

5. **Generate summary markdown** with this structure:

```markdown
## Daily AI Journal - [Full Date]

### Agent Usage
- Claude Code: X sessions
- Cursor: Y sessions

---

### Project: **[Project Name]**

**[HH:MM] Session** (Agent: claude-code)
- [What user asked/worked on]
- [Outcome from summary]

---

**Daily Vibe:** [One-line summary of the day's productivity/mood based on activities]
```

6. **Save summary**:
   ```bash
   # IMPORTANT: Use YYYY/MM format (e.g., 2026/01), NOT YYYY-MM
   mkdir -p ~/.journal/summaries/YYYY/MM/
   ```
   Write to `~/.journal/summaries/YYYY/MM/YYYY-MM-DD.md`

   **Path format examples:**
   - For January 24, 2026: `~/.journal/summaries/2026/01/2026-01-24.md`
   - For December 5, 2025: `~/.journal/summaries/2025/12/2025-12-05.md`
   - WRONG: `~/.journal/summaries/2026-01/...` (never use dashes in folder names)

## Example Raw Log Entry

```json
{"timestamp":"2026-01-24T10:30:00Z","type":"prompt","agent":"claude-code","project":"my-app","session_id":"abc123","prompt":"Fix the login bug"}
{"timestamp":"2026-01-24T10:35:00Z","type":"stop","agent":"claude-code","project":"my-app","session_id":"abc123","summary":"Fixed the login bug by updating the auth middleware..."}
```

## Guidelines

- Read from `~/.journal/raw/YYYY-MM-DD.jsonl`
- Group activities by project (from `project` field)
- Show agent type for each session (claude-code, cursor, etc.)
- Extract time from ISO timestamp for display
- Keep summaries concise - this is a quick daily recap
- If no log file exists for the date, inform the user
- For `--week` mode, create a combined weekly summary

## Example Output

```markdown
## Daily AI Journal - January 24, 2026

### Agent Usage
- Claude Code: 5 sessions
- Cursor: 2 sessions

---

### Project: **bazi-horoscope**

**10:30** (claude-code)
- Fixed login authentication bug
- *"Fixed the login bug by updating the auth middleware to properly validate JWT tokens"*

**14:15** (cursor)
- Quick CSS fixes for mobile layout

---

### Project: **dotfiles**

**16:00** (claude-code)
- Updated shell aliases

---

**Daily Vibe:** Productive debugging day with a successful deploy.
```
