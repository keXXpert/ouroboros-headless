# Ouroboros — Docker image for web UI runtime
# Usage:
#   docker build -t ouroboros-web .
#   docker run --rm -p 8765:8765 ouroboros-web

FROM python:3.10-slim

# System dependencies:
# - git/gh for repo & GitHub tooling
# - curl/wget for runtime diagnostics and quick network probes
# - ripgrep/jq for fast search + JSON inspection in shell workflows
# - (pytest is installed via pip in the same Python environment)
# - procps/lsof for process/port diagnostics
# Playwright/Chromium native libs are installed later via playwright install-deps.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    gh \
    curl \
    wget \
    jq \
    ripgrep \
    procps \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Working directory
ENV APP_HOME=/app
WORKDIR ${APP_HOME}

# Install Python dependencies
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir pytest \
    && python -c "import starlette,requests,httpx,pytest"

# Optional browser tooling layer (Chromium + deps)
# 1 = install browser tooling, 0 = skip (lean VPS profile)
ARG OUROBOROS_INSTALL_BROWSER_TOOLS=1
RUN if [ "${OUROBOROS_INSTALL_BROWSER_TOOLS}" = "1" ]; then \
      python3 -m playwright install-deps chromium && \
      PLAYWRIGHT_BROWSERS_PATH=0 python3 -m playwright install chromium ; \
    else \
      echo "Skipping browser tooling install (OUROBOROS_INSTALL_BROWSER_TOOLS=${OUROBOROS_INSTALL_BROWSER_TOOLS})" ; \
    fi

# Copy application
COPY . .

# Default environment
ENV OUROBOROS_SERVER_HOST=0.0.0.0 \
    OUROBOROS_SERVER_PORT=8765 \
    OUROBOROS_FILE_BROWSER_DEFAULT=${APP_HOME}

EXPOSE 8765

ENTRYPOINT ["python", "server.py"]
