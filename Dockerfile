FROM ruby:3.2.2-alpine AS builder

RUN \
	apk update && apk upgrade && \
	apk --no-cache add build-base nodejs npm && \
	rm -rf /var/cache/apk/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
ENV BUNDLER_WITHOUT="development test"
ENV BUNDLE_DEPLOYMENT="true"
RUN gem install bundler && bundle install --no-cache
RUN rm -rf vendor/bundle/ruby/*/cache/

FROM ruby:3.2.2-alpine

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/vendor/ ./vendor/
COPY . .

ENV BUNDLER_WITHOUT="development test"
ENV BUNDLE_DEPLOYMENT="true"
RUN gem install bundler && bundle install --no-cache

CMD ["bundle", "exec", "rackup"]
