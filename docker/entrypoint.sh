#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /progimage_store/tmp/pids/server.pid

# DB Migrations
/progimage_store/bin/rake db:create
/progimage_store/bin/rake db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
