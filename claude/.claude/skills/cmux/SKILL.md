---
name: cmux
description: Interact with cmux terminal multiplexer — browser automation, pane management, and workspace orchestration. Auto-activates when user asks to test a web UI, open a browser, split panes, or manage terminal workspaces in cmux.
---

# cmux Integration

cmux is a terminal multiplexer with a built-in browser engine. When running inside cmux, Claude can open browser panes, navigate web pages, interact with DOM elements, capture snapshots, manage panes, and orchestrate multi-service environments.

**Detection:** `cmux ping` returns `PONG` when available.

## Environment Variables

- `CMUX_WORKSPACE_ID` — Auto-set in cmux terminals. Default `--workspace` for all commands.
- `CMUX_SURFACE_ID` — Auto-set in cmux terminals. Default `--surface`.
- `CMUX_TAB_ID` — Optional alias for `tab-action`/`rename-tab` as default `--tab`.
- `CMUX_SOCKET_PATH` — Override default Unix socket path (`/tmp/cmux.sock`).

## Critical Rule: --surface flag

When calling `cmux browser` commands from a terminal pane (always the case for Claude agents), you MUST pass `--surface <ref>` to target the browser pane. Without it, commands fail or target the wrong surface.

Get the surface ref from `cmux browser open` output:
```bash
cmux browser open http://localhost:3000
# Output: OK surface=surface:7 pane=pane:4 placement=...
# Use surface:7 for all subsequent browser commands
```

## Handle Inputs

For most commands you can use UUIDs, short refs (`window:1`/`workspace:2`/`pane:3`/`surface:4`), or indexes. Pass `--id-format uuids` or `--id-format both` to include UUIDs in output.

---

## General Commands

```bash
cmux version                                         # Show version
cmux ping                                            # Health check (returns PONG)
cmux capabilities                                    # List capabilities
cmux identify [--workspace <id>] [--surface <id>] [--no-caller]  # Identify context
```

## Window Management

```bash
cmux list-windows                                    # List all windows
cmux current-window                                  # Get current window
cmux new-window                                      # Create new window
cmux focus-window --window <id>                      # Focus a window
cmux close-window --window <id>                      # Close a window
cmux move-workspace-to-window --workspace <id> --window <id>  # Move workspace between windows
cmux next-window | previous-window | last-window     # Navigate windows
cmux find-window [--content] [--select] <query>      # Search windows
cmux rename-window [--workspace <id>] <title>        # Rename window
```

## Workspace Management

```bash
cmux list-workspaces                                 # List all workspaces
cmux current-workspace                               # Get current workspace
cmux new-workspace [--command <text>]                # Create workspace (optionally run command)
cmux select-workspace --workspace <id>               # Switch to workspace
cmux close-workspace --workspace <id>                # Close workspace
cmux rename-workspace [--workspace <id>] <title>     # Rename workspace
cmux reorder-workspace --workspace <id> (--index <n> | --before <id> | --after <id>)
# workspace-action: perform workspace context-menu actions
# Actions: pin, unpin, rename, clear-name, move-up, move-down, move-top,
#          close-others, close-above, close-below, mark-read, mark-unread
cmux workspace-action --action <name> [--workspace <id>] [--title <text>]
cmux workspace-action --action pin
cmux workspace-action --action rename --title "infra"
cmux workspace-action --action close-others
```

## Pane & Panel Management

```bash
cmux list-panes [--workspace <id>]                   # List panes
cmux list-pane-surfaces [--workspace <id>] [--pane <id>]  # List surfaces in pane
cmux list-panels [--workspace <id>]                  # List panels
cmux focus-pane --pane <id> [--workspace <id>]       # Focus a pane
cmux focus-panel --panel <id> [--workspace <id>]     # Focus a panel
cmux last-pane [--workspace <id>]                    # Switch to last pane
cmux new-pane [--type <terminal|browser>] [--direction <left|right|up|down>] [--workspace <id>] [--url <url>]
cmux new-split <left|right|up|down> [--workspace <id>] [--surface <id>] [--panel <id>]
cmux swap-pane --pane <id> --target-pane <id> [--workspace <id>]
cmux break-pane [--workspace <id>] [--pane <id>] [--surface <id>] [--no-focus]
cmux join-pane --target-pane <id> [--workspace <id>] [--pane <id>] [--surface <id>] [--no-focus]
cmux resize-pane --pane <id> [--workspace <id>] (-L|-R|-U|-D) [--amount <n>]
cmux drag-surface-to-split --surface <id> <left|right|up|down>
```

