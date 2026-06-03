FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Configurable environment
# =========================
ENV APP_DIR=/app
ENV ROKIT_HOME=/root/.rokit
ENV PATH="${ROKIT_HOME}/bin:${PATH}"

# Runtime defaults (overridable at runtime with -e)
ENV address=0.0.0.0
ENV port=7777
ENV PLAYIT_SECRET=""
ENV USE_PLAYIT=false

# =========================
# Base dependencies
# =========================
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    wget \
    unzip \
    bash \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# =========================
# Install Rokit
# =========================
RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

# =========================
# Install playit.gg (optional, only runs if USE_PLAYIT=true)
# =========================
RUN curl -L -o playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
    && chmod +x playit \
    && mv playit /usr/local/bin/playit

# =========================
# App setup
# =========================
WORKDIR ${APP_DIR}
COPY . .

RUN rokit install --no-trust-check

# =========================
# Runtime
# =========================
EXPOSE ${port}

CMD ["/bin/bash", "-lc", "\
    resolved_address=\"${address:-${ADDRESS:-0.0.0.0}}\" && \
    resolved_port=\"${port:-${PORT:-7777}}\" && \
    if [ \"$USE_PLAYIT\" = \"true\" ] && [ -n \"$PLAYIT_SECRET\" ]; then \
    echo '[playit] Starting playit.gg tunnel...' && \
    playit --stdout --secret \"$PLAYIT_SECRET\" --platform_docker & \
    elif [ \"$USE_PLAYIT\" = \"true\" ] && [ -z \"$PLAYIT_SECRET\" ]; then \
    echo '[playit] USE_PLAYIT=true but PLAYIT_SECRET is not set, skipping.' ; \
    fi && \
    echo \"[engine] Starting Kinemium server on ${resolved_address}:${resolved_port}...\" && \
    zune run game --server --headless --address \"$resolved_address\" --port \"$resolved_port\" \
    "]
