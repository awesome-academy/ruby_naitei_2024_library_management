#!/bin/bash

# Exit on error
set -e

# Ensure database is up-to-date
bundle exec rails db:migrate
if [ "$(bundle exec rails runner "puts Account.count")" -eq 0 ]; then
  echo "Seeding database..."
  bundle exec rails db:seed
else
  echo "Database already seeded."
fi

# Start the server
exec "$@"
