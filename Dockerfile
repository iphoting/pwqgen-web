FROM ruby:3.4.9-slim AS builder

RUN \
	apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends build-essential nodejs npm && \
	rm -rf /var/lib/apt/lists/*

RUN gem install bundler --no-document

WORKDIR /usr/src/app

ENV BUNDLER_WITHOUT="development test"
ENV BUNDLE_DEPLOYMENT="true"

COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install --no-cache && \
	find vendor/bundle/ruby/*/gems/ -name "*.c" -delete && \
	find vendor/bundle/ruby/*/gems/ -name "*.o" -delete

FROM ruby:3.4.9-slim

RUN gem install bundler --no-document

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/vendor/ ./vendor/
COPY Gemfile Gemfile.lock .ruby-version Procfile config.ru pwqgen-web.rb ./
COPY views/ ./views/
COPY _assets/ ./_assets/
COPY public/ ./public/

ENV BUNDLER_WITHOUT="development test"
ENV BUNDLE_DEPLOYMENT="true"

CMD ["bundle", "exec", "rackup"]
