# Tiltfile for Mariner K8s Development
# This file defines how Tilt builds, deploys, and hot-reloads services

# Set default namespace
allow_k8s_contexts('k3d-mariner-dev')

# Create namespace if it doesn't exist
k8s_yaml('k8s/namespace.yaml')

# ============================================================================
# Database (PostgreSQL)
# ============================================================================
k8s_yaml('k8s/database.yaml')
k8s_resource(
    'db',
    port_forwards=['5432:5432'],
    labels=['database']
)

# ============================================================================
# API (Ktor + Gradle)
# ============================================================================
# Build the API Docker image
docker_build(
    'mariner-api',
    context='./api',
    dockerfile='./api/Dockerfile',
    live_update=[
        # Sync Kotlin source files for quick iteration
        sync('./api/src', '/home/gradle/src/src'),
        # Rebuild when source changes
        run(
            'cd /home/gradle/src && gradle installDist --no-daemon',
            trigger=['./api/src']
        ),
    ]
)

k8s_yaml('k8s/api.yaml')
k8s_resource(
    'api',
    port_forwards=['8080:8080', '5005:5005'],
    labels=['backend'],
    resource_deps=['db']
)

# ============================================================================
# Web (React + Vite)
# ============================================================================
# Build the web Docker image with live updates
docker_build(
    'mariner-web',
    context='./web',
    dockerfile='./web/Dockerfile',
    target='dev',
    live_update=[
        # Sync source files to container for hot reload
        sync('./web/src', '/workspace/src'),
        sync('./web/index.html', '/workspace/index.html'),
        sync('./web/vite.config.ts', '/workspace/vite.config.ts'),
        sync('./web/tsconfig.json', '/workspace/tsconfig.json'),
        sync('./web/package.json', '/workspace/package.json'),
        # Run npm install if package.json changes
        run(
            'cd /workspace && npm install',
            trigger=['./web/package.json']
        ),
    ]
)

k8s_yaml('k8s/web.yaml')
k8s_resource(
    'web',
    port_forwards=['5173:5173'],
    labels=['frontend'],
    resource_deps=['api']
)

# ============================================================================
# Browser (Playwright + noVNC)
# ============================================================================
docker_build(
    'mariner-browser',
    context='./browser',
    dockerfile='./browser/Dockerfile'
)

k8s_yaml('k8s/browser.yaml')
k8s_resource(
    'browser',
    port_forwards=['6080:6080', '5900:5900', '7331:7331'],
    labels=['testing']
)

# ============================================================================
# Tilt Settings
# ============================================================================
# Update settings for better UX
update_settings(
    max_parallel_updates=4,
    k8s_upsert_timeout_secs=60
)

# Print helpful startup message
print("""
╔═══════════════════════════════════════════════════════════════╗
║  Mariner K8s Development Environment                          ║
╠═══════════════════════════════════════════════════════════════╣
║  Services:                                                    ║
║    • Web:      http://localhost:5173                          ║
║    • API:      http://localhost:8080/health                   ║
║    • Browser:  http://localhost:6080 (noVNC)                  ║
║    • Tilt UI:  http://localhost:10350                         ║
║                                                                ║
║  Debug:                                                       ║
║    • JDWP:     localhost:5005                                 ║
║                                                                ║
║  Database:                                                    ║
║    • Postgres: localhost:5432 (user: mariner, db: mariner)    ║
╚═══════════════════════════════════════════════════════════════╝
""")
