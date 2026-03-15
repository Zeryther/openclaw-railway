FROM ghcr.io/openclaw/openclaw:latest as openclaw
FROM debian:bookworm-slim

# Install Tailscale
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/tailscale.gpg | gpg --dearmor | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/tailscale.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get install -y tailscale

# Copy OpenClaw from the original image
COPY --from=openclaw / /

# Entrypoint script
RUN echo '#!/bin/bash\nset -e\ntailscaled --tun=userspace-networking &\nsleep 2\ntailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname="$TAILSCALE_HOSTNAME"\nexec openclaw' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
