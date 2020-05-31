FROM alpine:3.11.6

RUN apk add --no-cache \
    build-base \
    ruby-full \
    ruby-dev \
    libxml2-dev \
    libxslt-dev \
    git

RUN gem install bundler && bundle config --global silence_root_warning 1

ENV GEM_HOME=./_gems
