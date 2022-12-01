FROM node:19-bullseye-slim as base
RUN mkdir /app
WORKDIR /app

# Build cache
FROM base as build
ADD package.json package-lock.json ./
RUN npm install

# Production build cache
FROM build as production-build
ADD package.json package-lock.json ./
RUN npm prune --production

# Built app cache
FROM build as app
ADD . .
RUN npm run build

# Final app
FROM production-build
RUN apt-get update && apt-get -y upgrade
ENV NODE_ENV=production
COPY --from=app /app/.next /app/.next

# Run application not as root
RUN useradd --create-home appuser
USER appuser

CMD ["npm", "run", "start"]