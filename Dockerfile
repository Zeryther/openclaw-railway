FROM ghcr.io/openclaw/openclaw:latest as openclaw
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y curl ca-certificates

# Add Tailscale repository
RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get install -y tailscale

# Copy OpenClaw from the original image
COPY --from=openclaw / /

# Entrypoint script
RUN echo '#!/bin/bash\nset -e\ntailscaled --tun=userspace-networking &\nsleep 2\ntailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname="$TAILSCALE_HOSTNAME"\nexec openclaw gateway --port 18789' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
