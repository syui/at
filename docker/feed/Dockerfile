FROM node:18

WORKDIR /app
COPY . .
RUN yarn install

EXPOSE 3000
ENV PORT=3000
ENV NODE_ENV=production

CMD ["yarn", "start"]

LABEL org.opencontainers.image.source=https://github.com/bluesky-social/feed-generator
