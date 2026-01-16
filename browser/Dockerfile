FROM mcr.microsoft.com/playwright:v1.57.0-noble

ARG PLAYWRIGHT_MCP_VERSION=0.0.47

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    fluxbox \
    novnc \
    websockify \
    x11vnc \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

RUN npx playwright install chrome \
  && npm install -g @playwright/mcp@${PLAYWRIGHT_MCP_VERSION} \
  && npm cache clean --force

WORKDIR /app

COPY start.sh /usr/local/bin/start.sh
COPY mcp.config.json /app/mcp.config.json
RUN chmod +x /usr/local/bin/start.sh

ENV DISPLAY=:99
ENV PLAYWRIGHT_MCP_VERSION=${PLAYWRIGHT_MCP_VERSION}

EXPOSE 5900 6080 7331

CMD ["start.sh"]
