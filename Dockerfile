# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=22.14.0

FROM node:${NODE_VERSION}-alpine AS base

WORKDIR /usr/src/app

EXPOSE 3000

FROM base AS dev

RUN --mount=type=bind,source=docker-nodejs-sample/package.json,target=package.json \
    --mount=type=bind,source=docker-nodejs-sample/package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev

USER node

COPY ./docker-nodejs-sample .

CMD npm run dev

FROM base AS prod

RUN --mount=type=bind,source=docker-nodejs-sample/package.json,target=package.json \
    --mount=type=bind,source=docker-nodejs-sample/package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

USER node

COPY ./docker-nodejs-sample .

CMD node /src/index.js

FROM base AS test

ENV NODE_ENV test

RUN --mount=type=bind,source=docker-nodejs-sample/package.json,target=package.json \
    --mount=type=bind,source=docker-nodejs-sample/package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev

USER node

COPY ./docker-nodejs-sample .

RUN npm run test
