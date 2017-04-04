FROM alpine:3.4

WORKDIR /usr/src/app

ENV BUNDLE_PATH=/usr/local/bundle
RUN mkdir -p /usr/src/app \
    && apk update \
    && apk add --no-cache \
       make python linux-headers gcc g++ libgcc binutils-gold \# For building Node and the packages
       bash \# Execution of scripts in yarn run
       curl \# For downloading install_node
       git \# Installing git npm dependencies
       mgnupg openssl openssh-client \# Runtime dependency used by node for ssl & crypto operations
    # Building the exact node & yarn version
    && curl -sL https://raw.githubusercontent.com/martinheidegger/install-node/master/install_node.sh | \
       NODE_VERSION="v7.6.0" \
       YARN_VERSION="v0.21.3" \
       NODE_VARIANT="make" \
       bash \
    && apk remove curl \# Curl not needed after the installation
    # Clearing the installation (Don't result in error)
    && (rm -rf \
       /var/lib/apt/lists/* \
       /usr/share/doc \# No need to keep the documentation
       /usr/share/perl* \# No need to keep perl
       /usr/share/man \# No need to keep man files of build dependencies
       || true)
