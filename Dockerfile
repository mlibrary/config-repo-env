ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.3
ARG UNAME=app
ARG UID=1000
ARG GID=1000


LABEL maintainer="mrio@umich.edu"

## Install Vim (optional)
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim-tiny \
  libsodium-dev

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app
