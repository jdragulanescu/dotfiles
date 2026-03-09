---
name: paul:browser-verify
description: Browser-assisted UAT using cmux browser automation
argument-hint: "[optional: phase or plan number, e.g., '4' or '04-02']"
allowed-tools: [Read, Bash, Glob, Grep, Edit, Write, AskUserQuestion]
---

<objective>
Run browser-assisted user acceptance testing using cmux's built-in browser.

**When to use:** After completing a plan for a web-facing feature. Enhances `/paul:verify` by automating browser interactions — opening pages, clicking elements, filling forms, and capturing snapshots for visual verification.

**Requires:** Running inside cmux terminal (`cmux ping` returns PONG).

**Who tests:** Claude drives the browser and captures results. The USER reviews snapshots and confirms pass/fail for visual/UX checks.
</objective>

<execution_context>
@~/.claude/paul-framework/workflows/verify-work.md
@~/.claude/paul-framework/templates/UAT-ISSUES.md
@~/.claude/skills/cmux/SKILL.md
</execution_context>

<context>
Scope: $ARGUMENTS (optional)
- If provided: Test specific phase or plan (e.g., "4" or "04-02")
- If not provided: Test most recently completed plan

@.paul/STATE.md
@.paul/ROADMAP.md
</context>

<process>

<step name="preflight">
**Verify cmux is available and open browser:**

```bash
cmux ping
```

If cmux is not available:
- Display: "cmux not detected. Use `/paul:verify` for manual testing instead."
- Exit

Open the browser and capture its surface ref for all subsequent commands:
```bash
# Open browser — returns surface ref like "surface:7"
cmux browser open <url>
```

Parse the surface ref from the output (e.g., `surface=surface:7`). Store it — you MUST pass `--surface <ref>` to ALL subsequent browser commands since you are calling from a terminal pane, not from the browser pane itself.
</step>

<step name="identify">
**Determine what to test (same as /paul:verify):**

If $ARGUMENTS provided:
- Parse as phase number (e.g., "4") or plan number (e.g., "04-02")
- Find corresponding SUMMARY.md file(s)

If no arguments:
- Find most recently modified SUMMARY.md

Read the SUMMARY.md to understand what was built.

Key extraction points:
- Acceptance Criteria results
- Files created/modified
- Any URLs, routes, or pages mentioned
- UI components built
</step>

<step name="extract_targets">
**Extract browser-testable targets from SUMMARY.md:**

Parse for:
1. **URLs/routes** — Pages to navigate to (e.g., `/dashboard`, `/settings`)
2. **UI components** — Elements to find and interact with
3. **User flows** — Sequences of actions (click X, fill Y, expect Z)
4. **Visual outcomes** — What should be visible on screen

Categorize each acceptance criterion:
- **browser-testable** — Can verify via DOM inspection, navigation, interaction
- **visual-only** — Needs human eye (design, layout, aesthetics)
- **non-browser** — API, CLI, backend (skip, note for manual verify)
</step>

<step name="open_browser">
**Open browser to the application:**

Determine the base URL from:
1. PLAN.md or SUMMARY.md mentions (e.g., `localhost:3000`)
2. Project config files (package.json scripts, .env, etc.)
3. Ask user if unclear

```bash
# Open browser — parse surface ref from output
cmux browser open http://localhost:3000
# Output: OK surface=surface:7 pane=pane:4 placement=...

# Wait for page load (use the surface ref from above)
cmux browser wait --load-state complete --timeout-ms 10000 --surface surface:7

# Take initial snapshot
cmux browser snapshot --compact --surface surface:7
```

Confirm the app is running and accessible before proceeding.
</step>

<step name="execute_tests">
**For each browser-testable acceptance criterion:**

All commands below require `--surface <ref>` from the preflight step.

1. **Navigate** to the relevant page/route:
   ```bash
   cmux browser navigate <url> --surface surface:7
   cmux browser wait --load-state complete --timeout-ms 5000 --surface surface:7
   ```

2. **Verify element presence** using CSS selectors:
   ```bash
   cmux browser get count "<selector>" --surface surface:7
   cmux browser get text "<selector>" --surface surface:7
   cmux browser is visible "<selector>" --surface surface:7
   ```

3. **Interact** if the test requires user actions:
   ```bash
   cmux browser click "<selector>" --surface surface:7
   cmux browser fill "<selector>" "test input" --surface surface:7
   cmux browser press "Enter" --surface surface:7
   ```

