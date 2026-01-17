# Browser Workflow in Mariner DevContainer

This document explains how browsers work with the Mariner development environment and how to access your running services.

## Overview

VSCode automatically handles opening browsers for forwarded ports using **native port forwarding** with intelligent browser launching. No custom scripts or platform-specific configuration required.

## Port Forwarding Strategy

The devcontainer is configured with different browser behaviors for each service based on typical usage patterns:

| Port | Service | Browser Behavior | Rationale |
|------|---------|-----------------|-----------|
| **5173** | Vite Dev Server (React) | `openBrowser` - External browser | Needs full DevTools for React debugging and responsive testing |
| **10350** | Tilt UI | `openPreview` - Embedded browser | Monitoring dashboard; side-by-side view with code is ideal |
| **8080** | Ktor API | `notify` - Manual only | Usually accessed via React app; rarely needs direct browser access |
| **6080** | noVNC Browser UI | `notify` - Manual only | Specialty tool; only open when testing Playwright scripts |

## How It Works

### Automatic Port Detection

When a service starts and binds to a port, VSCode automatically:
1. Detects the port is in use
2. Forwards it to your host machine
3. Takes the configured action (`openBrowser`, `openPreview`, or `notify`)

> **Important: `forwardPorts` vs `onAutoForward`**
>
> The `onAutoForward` action **only triggers for auto-detected ports**. Ports listed in `forwardPorts` are pre-forwarded at container startup (before any service is listening), so the `onAutoForward` action never fires for them.
>
> **Rule of thumb:**
> - Use `forwardPorts` for ports where you want `notify` or `silent` behavior
> - Omit from `forwardPorts` any port where you want `openBrowser` or `openPreview` to auto-trigger
>
> This is why ports 5173 (Vite) and 10350 (Tilt) are **not** in `forwardPorts` but still have `portsAttributes` configured—we want their `onAutoForward` actions to trigger when the services start.

### External Browser (`openBrowser`)

**Used for:** Vite Dev Server (port 5173)

When the Vite dev server starts, VSCode will automatically **open your default browser** (Chrome, Firefox, Safari, etc.) on your host machine with the URL `http://localhost:5173`.

**Benefits:**
- Full browser DevTools (Elements inspector, Console, Network tab, etc.)
- React DevTools extensions work
- Responsive design testing with device emulation
- Cross-browser testing capability

**Platform Support:**
- **WSL2**: Opens Windows browser automatically
- **macOS**: Opens default macOS browser
- **Linux**: Opens default Linux browser
- **Remote SSH**: Creates secure tunnel and opens local browser

### Embedded Preview (`openPreview`)

**Used for:** Tilt UI (port 10350)

When Tilt starts, VSCode will automatically open the Tilt UI in an **embedded Simple Browser** inside a VSCode editor tab.

**Benefits:**
- Side-by-side view: Code on left, Tilt dashboard on right
- No window switching needed
- Perfect for monitoring build status while coding
- One less window cluttering your workspace
- Fresh cache on every restart

**Recommended Layout:**
```
┌─────────────────────────────────────┬──────────────────────┐
│                                     │                      │
│   Code Editor                       │   Tilt UI (Preview)  │
│   (api/src/...)                     │   Build Status       │
│                                     │   Pod Logs           │
│                                     │   Resource Health    │
│                                     │                      │
└─────────────────────────────────────┴──────────────────────┘
```

**Limitations:**
- No full browser DevTools
- Can't install browser extensions
- Sufficient for monitoring dashboards (which is perfect for Tilt)

### Notification Only (`notify`)

**Used for:** API (port 8080), noVNC (port 6080)

VSCode shows a notification when the port is forwarded but doesn't open any browser automatically.

**Manual Access:**
1. Click the notification to open the browser, or
2. Open the **Ports** panel (View → Ports)
3. Click the **globe icon** next to the port to open in browser
4. Or click the **Local Address** link

## Common Workflows

### Starting Development

