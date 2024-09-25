FROM ruby:3.2.2

RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs npm default-mysql-client

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY package.json package-lock.json /app/
RUN npm install

COPY . /app

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

CMD "bash"
