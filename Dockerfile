# ---------- Build stage ----------
FROM node:16-bullseye AS builder

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone application source
RUN git clone https://github.com/gauri17-pro/nextflix.git .

# Disable ESLint & telemetry for CI builds
ENV NEXT_DISABLE_ESLINT=1
ENV NEXT_TELEMETRY_DISABLED=1

# Install dependencies and build
RUN yarn install --frozen-lockfile
RUN yarn build


# ---------- Runtime stage ----------
FROM node:16-bullseye

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3001
CMD ["yarn", "start"]
