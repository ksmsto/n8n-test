#!/bin/sh
set -e
if [ -f /.n8n/database.sqlite ]; then
  echo "Database already exists"
else
  echo "Database does not exist. Creating..."
  litestream restore -if-replica-exists -o ~/.n8n/database.sqlite ${GCS_BUCKET_URL} 
fi

if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec litestream replica -exec "n8n '$@'"
else
  # Got started without arguments
  exec litestream replica -exec "n8n"
fi