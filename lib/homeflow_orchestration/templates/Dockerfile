FROM ruby:<%= environment.fetch(:ruby_version) %>
ADD docker/.build/context.tar.gz .
RUN bundle install
CMD ["bundle", "exec", "rails", "server", "-p", "3000"]
