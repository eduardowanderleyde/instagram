#!/bin/sh

# Exit on any error
set -e

# Ensure the environment variables are available
if [ -z "$SECRET_KEY_BASE" ] || [ -z "$RAILS_MASTER_KEY" ]; then
  echo "Error: SECRET_KEY_BASE and RAILS_MASTER_KEY must be set"
  exit 1
fi

# Precompile assets
bundle exec rails assets:precompile

# Execute the original entrypoint command
exec "$@"
