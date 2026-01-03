# Build stage
FROM node:24-alpine AS builder

# Install build dependencies for native modules (better-sqlite3)
RUN apk add --no-cache python3 make g++ sqlite-dev

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Enable corepack and install all dependencies (including dev)
RUN corepack enable && \
    pnpm install --frozen-lockfile

# Copy source code and build configuration
COPY tsconfig.json ./
COPY src ./src

# Build the project
RUN pnpm run build

# Production stage
FROM node:24-alpine

# OCI labels for container metadata
LABEL org.opencontainers.image.title="actual-flow"
LABEL org.opencontainers.image.description="Import transactions from Lunch Flow to Actual Budget using Docker"
LABEL org.opencontainers.image.source="https://github.com/lukaswinter/actual-flow"
LABEL org.opencontainers.image.licenses="MIT"

# Install only runtime dependencies for native modules
RUN apk add --no-cache sqlite-libs tzdata

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Enable corepack and install only production dependencies
RUN corepack enable && \
    pnpm install --prod --frozen-lockfile && \
    pnpm store prune

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create directory for config persistence
RUN mkdir -p /data

# Set environment to use /data for config
ENV CONFIG_PATH=/data \
    NODE_ENV=production

# Default to running the cron service
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cron"]
