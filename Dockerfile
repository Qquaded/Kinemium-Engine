FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive

ENV APP_DIR=/app
ENV ROKIT_HOME=/root/.rokit
ENV PATH="${ROKIT_HOME}/bin:${PATH}"

ENV address=0.0.0.0
ENV port=7777

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    wget \
    unzip \
    bash \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

WORKDIR ${APP_DIR}
COPY . .

RUN rokit install --no-trust-check

EXPOSE ${port}

CMD ["/bin/bash", "-lc", "\
    resolved_address=\"${address:-${ADDRESS:-0.0.0.0}}\" && \
    resolved_port=\"${port:-${PORT:-7777}}\" && \
    echo \"[engine] Starting Kinemium server on ${resolved_address}:${resolved_port}...\" && \
    zune run game --server --headless --address \"$resolved_address\" --port \"$resolved_port\" \
    "]