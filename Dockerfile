## Base layer
FROM ruby:3.4-alpine AS base

RUN apk add --no-cache build-base tzdata yaml-dev

WORKDIR /usr/src/app

ENV BUNDLE_PATH=/usr/src/vendor/bundle

## Bundler layer
FROM base AS bundler

COPY Gemfile /usr/src/app/

RUN bundle install -j $(nproc)

RUN ls -al

## Build layer
FROM base AS build

# Fixme use a specific user for production containers
#RUN addgroup -S appgroup && adduser -S appuser -G appgroup
#USER appuser

COPY --from=bundler /usr/src/vendor/bundle /usr/src/vendor/bundle
COPY . /usr/src/app

CMD ["ruby", "main.rb", "input.txt"]