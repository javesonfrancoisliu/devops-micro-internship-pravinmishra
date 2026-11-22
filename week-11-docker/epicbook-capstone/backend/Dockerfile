FROM node:18-alpine AS deps
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev

FROM node:18-alpine
ENV NODE_ENV=production \
    PORT=8080
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node app/ ./
USER node
EXPOSE 8080
CMD ["node", "server.js"]
