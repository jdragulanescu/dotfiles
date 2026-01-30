---
name: sky:settings
description: Configure SKY workflow toggles and model profile
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

<objective>
Allow users to toggle workflow agents on/off and select model profile via interactive settings.

Updates `.planning/config.json` with workflow preferences and model profile selection.
</objective>

<process>

## 1. Validate Environment

```bash
ls .planning/config.json 2>/dev/null
```

**If not found:** Error - run `/sky:new-project` first.

## 2. Read Current Config

```bash
cat .planning/config.json
```

Parse current values (default to `true` if not present):
- `workflow.research` — spawn researcher during plan-phase
- `workflow.plan_check` — spawn plan checker during plan-phase
- `workflow.verifier` — spawn verifier during execute-phase
- `model_profile` — which model each agent uses (default: `balanced`)

## 3. Present Settings

Use AskUserQuestion with current values shown:

```
AskUserQuestion([
  {
    question: "Which model profile for agents?",
    header: "Model",
    multiSelect: false,
    options: [
      { label: "Quality", description: "Opus everywhere except verification (highest cost)" },
      { label: "Balanced (Recommended)", description: "Opus for planning, Sonnet for execution/verification" },
      { label: "Budget", description: "Sonnet for writing, Haiku for research/verification (lowest cost)" }
    ]
  },
  {
    question: "Spawn Plan Researcher? (researches domain before planning)",
    header: "Research",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Research phase goals before planning" },
      { label: "No", description: "Skip research, plan directly" }
    ]
  },
  {
    question: "Spawn Plan Checker? (verifies plans before execution)",
    header: "Plan Check",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Verify plans meet phase goals" },
      { label: "No", description: "Skip plan verification" }
    ]
  },
  {
    question: "Spawn Execution Verifier? (verifies phase completion)",
    header: "Verifier",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Verify must-haves after execution" },
      { label: "No", description: "Skip post-execution verification" }
    ]
  }
])
```

**Pre-select based on current config values.**

## 3.5 Quality Settings

Present quality settings:

```
AskUserQuestion([
  {
    question: "Block commits with TypeScript errors?",
    header: "Typecheck",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Run typecheck before commits" },
      { label: "No", description: "Skip typecheck" }
    ]
  },
  {
    question: "Block commits with lint errors?",
    header: "Lint",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Run lint before commits" },
      { label: "No", description: "Skip lint" }
    ]
  },
  {
    question: "Spawn code-reviewer after coding tasks?",
    header: "Review",
    multiSelect: false,
    options: [
      { label: "Yes", description: "Security analysis after code changes" },
      { label: "No", description: "Skip automatic review" }
    ]
  },
  {
    question: "Spawn code-simplifier after coding tasks?",
    header: "Simplify",
    multiSelect: false,
    options: [
      { label: "No", description: "Keep code as written" },
      { label: "Yes", description: "Cleanup after code changes" }
    ]
  }
])
```

**Pre-select based on current config values (default: typecheck=yes, lint=yes, review=yes, simplify=no).**

## 4. Update Config

Merge new settings into existing config.json:

```json
{
  ...existing_config,
  "model_profile": "quality" | "balanced" | "budget",
  "workflow": {
    "research": true/false,
    "plan_check": true/false,
    "verifier": true/false
  },
  "quality": {
    "typecheck_before_commit": true/false,
    "lint_before_commit": true/false,
    "typecheck_command": "pnpm typecheck",
    "lint_command": "pnpm lint",
    "code_review_after_coding": true/false,
    "code_simplify_after_coding": true/false
  }
}
```

Write updated config to `.planning/config.json`.

## 5. Confirm Changes

Display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SKY ► SETTINGS UPDATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Workflow Settings

| Setting              | Value |
|----------------------|-------|
| Model Profile        | {quality/balanced/budget} |
| Plan Researcher      | {On/Off} |
| Plan Checker         | {On/Off} |
| Execution Verifier   | {On/Off} |

## Quality Settings

| Setting              | Value |
|----------------------|-------|
| Typecheck            | {On/Off} |
| Lint                 | {On/Off} |
| Code Reviewer        | {On/Off} |
| Code Simplifier      | {On/Off} |

These settings apply to future /sky:plan-phase and /sky:execute-phase runs.

Quick commands:
- /sky:set-profile <profile> — switch model profile
- /sky:plan-phase --research — force research
- /sky:plan-phase --skip-research — skip research
- /sky:plan-phase --skip-verify — skip plan check
```

</process>

<success_criteria>
- [ ] Current config read
- [ ] User presented with 4 workflow settings (profile + 3 toggles)
- [ ] User presented with 4 quality settings (typecheck, lint, review, simplify)
- [ ] Config updated with model_profile, workflow, and quality sections
- [ ] Changes confirmed to user
</success_criteria>
