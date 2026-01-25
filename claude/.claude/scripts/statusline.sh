#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Colors
RESET="\033[0m"
DIM="\033[2m"
MAGENTA="\033[35m"
YELLOW="\033[33m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
WHITE="\033[37m"
BLUE="\033[34m"

# Extract values using jq
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
MODEL_ID=$(echo "$input" | jq -r '.model.id // ""')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // ""')
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d'.' -f1)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_CREATION=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Calculate total tokens used
if [[ "$INPUT_TOKENS" != "null" && "$INPUT_TOKENS" != "0" ]]; then
    TOTAL_TOKENS=$((INPUT_TOKENS + CACHE_READ + CACHE_CREATION))
else
    TOTAL_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
fi

# Calculate cache efficiency
if [[ $TOTAL_TOKENS -gt 0 && $CACHE_READ -gt 0 ]]; then
    CACHE_PERCENT=$((CACHE_READ * 100 / TOTAL_TOKENS))
else
    CACHE_PERCENT=0
fi

# Format tokens as Xk
format_tokens() {
    local tokens=$1
    if [[ $tokens -ge 1000 ]]; then
        echo "$((tokens / 1000))k"
    else
        echo "$tokens"
    fi
}

# Format duration
format_duration() {
    local ms=$1
    local seconds=$((ms / 1000))
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))

    if [[ $hours -gt 0 ]]; then
        local remaining_mins=$((minutes % 60))
        echo "${hours}h${remaining_mins}m"
    elif [[ $minutes -gt 0 ]]; then
        echo "${minutes}m"
    else
        echo "${seconds}s"
    fi
}

TOKENS_DISPLAY=$(format_tokens $TOTAL_TOKENS)
CONTEXT_DISPLAY=$(format_tokens $CONTEXT_SIZE)
DURATION_DISPLAY=$(format_duration $DURATION_MS)

# Get model version from ID
if [[ "$MODEL_ID" == *"opus-4-5"* ]]; then
    MODEL_VERSION="Opus 4.5"
elif [[ "$MODEL_ID" == *"opus-4"* ]]; then
    MODEL_VERSION="Opus 4"
elif [[ "$MODEL_ID" == *"sonnet-4"* ]]; then
    MODEL_VERSION="Sonnet 4"
elif [[ "$MODEL_ID" == *"sonnet-3-5"* ]]; then
    MODEL_VERSION="Sonnet 3.5"
elif [[ "$MODEL_ID" == *"haiku"* ]]; then
    MODEL_VERSION="Haiku"
else
    MODEL_VERSION="$MODEL"
fi

# Build progress bar (10 chars wide)
BAR_WIDTH=10
FILLED=$((PERCENT_USED * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR="["
for ((i=0; i<FILLED; i++)); do BAR+="="; done
for ((i=0; i<EMPTY; i++)); do BAR+=" "; done
BAR+="]"

# Get directory name
if [[ "$CURRENT_DIR" == "$PROJECT_DIR" ]]; then
    DIR_DISPLAY=$(basename "$CURRENT_DIR")
elif [[ "$CURRENT_DIR" == "$PROJECT_DIR"/* ]]; then
    DIR_DISPLAY=$(basename "$PROJECT_DIR")
else
    DIR_DISPLAY=$(basename "$CURRENT_DIR")
fi

# Git branch and dirty status
BRANCH=""
DIRTY=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if ! git -C "$CURRENT_DIR" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$CURRENT_DIR" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        DIRTY="*"
    fi
fi

# Format cost
if (( $(echo "$COST > 0" | bc -l 2>/dev/null || echo 0) )); then
    COST_DISPLAY=$(printf "\$%.2f" "$COST")
else
    COST_DISPLAY="\$0.00"
fi

# Get total input/output tokens for session
TOTAL_INPUT=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUTPUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
INPUT_DISPLAY=$(format_tokens $TOTAL_INPUT)
OUTPUT_DISPLAY=$(format_tokens $TOTAL_OUTPUT)

# === LINE 1: Model, context, tokens, cost ===
printf "${MAGENTA}${MODEL_VERSION}${RESET} "
printf "${DIM}${BAR}${RESET} "
printf "${YELLOW}${PERCENT_USED}%%${RESET}"
printf " ${DIM}|${RESET} "
printf "${WHITE}${TOKENS_DISPLAY}/${CONTEXT_DISPLAY}${RESET}"
printf " ${DIM}|${RESET} "
printf "${DIM}↓${RESET}${CYAN}${INPUT_DISPLAY}${RESET} ${DIM}↑${RESET}${MAGENTA}${OUTPUT_DISPLAY}${RESET}"
printf " ${DIM}|${RESET} "
printf "${DIM}cost${RESET} ${YELLOW}${COST_DISPLAY}${RESET}"

# === EMPTY LINE ===
printf "\n \n"

# === LINE 2: Stats + location ===
printf "${DIM}lines${RESET} ${GREEN}+${LINES_ADDED}${RESET}${DIM}/${RESET}${RED}-${LINES_REMOVED}${RESET}"

if [[ $CACHE_PERCENT -gt 0 ]]; then
    printf " ${DIM}|${RESET} "
    printf "${DIM}cache${RESET} ${CYAN}${CACHE_PERCENT}%%${RESET}"
fi

printf " ${DIM}|${RESET} "
printf "${DIM}time${RESET} ${BLUE}${DURATION_DISPLAY}${RESET}"
printf " ${DIM}|${RESET} "
printf "${GREEN}${DIR_DISPLAY}${RESET}"

if [[ -n "$BRANCH" ]]; then
    printf " ${DIM}on${RESET} "
    printf "${CYAN}${BRANCH}${RESET}"
    if [[ -n "$DIRTY" ]]; then
        printf "${RED}${DIRTY}${RESET}"
    fi
fi

echo ""
