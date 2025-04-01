## Base layer
FROM ruby:3.4-alpine AS base

# Accept build arguments for UID/GID
ARG UID=1000
ARG GID=1000

RUN apk add --no-cache build-base tzdata yaml-dev git

# Create user and group with specified UID/GID
RUN addgroup -S appgroup -g ${GID} && \
    adduser -S appuser -u ${UID} -G appgroup

# Create directories with proper ownership
RUN mkdir -p /home/appuser/app /home/appuser/vendor/bundle && \
    chown -R ${UID}:${GID} /home/appuser

WORKDIR /home/appuser/app
USER appuser

# Configure Bundler paths
ENV BUNDLE_PATH=/home/appuser/vendor/bundle \
    BUNDLE_HOME=/home/appuser/vendor/bundle \
    GEM_HOME=/home/appuser/vendor/bundle \
    BUNDLE_APP_CONFIG=/home/appuser/vendor/bundle

## Bundler layer
FROM base AS bundler

COPY --chown=${UID}:${GID} Gemfile* /home/appuser/app/
RUN bundle install -j $(nproc) --path "$BUNDLE_PATH"

## Build layer
FROM base AS build

COPY --from=bundler --chown=${UID}:${GID} /home/appuser/vendor/bundle /home/appuser/vendor/bundle
COPY --from=bundler --chown=${UID}:${GID} /home/appuser/app/Gemfile.lock /home/appuser/app
COPY --chown=${UID}:${GID} . /home/appuser/app

RUN gem install bundler-audit

# Verify zeitwerk is installed
RUN bundle list

CMD ["ruby", "main.rb", "input.txt"]