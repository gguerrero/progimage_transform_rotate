FROM ruby:2.6.5
RUN apt-get update -qq && \
  apt-get install -y imagemagick postgresql-client

RUN mkdir /progimage_transform_rotate
WORKDIR /progimage_transform_rotate

COPY Gemfile /progimage_transform_rotate/Gemfile
COPY Gemfile.lock /progimage_transform_rotate/Gemfile.lock
RUN bundle install
COPY . /progimage_transform_rotate

# Add a script to be executed every time the container starts.
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
