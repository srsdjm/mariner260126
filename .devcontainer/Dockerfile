# Use Microsoft's official devcontainer base image (Debian-based)
# This image is purpose-built for dev containers and includes:
# - Git, zsh, oh-my-zsh pre-configured
# - Non-root 'vscode' user with sudo access
# - Common dev tools: curl, wget, vim, nano, jq, etc.
FROM mcr.microsoft.com/devcontainers/base:debian

ARG TZ
ENV TZ="$TZ"

ARG GIT_DELTA_VERSION=0.18.2

# Install project-specific tools not provided by devcontainer features
# Note: Base image + features provide: git, curl, wget, vim, nano, jq, zsh, sudo, etc.
# Note: Node.js, Java, kubectl, helm, gh installed via features
RUN apt-get update && apt-get install -y --no-install-recommends \
  fzf \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  postgresql-client \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install git-delta (not available in Debian bookworm, no devcontainer feature exists)
# This provides better git diff output (syntax highlighting)
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Install Tilt (third-party devcontainer features can be unreliable)
RUN ARCH=$(uname -m) && \
  TILT_VERSION=$(curl -sL https://api.github.com/repos/tilt-dev/tilt/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
  wget "https://github.com/tilt-dev/tilt/releases/download/v${TILT_VERSION}/tilt.${TILT_VERSION}.linux.${ARCH}.tar.gz" && \
  tar -xzf "tilt.${TILT_VERSION}.linux.${ARCH}.tar.gz" tilt && \
  mv tilt /usr/local/bin/ && \
  rm "tilt.${TILT_VERSION}.linux.${ARCH}.tar.gz"

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Configure security: firewall script + docker socket permissions
# These require sudo and are justified:
# - init-firewall.sh: Requires root for iptables/ipset (network security control)
# - groupmod/usermod: Required for docker socket GID synchronization (docker-outside-docker)
COPY init-firewall.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "vscode ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/vscode-firewall && \
  echo "vscode ALL=(root) NOPASSWD: /usr/sbin/groupmod" > /etc/sudoers.d/vscode-docker && \
  echo "vscode ALL=(root) NOPASSWD: /usr/sbin/usermod" >> /etc/sudoers.d/vscode-docker && \
  chmod 0440 /etc/sudoers.d/vscode-firewall && \
  chmod 0440 /etc/sudoers.d/vscode-docker

# Switch to non-root user (vscode user is pre-configured in base image)
USER vscode

# Create workspace and config directories
RUN mkdir -p /home/vscode/.claude

# Configure fzf for zsh (zsh and oh-my-zsh are pre-installed in base image)
RUN echo 'source /usr/share/doc/fzf/examples/key-bindings.zsh' >> ~/.zshrc && \
    echo 'source /usr/share/doc/fzf/examples/completion.zsh' >> ~/.zshrc
