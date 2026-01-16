# Dev Container Firewall

The dev container includes an optional iptables-based firewall for testing network restrictions.

## Default Behavior

**The firewall is disabled by default.** All network traffic is allowed for normal development.

## Usage

Control the firewall using the `scripts/firewall.sh` command:

```bash
# Show current firewall status
./scripts/firewall.sh status

# Enable strict mode (block all except allowed domains)
./scripts/firewall.sh strict

# Enable permissive mode (allow all traffic)
./scripts/firewall.sh permissive

# Disable firewall completely
./scripts/firewall.sh disable
```

## Firewall Modes

### Disabled (Default)
- No firewall restrictions
- All network traffic is allowed
- Best for normal development

### Permissive
- Firewall is active but allows all outbound traffic
- Useful for testing firewall rules without blocking traffic
- Helps validate that firewall configuration doesn't break connectivity

### Strict
- Blocks all outbound traffic except explicitly allowed domains
- Allowed domains include:
  - GitHub (api.github.com, *.github.com)
  - npm registry (registry.npmjs.org)
  - Anthropic API (api.anthropic.com, statsig.anthropic.com)
  - VSCode marketplace (marketplace.visualstudio.com, *.gallerycdn.vsassets.io)
- Useful for testing in a restricted network environment
- Simulates network security constraints

## Adding Allowed Domains (Strict Mode)

To allow additional domains in strict mode, edit `.devcontainer/init-firewall.sh`:

1. Find the `for domain in \` section (around line 67)
2. Add your domain to the list
3. Run `./scripts/firewall.sh strict` to apply changes

Example:
```bash
for domain in \
    "registry.npmjs.org" \
    "api.anthropic.com" \
    "your-custom-domain.com"; do  # <- Add your domain here
```

## Important Notes

- Firewall settings **do not persist** across container restarts
- You must reapply firewall rules after rebuilding the dev container
- The firewall requires `NET_ADMIN` and `NET_RAW` capabilities (already configured in the dev container)
- VSCode connection to the dev container works regardless of firewall mode

## Troubleshooting

If you encounter connectivity issues:

1. Check firewall status: `./scripts/firewall.sh status`
2. Disable the firewall: `./scripts/firewall.sh disable`
3. If issues persist, the problem is likely not firewall-related