4. **Snapshot after interactions** for evidence:
   ```bash
   cmux browser snapshot --compact --surface surface:7
   ```

   Or use `--snapshot-after` flag on interaction commands:
   ```bash
   cmux browser click "<selector>" --snapshot-after --surface surface:7
   ```

5. **Record result:**
   - PASS: Element found, text matches, behavior correct
   - FAIL: Element missing, wrong text, unexpected behavior
   - PARTIAL: Partially working

6. **For visual-only checks:** Take snapshot and present to user via AskUserQuestion:
   - header: "[AC-N or Feature name]"
   - question: "Here's the page structure:\n[snapshot output]\n\nDoes this look correct?"
   - options: ["Pass", "Fail", "Partial", "Skip"]
</step>

<step name="test_flows">
**For multi-step user flows:**

Execute the full sequence:
1. Navigate to start point
2. Perform each action in order (click, fill, submit)
3. Snapshot at each step
4. Verify expected state after each action
5. Check final state matches acceptance criteria

If a step fails, stop the flow and record which step broke.

Example flow (all commands need `--surface <ref>`):
```bash
cmux browser navigate http://localhost:3000/login --surface surface:7
cmux browser wait --load-state complete --surface surface:7
cmux browser fill "input[name=email]" "test@example.com" --surface surface:7
cmux browser fill "input[name=password]" "password123" --surface surface:7
cmux browser click "button[type=submit]" --surface surface:7
cmux browser wait --url-contains "/dashboard" --timeout-ms 5000 --surface surface:7
cmux browser snapshot --compact --surface surface:7
cmux browser get text "h1" --surface surface:7
```

**Checking errors after interactions:**
```bash
cmux browser errors list --surface surface:7
cmux browser console list --surface surface:7
```
</step>

<step name="collect">
**Collect and categorize issues (same as /paul:verify):**

For each failed/partial test, gather:
- Feature/AC affected
- What went wrong (from browser output or user input)
- Snapshot evidence
- Severity: Blocker / Major / Minor / Cosmetic
</step>

<step name="log">
**Log issues to phase-scoped file:**

If any issues found, create `.paul/phases/XX-name/{phase}-{plan}-UAT.md` using the UAT-ISSUES template.

Include browser evidence in issue descriptions:
```markdown
### UAT-001: [Brief description]

**Discovered:** [date] during browser-assisted acceptance testing
**Phase/Plan:** [phase]-[plan]
**Severity:** [Blocker/Major/Minor/Cosmetic]
**AC:** [Which acceptance criteria]
**Description:** [What failed]
**Expected:** [Expected DOM state / text / behavior]
**Actual:** [Actual DOM state / text / behavior]
**URL:** [Page URL where issue occurred]
```
</step>

<step name="summarize">
**Present test summary:**

```
# Browser Test Results: [Plan Name]

**Tests run:** [N]
**Passed:** [N] (automated) + [N] (visual, user-confirmed)
**Failed:** [N]
**Partial:** [N]
**Skipped:** [N] (non-browser tests)

## Issues Found
[List any issues with severity]

## Non-Browser Tests
[List ACs that need manual or API testing via /paul:verify]

## Verdict
[ALL PASS / MINOR ISSUES / MAJOR ISSUES / BLOCKERS]

## Next Steps
[Based on verdict]
```
</step>

<step name="offer">
**Offer next actions:**

Use AskUserQuestion:
- header: "Next"
- question: "What would you like to do?"
- options (based on results):

If all passed:
- "Continue" — Proceed with confidence
- "Manual verify" — Run /paul:verify for non-browser tests
- "Done" — Finish testing session

If issues found:
- "Plan fixes" — Create plan to address issues
- "Manual verify" — Also run non-browser tests
- "Review issues" — Look at logged issues in detail
</step>

</process>

<success_criteria>
- [ ] cmux availability confirmed
- [ ] Browser surface ref captured and used for all commands
- [ ] Test scope identified from SUMMARY.md
- [ ] Browser opened to application URL
- [ ] Browser-testable ACs verified via DOM interaction
- [ ] Visual checks presented to user for confirmation
- [ ] Non-browser ACs flagged for /paul:verify
- [ ] Any issues logged to phase-scoped UAT file with evidence
- [ ] Summary presented with verdict
- [ ] User knows next steps
</success_criteria>

<anti_patterns>
- Don't forget `--surface <ref>` — commands fail silently or target wrong surface without it
- Don't assume the dev server URL — check config or ask
- Don't skip visual confirmation — snapshots need human review
- Don't mark visual/UX checks as auto-pass — always ask the user
- Don't fix issues during testing — capture for later
- Don't test non-browser functionality here — flag for /paul:verify
</anti_patterns>
