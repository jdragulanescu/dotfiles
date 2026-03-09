---
name: cmux
description: Interact with cmux terminal multiplexer — browser automation, pane management, and workspace orchestration. Auto-activates when user asks to test a web UI, open a browser, split panes, or manage terminal workspaces in cmux.
---

# cmux Integration

cmux is a terminal multiplexer with a built-in browser engine. When running inside cmux, Claude can open browser panes, navigate web pages, interact with DOM elements, capture snapshots, manage panes, and orchestrate multi-service environments.

**Detection:** `cmux ping` returns `PONG` when available.

## Critical Rule: --surface flag

When calling `cmux browser` commands from a terminal pane (always the case for Claude agents), you MUST pass `--surface <ref>` to target the browser pane. Without it, commands fail or target the wrong surface.

Get the surface ref from `cmux browser open` output:
```bash
cmux browser open http://localhost:3000
# Output: OK surface=surface:7 pane=pane:4 placement=...
# Use surface:7 for all subsequent browser commands
```

## Browser Commands

### Navigation

```bash
cmux browser open <url>                              # Open browser pane (returns surface ref)
cmux browser navigate <url> --surface <ref>          # Navigate to URL
cmux browser back --surface <ref>                    # Go back
cmux browser forward --surface <ref>                 # Go forward
cmux browser reload --surface <ref>                  # Reload page
cmux browser get url --surface <ref>                 # Get current URL
```

### Waiting

```bash
cmux browser wait --load-state complete --timeout-ms 5000 --surface <ref>
cmux browser wait --selector "<css>" --timeout-ms 5000 --surface <ref>
cmux browser wait --text "Welcome" --timeout-ms 5000 --surface <ref>
cmux browser wait --url-contains "/dashboard" --timeout-ms 5000 --surface <ref>
cmux browser wait --function "() => window.loaded" --surface <ref>
```

### Reading Content

```bash
cmux browser snapshot --compact --surface <ref>                    # DOM tree (most useful)
cmux browser snapshot --selector "main" --compact --surface <ref>  # Scoped snapshot
cmux browser get text "<selector>" --surface <ref>                 # Element text
cmux browser get count "<selector>" --surface <ref>                # Element count
cmux browser get title --surface <ref>                             # Page title
cmux browser get html "<selector>" --surface <ref>                 # Element HTML
cmux browser get value "<selector>" --surface <ref>                # Input value
cmux browser get attr "<selector>" "<attr>" --surface <ref>        # Element attribute
cmux browser is visible "<selector>" --surface <ref>               # Returns 1/0
cmux browser is enabled "<selector>" --surface <ref>
cmux browser is checked "<selector>" --surface <ref>
```

### Interacting

```bash
cmux browser click "<selector>" --surface <ref>
cmux browser dblclick "<selector>" --surface <ref>
cmux browser hover "<selector>" --surface <ref>
cmux browser fill "<selector>" "text" --surface <ref>      # Clears then types
cmux browser type "<selector>" "text" --surface <ref>      # Appends to existing
cmux browser fill "<selector>" "" --surface <ref>          # Clear input
cmux browser press "Enter" --surface <ref>
cmux browser select "<selector>" "value" --surface <ref>   # Dropdown
cmux browser check "<selector>" --surface <ref>
cmux browser uncheck "<selector>" --surface <ref>
cmux browser scroll --dy 500 --surface <ref>
cmux browser scroll-into-view "<selector>" --surface <ref>
```

All interaction commands support `--snapshot-after` to return a DOM snapshot after the action:
```bash
cmux browser click "button" --snapshot-after --surface <ref>
```

### Finding Elements

```bash
cmux browser find role "button" --surface <ref>
cmux browser find text "Submit" --surface <ref>
cmux browser find label "Email" --surface <ref>
cmux browser find placeholder "Enter name" --surface <ref>
cmux browser find testid "login-btn" --surface <ref>
```

### Debugging

```bash
cmux browser console list --surface <ref>                          # Console messages
cmux browser errors list --surface <ref>                           # JS errors
cmux browser eval "document.title" --surface <ref>                 # Run JS
cmux browser highlight "<selector>" --surface <ref>                # Visual highlight
```

## Pane & Workspace Commands

```bash
cmux list-panes                                          # List panes in workspace
cmux new-split right --command "npm run api"             # Split right with command
cmux new-split down --command "npm test"                 # Split below with command
cmux list-workspaces                                     # List all workspaces
cmux new-workspace --command "htop"                      # New workspace with command
cmux send-text "npm run build" --surface <ref>           # Send text to a surface
```

## Common Patterns

### Verify a page loads correctly
```bash
cmux browser open http://localhost:3000
# parse surface ref from output
cmux browser wait --load-state complete --timeout-ms 10000 --surface <ref>
cmux browser snapshot --compact --surface <ref>
cmux browser get title --surface <ref>
```

### Test a form submission
```bash
cmux browser navigate http://localhost:3000/contact --surface <ref>
cmux browser wait --load-state complete --surface <ref>
cmux browser fill "input[name=name]" "Jane Doe" --surface <ref>
cmux browser fill "input[name=email]" "jane@example.com" --surface <ref>
cmux browser click "button[type=submit]" --snapshot-after --surface <ref>
cmux browser wait --text "Thank you" --timeout-ms 5000 --surface <ref>
```

### Check for errors
```bash
cmux browser errors list --surface <ref>
cmux browser console list --surface <ref>
```

### Run services in parallel panes
```bash
cmux new-split right --command "npm run api"
cmux new-split down --command "npm run worker"
# main pane still available for Claude
```
