FROM ruby:2

RUN apt-get update -qq && \
        apt-get install -y --no-install-recommends build-essential=12.3 && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME/
RUN bundle install

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
