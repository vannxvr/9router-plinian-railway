# syntax=docker/dockerfile:1.7
ARG NODE_IMAGE=node:22.23.4-alpine
FROM ${NODE_IMAGE} AS builder
WORKDIR /app
RUN apk add --no-cache git python3 make g++ linux-headers

ARG PLINIAN_REPO=https://github.com/vannxvr/9router-plinian.git
ARG PLINIAN_REF=master
ARG NPM_REGISTRY=https://registry.npmjs.org/
RUN git clone --depth 1 --branch "${PLINIAN_REF}" "${PLINIAN_REPO}" /app

RUN --mount=type=cache,id=s/2f3b29ea-d004-4768-8e9a-77623cb89992-plinian-npm-cache,target=/root/.npm \
    npm install --registry="${NPM_REGISTRY}" --fetch-retries=5 \
      --fetch-retry-factor=2 --fetch-retry-mintimeout=10000 \
      --fetch-retry-maxtimeout=120000 --fetch-timeout=300000

ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

RUN --mount=type=cache,id=s/2f3b29ea-d004-4768-8e9a-77623cb89992-plinian-npm-cache,target=/root/.npm \
    mkdir -p /opt/lazy-runtime && cd /opt/lazy-runtime && \
    npm init -y >/dev/null && \
    npm install --no-save --registry="${NPM_REGISTRY}" \
      --fetch-retries=5 --fetch-retry-factor=2 \
      --fetch-retry-mintimeout=10000 --fetch-retry-maxtimeout=120000 \
      --fetch-timeout=300000 wreq-js playwright-core

FROM ${NODE_IMAGE} AS runner
WORKDIR /app
ENV NODE_ENV=production PORT=20128 HOSTNAME=0.0.0.0 NEXT_TELEMETRY_DISABLED=1 DATA_DIR=/app/data

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/custom-server.js ./custom-server.js
COPY --from=builder /app/open-sse ./open-sse
COPY --from=builder /app/src/mitm ./src/mitm
COPY --from=builder /app/node_modules/node-forge ./node_modules/node-forge
COPY --from=builder /app/node_modules/next ./node_modules/next
COPY --from=builder /app/node_modules/sql.js ./node_modules/sql.js
COPY --from=builder /app/node_modules/node-machine-id ./node_modules/node-machine-id
COPY --from=builder /opt/lazy-runtime/node_modules/. ./node_modules/

RUN mkdir -p /app/data /app/data-home && chown -R node:node /app
RUN apk add --no-cache su-exec ffmpeg && \
    printf '#!/bin/sh\\nchown -R node:node /app/data /app/data-home 2>/dev/null\\nexec su-exec node "$@"\\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 20128
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "custom-server.js"]
