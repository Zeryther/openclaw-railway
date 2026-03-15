FROM ghcr.io/openclaw/openclaw:latest as openclaw
FROM debian:bookworm-slim

# Install Tailscale
RUN apt-get update && apt-get install -y tailscale ca-certificates curl

# Copy OpenClaw from the original image
COPY --from=openclaw / /

# Entrypoint script
RUN echo '#!/bin/bash\nset -e\ntailscaled --tun=userspace-networking &\nsleep 2\ntailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname="$TAILSCALE_HOSTNAME"\nexec openclaw' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
