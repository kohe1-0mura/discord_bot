FROM ruby:3.2
WORKDIR /app
RUN apt-get update -qq && apt-get install -y build-essential libssl-dev curl
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install
COPY . .
EXPOSE 8080
COPY .env .env
CMD ["ruby", "run.rb"]
