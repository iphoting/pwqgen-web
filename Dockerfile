FROM ruby:3.1.2-alpine

RUN \
	apk update && apk upgrade && \
	apk --no-cache add build-base ruby-dev ruby-bundler && \
	rm -rf /var/cache/apk/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem install bundler
ENV BUNDLER_WITHOUT development test
RUN bundle install

COPY . .

CMD ["rackup"]
