# Pull the ruby base image
# FROM ruby:3.0.3-slim
FROM ruby:3.0.3

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - postgresql-client: Communicate with postgres DB
RUN apt-get update && apt-get install -y build-essential nodejs default-libmysqlclient-dev postgresql-client curl git libpq-dev

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq && apt-get install -y yarn

# Specify the work directory
WORKDIR /myapp

# Set SECRET_KEY_BASE to a placeholder value
# This is not suitable for production use
# ENV SECRET_KEY_BASE=dumb
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT 1

# Copy the Gemfile and Gemfile.lock into the image and install gems before the app code is copied into the image
COPY Gemfile Gemfile.lock ./

# Install the bundler version as in Gemfile.lock and bundle install
RUN gem install bundler:2.3.8 && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy package.json and yarn.lock files into the image
COPY package.json yarn.lock ./
RUN yarn install

# Copy the main application.
COPY . /myapp


# Precompile Rails assets
# RUN bundle exec rails assets:precompile

# Copy the entrypoint script into the image
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Expose port 3000
EXPOSE 3000

# The command to start the puma server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
