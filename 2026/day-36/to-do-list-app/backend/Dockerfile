# Stage 1: Install deps
FROM node:20-alpine AS deps

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

# Stage 2: Final image
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Switch to non-root
USER appuser

EXPOSE 3000

CMD ["node", "app.js"]