1. Open the project in VSCode
2. Rebuild and reopen in devcontainer (if needed)
3. Wait for Tilt to start (automatic via `postStartCommand`)
4. **Automatically happens:**
   - Tilt UI opens in embedded browser (side-by-side)
   - When Vite server is ready, React app opens in external browser
5. Start coding!

### Accessing Services Manually

#### View All Forwarded Ports

1. Open the **Ports** panel:
   - View → Ports (in menu)
   - Or press `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (macOS)
   - Type "Ports: Focus on Ports View"

2. You'll see all forwarded ports with labels:
   ```
   Port    Label                  Local Address
   5173    Vite Dev Server        localhost:5173
   8080    Ktor API              localhost:8080
   10350   Tilt UI               localhost:10350
   6080    noVNC (browser UI)    localhost:6080
   ```

#### Open in Browser

- **Click the globe icon** next to any port to open in browser
- **Right-click the port** → "Open in Browser"
- **Ctrl/Cmd + Click** on the Local Address link

#### Open in Embedded Preview

- **Right-click the port** → "Preview in Editor"
- Useful if you want to view the API health endpoint or noVNC in embedded mode

### Switching Between External and Embedded

You can override the default behavior:

1. Find the port in the **Ports** panel
2. Right-click the port:
   - **"Open in Browser"** - Opens in external browser (even if default is embedded)
   - **"Preview in Editor"** - Opens in embedded Simple Browser (even if default is external)

### Closing Embedded Previews

Embedded browser tabs are just editor tabs:
- Close them with `Ctrl+W` / `Cmd+W`
- Or click the ✕ on the tab
- They'll reopen automatically if the port forwards again

## Cross-Platform Compatibility

This solution works **identically** on all platforms with **zero configuration**:

| Platform | How It Works |
|----------|--------------|
| **WSL2 (Windows)** | VSCode forwards ports through the Windows host and opens Windows browsers |
| **macOS** | Native port forwarding to macOS, opens default browser |
| **Linux** | Direct port forwarding, uses default browser |
| **Remote SSH** | VSCode creates secure tunnels and opens browser on your local machine |
| **GitHub Codespaces** | Cloud-based port forwarding with authentication |

## Troubleshooting

### Port Not Auto-Forwarding

**Symptom:** Service is running but port doesn't show in Ports panel

**Solutions:**
1. Check the service is actually running: `kubectl get pods -n mariner-dev`
2. Manually forward the port:
   - Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
   - Type "Forward a Port"
   - Enter the port number
3. Check `devcontainer.json` has the port in `forwardPorts` array

### Browser Doesn't Open Automatically

**Symptom:** Port forwards but browser doesn't open

**Solutions:**
1. **Check if port is in `forwardPorts`:** The most common cause! If the port is listed in `forwardPorts`, the `onAutoForward` action won't trigger because the port is pre-forwarded at startup. Remove the port from `forwardPorts` if you want `openBrowser` or `openPreview` to work.
2. Check VSCode settings:
   - Settings → Search "port auto forward"
   - Ensure "Remote › Auto Forward Ports" is enabled
3. Manually open from Ports panel (see above)
4. Check if notification was dismissed - won't auto-open again until next session

### Embedded Preview Shows Error

**Symptom:** Simple Browser shows "Cannot connect" or security error

**Causes:**
- Service hasn't started yet (wait a few seconds)
- Some sites block embedding (iframe restrictions)
- Mixed content issues (HTTPS page loading HTTP resources)

**Solutions:**
1. Wait for service to fully start
2. For complex apps, use external browser instead (right-click → "Open in Browser")
3. Check service logs: `kubectl logs -n mariner-dev <pod-name>`

### Prefer External Browser for Tilt

If you prefer Tilt in an external browser instead of embedded:

**Option 1: Right-click override**
- Right-click port 10350 in Ports panel
- Select "Open in Browser"

**Option 2: Change configuration**
Edit `.devcontainer/devcontainer.json`:
```json
"10350": {
  "label": "Tilt UI",
  "onAutoForward": "openBrowser"  // Changed from "openPreview"
}
```
Then rebuild the devcontainer.

## Best Practices

### Screen Layout for Development

**Recommended VSCode layout:**
1. **Left side:** Code editor (70% width)
2. **Right side:** Tilt UI embedded preview (30% width)
3. **External browser:** React app in full browser window on second monitor (or Alt+Tab)

This gives you:
- Code and build status always visible
- Full browser for testing the app
- No constant window switching

### When to Use Which Browser Mode

| Scenario | Use External Browser | Use Embedded Preview |
|----------|---------------------|---------------------|
| Developing React components | ✅ Yes - need DevTools | ❌ |
| Testing responsive design | ✅ Yes - need device emulation | ❌ |
| Monitoring Tilt builds | ❌ | ✅ Yes - perfect for dashboards |
| Debugging API responses | ✅ Yes - need Network tab | ❌ |
| Checking build logs | ❌ | ✅ Yes - read-only viewing |
| Testing Playwright scripts | ✅ Yes - need real browser | ❌ |

### Managing Screen Real Estate

**Single monitor:**
- Use embedded preview for Tilt (side-by-side)
- Use external browser for React app (Alt+Tab when needed)

**Dual monitors:**
- VSCode + embedded Tilt on primary monitor
- External browser with React app on secondary monitor

**Ultra-wide monitor:**
- Split screen: VSCode (left 60%) + External Browser (right 40%)
- Embedded Tilt UI in VSCode's right editor group

## Configuration Reference

### Current Configuration

From `.devcontainer/devcontainer.json`:

```json
{
  "forwardPorts": [6080, 8080],
  "portsAttributes": {
    "6080": {
      "label": "noVNC (browser UI)",
      "onAutoForward": "notify"
    },
    "5173": {
      "label": "Vite Dev Server",
      "onAutoForward": "openBrowser"
    },
    "8080": {
      "label": "Ktor API",
      "onAutoForward": "notify"
    },
    "10350": {
      "label": "Tilt UI",
      "onAutoForward": "openPreview"
    }
  }
}
```

**Note:** Ports 5173 and 10350 are intentionally **not** in `forwardPorts` so their `onAutoForward` actions (`openBrowser` and `openPreview`) will trigger when Vite and Tilt start. Ports 6080 and 8080 use `notify`, so pre-forwarding them is fine.

### Available `onAutoForward` Options

| Value | Behavior |
|-------|----------|
| `"notify"` | Shows notification, no automatic browser open |
| `"openBrowser"` | Opens external browser every time port forwards |
| `"openBrowserOnce"` | Opens external browser only on first forward |
| `"openPreview"` | Opens embedded Simple Browser in VSCode |
| `"silent"` | No notification, no browser open |
| `"ignore"` | Port won't be auto-forwarded |

## Related Documentation

- [VSCode Port Forwarding](https://code.visualstudio.com/docs/debugtest/port-forwarding)
- [DevContainers Specification](https://containers.dev/implementors/json_reference/)
- [Tilt UI Documentation](https://docs.tilt.dev/tutorial/3-tilt-ui.html)
- [VSCode Simple Browser](https://code.visualstudio.com/docs/devcontainers/containers#_opening-a-terminal)

## FAQ

**Q: Can I change which browser opens for external links?**
A: Yes, change your operating system's default browser. VSCode uses the OS default.

**Q: Can I stop auto-opening browsers?**
A: Yes, change `onAutoForward` to `"notify"` in `devcontainer.json` for the specific port.

**Q: Does the embedded browser support JavaScript?**
A: Yes, it's a real browser (using VSCode's webview), just with limited DevTools.

**Q: Can I use the embedded browser with localhost URLs?**
A: Yes, that's exactly what it's designed for with forwarded ports.

**Q: Will this work in GitHub Codespaces?**
A: Yes, identically. Codespaces uses the same DevContainer specification.

**Q: Can I debug in the embedded browser?**
A: Limited debugging. For full debugging, use external browser with full DevTools.
