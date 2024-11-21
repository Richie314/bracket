#
# Source code download
#
FROM alpine AS code
ADD https://github.com/evroon/bracket.git /app 

#
# Backend building
#
FROM python:3.12-rc-slim-bookworm AS base
RUN apt update
RUN apt install -y npm nodejs \
    && rm -rf /var/cache/apt/lists/* \
    && pip3 install --upgrade pip pipenv wheel virtualenv \
    && npm install --global yarn

# Backend
ENV AUTO_RUN_MIGRATIONS=true
ENV ALLOW_USER_REGISTRATION=true
ENV ALLOW_INSECURE_HTTP_SSO=false

COPY --from=code /app/backend /app/backend

WORKDIR /app/backend
RUN pipenv install --deploy

#
# Frontend building
#
FROM node:18-alpine AS frontend-deps
WORKDIR /app
COPY --from=code /app/frontend/package.json /app/frontend/yarn.lock ./
RUN yarn

FROM node:18-alpine AS frontend-builder
COPY --from=code /app/frontend /app
WORKDIR /app
COPY --from=frontend-deps /app/node_modules ./node_modules
RUN NEXT_PUBLIC_API_BASE_URL=http://NEXT_PUBLIC_API_BASE_URL_PLACEHOLDER \
    NEXT_PUBLIC_HCAPTCHA_SITE_KEY=NEXT_PUBLIC_HCAPTCHA_SITE_KEY_PLACEHOLDER \
    yarn build

FROM base AS final
WORKDIR /app/frontend
ENV NODE_ENV production

COPY --from=frontend-builder /app/public ./public
COPY --from=frontend-builder /app/.next ./.next
COPY --from=frontend-builder /app/node_modules ./node_modules
COPY --from=frontend-builder /app/package.json ./package.json
# COPY --from=frontend-builder /app/docker-entrypoint.sh ./entrypoint.sh
COPY --from=frontend-builder /app/next.config.js ./next.config.js
COPY --from=frontend-builder /app/next-i18next.config.js ./next-i18next.config.js

RUN yarn next telemetry disable


#
# Run the application
#
EXPOSE 3000
EXPOSE 8400
WORKDIR /app

HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
    CMD wget --spider http://localhost:8400 && wget --spider http://localhost:3000 || exit 1

COPY start.sh .
ENTRYPOINT [ "/app/start.sh" ]