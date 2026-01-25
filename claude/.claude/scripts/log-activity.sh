#!/bin/bash
# ~/.claude/scripts/log-activity.sh
# Activity logging hook for Claude Code / Cursor
# Captures prompts and response summaries to JSONL files
# Data stored in ~/.journal/raw/

set -euo pipefail

JOURNAL_DIR="$HOME/.journal"
RAW_DIR="$JOURNAL_DIR/raw"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
LOG_FILE="$RAW_DIR/$TODAY.jsonl"

# Ensure directories exist
mkdir -p "$RAW_DIR"

# Read hook input from stdin
INPUT=$(cat)

# Detect agent type from environment variables
detect_agent() {
    # Claude Code CLI detection
    if [[ "${CLAUDE_CODE_ENTRYPOINT:-}" == "cli" ]]; then
        echo "claude-code"
    # VS Code / Cursor detection
    elif [[ -n "${VSCODE_PID:-}" ]]; then
        # Check for Cursor-specific indicators
        if [[ -n "${CURSOR_TRACE:-}" ]] || [[ "${TERM_PROGRAM:-}" == "cursor" ]]; then
            echo "cursor"
        else
            echo "vscode"
        fi
    # Remote Claude Code
    elif [[ "${CLAUDE_CODE_REMOTE:-}" == "true" ]]; then
        echo "claude-code-remote"
    else
        echo "unknown"
    fi
}

# Extract project name from cwd
get_project_name() {
    local cwd
    cwd=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
    if [[ -n "$cwd" ]]; then
        basename "$cwd"
    else
        echo "unknown-project"
    fi
}

AGENT=$(detect_agent)
PROJECT=$(get_project_name)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
HOOK_TYPE="${1:-unknown}"

case "$HOOK_TYPE" in
    "prompt")
        # Log the user prompt
        PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

        # Skip empty prompts or slash commands
        if [[ -z "$PROMPT" ]] || [[ "$PROMPT" =~ ^/[a-z] ]]; then
            exit 0
        fi

        # Truncate very long prompts (keep first 2000 chars)
        if [[ ${#PROMPT} -gt 2000 ]]; then
            PROMPT="${PROMPT:0:2000}..."
        fi

        jq -nc \
            --arg ts "$TIMESTAMP" \
            --arg type "prompt" \
            --arg agent "$AGENT" \
            --arg project "$PROJECT" \
            --arg session "$SESSION_ID" \
            --arg prompt "$PROMPT" \
            '{
                timestamp: $ts,
                type: $type,
                agent: $agent,
                project: $project,
                session_id: $session,
                prompt: $prompt
            }' >> "$LOG_FILE"
        ;;

    "stop")
        # Extract summary from transcript
        TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
        SUMMARY=""

        if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
            # Get last assistant message's first text block (truncated to 300 chars)
            # This provides a cost-free "summary" without LLM calls
            SUMMARY=$(tail -100 "$TRANSCRIPT_PATH" 2>/dev/null | \
                jq -rs '
                    [.[] | select(.type == "assistant")] |
                    last |
                    .message.content |
                    if type == "array" then
                        [.[] | select(.type == "text") | .text] | first
                    else
                        .
                    end |
                    if . then .[0:300] else null end
                ' 2>/dev/null || echo "")
        fi

        # Only log if we have a meaningful summary
        if [[ -n "$SUMMARY" ]] && [[ "$SUMMARY" != "null" ]]; then
            jq -nc \
                --arg ts "$TIMESTAMP" \
                --arg type "stop" \
                --arg agent "$AGENT" \
                --arg project "$PROJECT" \
                --arg session "$SESSION_ID" \
                --arg summary "$SUMMARY" \
                '{
                    timestamp: $ts,
                    type: $type,
                    agent: $agent,
                    project: $project,
                    session_id: $session,
                    summary: $summary
                }' >> "$LOG_FILE"
        fi
        ;;
esac

exit 0