## Surface & Tab Management

```bash
cmux new-surface [--type <terminal|browser>] [--pane <id>] [--workspace <id>] [--url <url>]
cmux close-surface [--surface <id>] [--workspace <id>]
cmux move-surface --surface <id> [--pane <id>] [--workspace <id>] [--window <id>] [--before <id>] [--after <id>] [--index <n>] [--focus <true|false>]
cmux reorder-surface --surface <id> (--index <n> | --before <id> | --after <id>)
cmux refresh-surfaces                                # Refresh all surfaces
cmux surface-health [--workspace <id>]               # Check surface health
cmux trigger-flash [--workspace <id>] [--surface <id>]  # Visual flash
cmux rename-tab [--workspace <id>] [--tab <id>] [--surface <id>] <title>

# tab-action: perform tab context-menu actions
# Actions: rename, clear-name, close-left, close-right, close-others,
#          new-terminal-right, new-browser-right, reload, duplicate,
#          pin, unpin, mark-read, mark-unread
cmux tab-action --action <name> [--tab <id>] [--surface <id>] [--workspace <id>] [--title <text>] [--url <url>]
cmux tab-action --tab tab:3 --action pin
cmux tab-action --action rename --title "build logs"
cmux tab-action --action new-browser-right --url "http://localhost:3000"
```

## Terminal I/O

```bash
cmux read-screen [--workspace <id>] [--surface <id>] [--scrollback] [--lines <n>]
cmux send [--workspace <id>] [--surface <id>] <text>           # Send text to surface
cmux send-key [--workspace <id>] [--surface <id>] <key>        # Send keypress
cmux send-panel --panel <id> [--workspace <id>] <text>         # Send text to panel
cmux send-key-panel --panel <id> [--workspace <id>] <key>      # Send keypress to panel
cmux capture-pane [--workspace <id>] [--surface <id>] [--scrollback] [--lines <n>]  # tmux compat
cmux clear-history [--workspace <id>] [--surface <id>]
cmux respawn-pane [--workspace <id>] [--surface <id>] [--command <cmd>]
cmux pipe-pane --command <shell-command> [--workspace <id>] [--surface <id>]
cmux display-message [-p|--print] <text>
```

## Clipboard / Buffers

```bash
cmux set-buffer [--name <name>] <text>               # Set buffer content
cmux list-buffers                                    # List all buffers
cmux paste-buffer [--name <name>] [--workspace <id>] [--surface <id>]
```

## Notifications

```bash
cmux notify --title <text> [--subtitle <text>] [--body <text>] [--workspace <id>] [--surface <id>]
cmux list-notifications                              # List all notifications
cmux clear-notifications                             # Clear all notifications
```

## Sidebar Metadata

```bash
cmux set-status <key> <value> [--icon <name>] [--color <#hex>] [--workspace <id>]
cmux clear-status <key> [--workspace <id>]
cmux list-status [--workspace <id>]
cmux set-progress <0.0-1.0> [--label <text>] [--workspace <id>]
cmux clear-progress [--workspace <id>]
cmux log [--level <level>] [--source <name>] [--workspace <id>] [--] <message>
cmux list-log [--limit <n>] [--workspace <id>]
cmux clear-log [--workspace <id>]
cmux sidebar-state [--workspace <id>]
```

## Claude Integration Hooks

```bash
cmux claude-hook session-start [--workspace <id>] [--surface <id>]  # Signal session start (reads JSON from stdin)
cmux claude-hook stop [--workspace <id>] [--surface <id>]           # Signal session stop
cmux claude-hook notification [--workspace <id>] [--surface <id>]   # Forward notification
```

