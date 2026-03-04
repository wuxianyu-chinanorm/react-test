# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm and copy dependency files
RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml ./
# Unset proxy env vars that can break corepack/pnpm in Podman (invalid URL protocol)
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy NO_PROXY no_proxy 2>/dev/null; pnpm install --frozen-lockfile

# Copy source and build
COPY . .
RUN pnpm run build

# Production stage: serve with nginx
FROM nginx:alpine

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# App is built with base: '/foo/', so assets are requested as /foo/index-*.js etc.
# Use alias so /foo/<file> maps to /usr/share/nginx/html/<file> (not .../foo/<file>).
# SPA fallback: serve index.html for client-side routes under /foo/
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location /foo/ { \
        alias /usr/share/nginx/html/; \
        try_files $uri $uri/ /foo/index.html; \
    } \
    location / { try_files $uri $uri/ /index.html; } \
    }' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
