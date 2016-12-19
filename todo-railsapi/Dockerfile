FROM ruby:2.3.3-alpine

ENV APP_HOME /myapp/
ADD ./.ruby-* $APP_HOME
ADD ./Gemfile* $APP_HOME 

RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev libxml2-dev libxslt-dev \  
    postgresql-dev libc-dev linux-headers nodejs tzdata
    
RUN gem install bundler

RUN cd $APP_HOME ; bundle config build.nokogiri --use-system-libraries && bundle install --without development test

ADD ./ $APP_HOME
RUN chown -R nobody:nogroup $APP_HOME
USER nobody

ENV RAILS_ENV production
WORKDIR $APP_HOME
CMD ["bundle", "exec", "rails", "s", "-p", "8080"]
