FROM node:24.22.1-trixie-slim AS node

FROM ruby:3.4.10-slim

ENV LANG=C.UTF-8

# curl is used by the omega CI jobs; gnupg and wget are kept so the image keeps the
# packages it had when Node was installed from the nodejs.org tarball.
RUN apt-get update && apt-get install -y --no-install-recommends gnupg curl wget ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Node comes from the official multi-arch image, so the same Dockerfile builds for amd64
# and arm64 (Apple Silicon) without downloading and verifying the tarball by hand.
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && node --version && npm --version

RUN npm install -g yarn

RUN apt-get update && apt-get install -y --no-install-recommends git build-essential default-libmysqlclient-dev shared-mime-info file imagemagick \
  && rm -rf /var/lib/apt/lists/*
