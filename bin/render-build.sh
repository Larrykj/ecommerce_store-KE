#!/usr/bin/env bash
# Build script for Render deployment

set -o errexit # exit on error

bundle install

# Run database migrations and load schemas for solid_cache/queue/cable
bundle exec rails db:prepare
bundle exec rails db:seed

# Precompile assets (if using asset pipeline)
bundle exec rails assets:precompile
