# Pre-built linux/amd64 binaries: place under dist/ before build (see readme).
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    openssh-client \
    screen \
    && rm -rf /var/lib/apt/lists/*

COPY dist/binancepairlist dist/coindg dist/screening /usr/local/bin/
RUN chmod +x /usr/local/bin/binancepairlist /usr/local/bin/coindg /usr/local/bin/screening

COPY scripts/ /opt/gatherscan/
RUN chmod +x /opt/gatherscan/docker-entrypoint.sh /opt/gatherscan/run-coindg-pair.sh

ENV TERM=xterm-256color \
    DATA_ROOT=/data

ENTRYPOINT ["/opt/gatherscan/docker-entrypoint.sh"]