## App Focus

```bash
cmux set-app-focus <active|inactive|clear>
cmux simulate-app-active
```

## Synchronization

```bash
cmux wait-for [-S|--signal] <name> [--timeout <seconds>]  # Wait for named signal
cmux wait-for -S <name>                                    # Send named signal
```

## tmux Compatibility Stubs

These exist for tmux compatibility but have minimal documentation:
```bash
cmux set-hook [--list] [--unset <event>] | <event> <command>
cmux bind-key | unbind-key | copy-mode
cmux popup
```

---

## Browser Commands

All browser commands use: `cmux browser [--surface <ref>] <subcommand>`

### Navigation

```bash
cmux browser open [url]                              # Open browser pane (returns surface ref)
cmux browser open-split [url]                        # Open browser in new split
cmux browser goto|navigate <url> --surface <ref>     # Navigate to URL [--snapshot-after]
cmux browser back --surface <ref>                    # Go back [--snapshot-after]
cmux browser forward --surface <ref>                 # Go forward [--snapshot-after]
cmux browser reload --surface <ref>                  # Reload page [--snapshot-after]
cmux browser url|get-url --surface <ref>             # Get current URL
```

### Waiting

```bash
cmux browser wait --load-state <interactive|complete> --timeout-ms 5000 --surface <ref>
cmux browser wait --selector "<css>" --timeout-ms 5000 --surface <ref>
cmux browser wait --text "Welcome" --timeout-ms 5000 --surface <ref>
cmux browser wait --url-contains "/dashboard" --timeout-ms 5000 --surface <ref>
cmux browser wait --function "() => window.loaded" --surface <ref>
```

### Reading Content

```bash
cmux browser snapshot --compact --surface <ref>                    # DOM tree (most useful)
cmux browser snapshot --interactive --surface <ref>                # Interactive elements
cmux browser snapshot --cursor --surface <ref>                     # Include cursor info
cmux browser snapshot --max-depth <n> --surface <ref>              # Limit depth
cmux browser snapshot --selector "main" --compact --surface <ref>  # Scoped snapshot
cmux browser get text "<selector>" --surface <ref>                 # Element text
cmux browser get count "<selector>" --surface <ref>                # Element count
cmux browser get title --surface <ref>                             # Page title
cmux browser get url --surface <ref>                               # Current URL
cmux browser get html "<selector>" --surface <ref>                 # Element HTML
cmux browser get value "<selector>" --surface <ref>                # Input value
cmux browser get attr "<selector>" "<attr>" --surface <ref>        # Element attribute
cmux browser get box "<selector>" --surface <ref>                  # Bounding box
cmux browser get styles "<selector>" --surface <ref>               # Computed styles
cmux browser is visible "<selector>" --surface <ref>               # Returns 1/0
cmux browser is enabled "<selector>" --surface <ref>
cmux browser is checked "<selector>" --surface <ref>
```

### Interacting

```bash
cmux browser click "<selector>" --surface <ref>                    # [--snapshot-after]
cmux browser dblclick "<selector>" --surface <ref>                 # [--snapshot-after]
cmux browser hover "<selector>" --surface <ref>                    # [--snapshot-after]
cmux browser focus "<selector>" --surface <ref>                    # [--snapshot-after]
cmux browser fill "<selector>" "text" --surface <ref>              # Clears then types [--snapshot-after]
cmux browser fill "<selector>" "" --surface <ref>                  # Clear input
cmux browser type "<selector>" "text" --surface <ref>              # Appends to existing [--snapshot-after]
cmux browser press "Enter" --surface <ref>                         # [--snapshot-after]
cmux browser keydown "Shift" --surface <ref>                       # [--snapshot-after]
cmux browser keyup "Shift" --surface <ref>                         # [--snapshot-after]
cmux browser select "<selector>" "value" --surface <ref>           # Dropdown [--snapshot-after]
cmux browser check "<selector>" --surface <ref>                    # [--snapshot-after]
cmux browser uncheck "<selector>" --surface <ref>                  # [--snapshot-after]
cmux browser scroll --dy 500 --surface <ref>                       # [--selector <css>] [--dx <n>] [--snapshot-after]
cmux browser scroll-into-view "<selector>" --surface <ref>         # [--snapshot-after]
```

