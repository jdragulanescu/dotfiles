#!/bin/bash

# Check if we've already run the journal today
TODAY=$(date +%Y-%m-%d)
LAST_RUN_FILE="$HOME/.claude/.last-journal-run"

if [ -f "$LAST_RUN_FILE" ]; then
  LAST_RUN=$(cat "$LAST_RUN_FILE")
  if [ "$LAST_RUN" = "$TODAY" ]; then
    # Already ran today, exit silently
    exit 0
  fi
fi

# First session of the day - mark it and output instruction
echo "$TODAY" > "$LAST_RUN_FILE"
echo "First Claude Code session of the day. Please run /ai-journal to generate today's journal."
exit 0
