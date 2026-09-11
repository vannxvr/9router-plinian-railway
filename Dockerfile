FROM decolua/9router:0.5.75
# Bumped from 0.5.45 (2026-07-30). Confirmed via 9router's own CHANGELOG.md
# that v0.5.65 fixed "explicitly bundle node-machine-id into standalone Docker
# runtime image" -- a real Docker-runtime packaging bug, directly relevant
# since this template requires MACHINE_ID_SALT (internal instance ID hashing,
# which depends on node-machine-id). 0.5.45 predates that fix by 5 releases.
# Also picks up subsequent security/auth fixes (SSRF guards, session cookie
# maxAge hardening) through 0.5.75.

# 9router's own Dockerfile already sets PORT/HOSTNAME as ENV defaults and
# handles volume permissions correctly at container start (its entrypoint
# chowns /app/data to the non-root `node` user before dropping privileges),
# so no USER root workaround is needed here, unlike several other templates
# in this project. Still setting PORT explicitly below as a Railway variable
# (not just relying on the image's own Dockerfile default) - a Dockerfile-only
# default has already been proven insufficient for Railway's own edge routing
# on other templates in this collection (Metabase, Postiz, Vaultwarden).
ENV PORT=20128
ENV HOSTNAME=0.0.0.0
ENV DATA_DIR=/app/data

EXPOSE 20128
