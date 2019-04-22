FROM ruby:2.6.1-alpine
RUN apk --update add --virtual __deps__ build-base postgresql-dev \
 && apk add make bash ncurses perl git mysql-dev libpq \
 && gem install 'rails' -v '5.2.3' \
 && mkdir -p /app/log \
 && rails new /app -q \
                   -f \
                   --api \
                   --skip-bootsnap \
                   --skip-system-test \
                   --skip-test \
                   --skip-javascript--skip-coffee \
                   --skip-listen \
                   --skip-spring \
                   --skip-sprockets \
                   --skip-action-cable \
                   --skip-puma \
                   --skip-action-cable \
                   --skip-active-storage \
                   --skip-action-mailer \
                   --skip-keeps \
                   --skip-keeps \
                   --skip-yarn
WORKDIR /app
ADD .context.tar /.orchestration/
RUN cp /.orchestration/docker/Gemfile ./ \
 && bundle install
RUN gem cleanup \
 && apk del __deps__ \
 && rm -rf /usr/lib/ruby/gems/*/cache/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*
ENV TERM=dumb
RUN apk --update add mysql-dev libpq
