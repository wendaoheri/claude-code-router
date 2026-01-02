# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files for caching
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code and build
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production

# Copy package.json for production dependencies
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev --ignore-scripts

# Copy build output from builder stage
COPY --from=builder /app/dist ./dist

# Copy example config and set up default config path at /data/config/
COPY config.example.json ./config.example.json

RUN mkdir -p /data/config \
    && cp /app/config.example.json /data/config/config.json

EXPOSE 3456

# Start service using built CLI
CMD ["node", "dist/cli.js", "start", "--config", "/data/config/config.json"]
