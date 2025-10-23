FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

# Final stage with k6
FROM grafana/k6:latest

WORKDIR /tests

# Copy built tests from builder
COPY --from=builder /app/dist ./dist

# Copy run script
COPY run-tests.sh ./

ENTRYPOINT ["/bin/sh"]
CMD ["./run-tests.sh"]