### Finding Elements

```bash
cmux browser find role "button" --surface <ref>
cmux browser find text "Submit" --surface <ref>
cmux browser find label "Email" --surface <ref>
cmux browser find placeholder "Enter name" --surface <ref>
cmux browser find alt "Logo" --surface <ref>
cmux browser find title "Close" --surface <ref>
cmux browser find testid "login-btn" --surface <ref>
cmux browser find first "<selector>" --surface <ref>
cmux browser find last "<selector>" --surface <ref>
cmux browser find nth "<selector>" <n> --surface <ref>
```

### Frames

```bash
cmux browser frame "<selector>" --surface <ref>      # Switch to iframe
cmux browser frame main --surface <ref>              # Switch back to main frame
```

### Dialogs

```bash
cmux browser dialog accept [text] --surface <ref>    # Accept dialog (optional input text)
cmux browser dialog dismiss [text] --surface <ref>   # Dismiss dialog
```

### Downloads

```bash
cmux browser download [wait] [--path <path>] [--timeout-ms <ms>] --surface <ref>
```

### Cookies & Storage

```bash
cmux browser cookies get [...] --surface <ref>
cmux browser cookies set [...] --surface <ref>
cmux browser cookies clear [...] --surface <ref>
cmux browser storage local get [...] --surface <ref>
cmux browser storage local set [...] --surface <ref>
cmux browser storage local clear [...] --surface <ref>
cmux browser storage session get [...] --surface <ref>
cmux browser storage session set [...] --surface <ref>
cmux browser storage session clear [...] --surface <ref>
```

### Browser Tabs

```bash
cmux browser tab new [url] --surface <ref>           # Open new tab
cmux browser tab list --surface <ref>                # List tabs
cmux browser tab switch <index> --surface <ref>      # Switch tab
cmux browser tab close [index] --surface <ref>       # Close tab
cmux browser tab <index> --surface <ref>             # Switch to tab by index
```

### Page Injection

```bash
cmux browser addinitscript <script> --surface <ref>  # Run JS on every navigation
cmux browser addscript <script> --surface <ref>      # Inject JS
cmux browser addstyle <css> --surface <ref>          # Inject CSS
```

### State Management

```bash
cmux browser state save <path> --surface <ref>       # Save browser state
cmux browser state load <path> --surface <ref>       # Load browser state
```

### Debugging

```bash
cmux browser console list --surface <ref>            # Console messages
cmux browser console clear --surface <ref>           # Clear console
cmux browser errors list --surface <ref>             # JS errors
cmux browser errors clear --surface <ref>            # Clear errors
cmux browser eval "document.title" --surface <ref>   # Run JS
cmux browser highlight "<selector>" --surface <ref>  # Visual highlight
cmux browser identify --surface <ref>                # Identify browser surface
```

### Advanced (may return not_supported on WKWebView)

```bash
cmux browser viewport <width> <height> --surface <ref>
cmux browser geolocation|geo <lat> <lon> --surface <ref>
cmux browser offline <true|false> --surface <ref>
cmux browser trace <start|stop> [path] --surface <ref>
cmux browser network <route|unroute|requests> [...] --surface <ref>
cmux browser screencast <start|stop> --surface <ref>
cmux browser input <mouse|keyboard|touch> --surface <ref>
```

---

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

### Send notification when task completes
```bash
cmux notify --title "Build done" --body "All tests passed"
cmux notify --title "Error" --subtitle "test.swift" --body "Line 42: syntax error"
```

### Track progress in sidebar
```bash
cmux set-status "phase" "Building" --icon "hammer" --color "#f0ad4e"
cmux set-progress 0.5 --label "50% complete"
cmux log --level info --source "build" "Compiling modules..."
```
