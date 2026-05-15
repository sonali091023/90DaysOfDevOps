# ─────────────────────────────────────
# Stage 1: Install dependencies
# ─────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json .

RUN npm install --omit=dev

# ─────────────────────────────────────
# Stage 2: Final lightweight image
# ─────────────────────────────────────
FROM node:20-alpine

# Create app directory
WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy dependencies and app files
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["node", "app.js"]
