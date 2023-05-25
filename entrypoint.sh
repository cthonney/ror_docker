#!/bin/sh
set -e

# Create the DB or migrate
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
