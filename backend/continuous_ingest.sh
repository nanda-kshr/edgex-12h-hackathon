#!/bin/bash
# continuous_ingest.sh

URL="http://localhost:8000/ingest"

echo "Starting continuous ingestion every 10 seconds. Press Ctrl+C to stop."

while true; do
  echo "Sending power reading..."
  curl -X POST -s $URL \
    -H "Content-Type: application/json" \
    -d '{"appliance_id":"laptop", "power": 0}'
  echo "" # Newline for readability
  sleep 10
done
