#!/bin/bash

if [ -z "${NODE_VERSION}" ]; then
  echo "NODE_VERSION environment variable required"
  exit 1
fi
if [ -z "${YARN_VERSION}" ]; then
  echo "YARN_VERSION environment variable required"
  exit 1
fi

if [[ -n $(git status --porcelain) ]]; then
  echo "GIT Dirty!"
  exit 1
fi

git checkout -b "v${NODE_VERSION}" 2>/dev/null || git checkout "v${NODE_VERSION}"

Dockerfile=<< DOCKERFILE

FROM alpine:3.4

WORKDIR /usr/src/app

ENV BUNDLE_PATH=/usr/local/bundle

# NOTE: libxml2-dev libxslt-dev for nokogiri (actionview 4.2 <- rails-html-sanitizer)
# NOTE: libffi-dev for ffi. see https://github.com/ffi/ffi/issues/485#issuecomment-191382158
# NOTE: gcc, g++ and libc-dev for json gem
# NOTE: linux-headers for raindrops gem
# NOTE: bash for ci
RUN mkdir -p /usr/src/app \
    && apk update \
    && apk add --no-cache make bash gcc g++ man linux-headers curl git openssl openssh-client \
                          python binutils-gold linux-headers gnupg libgcc \
    ## For the build of node
    && curl -sL https://raw.githubusercontent.com/martinheidegger/install-node/master/install_node.sh | \
       NODE_VERSION="v${NODE_VERSION}" \
       YARN_VERSION="v${YARN_VERSION}" \
       NODE_VARIANT="make" \
       bash \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/perl* /usr/share/man || true

DOCKERFILE

echo "${Dockerfile}" > Dockerfile

git add Dockerfile
if [[ -n $(git status --porcelain) ]]; then
  git commit -m "Updated Node & Yarn version"
  git push -u origin "v${NODE_VERSION}"
fi

