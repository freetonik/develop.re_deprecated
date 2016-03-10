FROM ruby:2.3.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV production

COPY scripts/apt-install /bin/apt-install
RUN chmod +x /bin/apt-install

RUN apt-install -yqq apt-transport-https libxslt-dev libxml2-dev \
  wget git make ca-certificates libwxbase3.0 libwxgtk3.0-dev

#NOTE Apt-key command fails for the Docker repo during installation because we are behind a filtering proxy. To work around this, add the key directly using the following:
RUN curl -sSL https://get.docker.com/gpg | apt-key add - \
  && apt-get update -qq && curl -sSL https://get.docker.com/ | sh

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle config build.nokogiri --use-system-libraries

RUN bundle install --without development test

COPY . /usr/src/app
RUN RAILS_ENV=production bin/rake assets:precompile

VOLUME /usr/src/app/tmp
VOLUME /var/folders

EXPOSE 8081
