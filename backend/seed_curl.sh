#!/bin/bash
# seed_curl.sh

URL="http://127.0.0.1:8000/ingest"

echo "Seeding regular readings..."
for i in {15..1}; do
  # Subtract 'i' minutes from current time
  TIME=$(date -v-${i}M -u +"%Y-%m-%dT%H:%M:%SZ")
  POWER=$((30 + RANDOM % 30))
  echo "- Sending power ${POWER}W at $TIME"
  curl -X POST -s -H "Content-Type: application/json" -d "{\"appliance_id\":\"laptop\",\"power\":$POWER,\"timestamp\":\"$TIME\"}" $URL
  echo ""
done

echo "Seeding a spike reading..."
TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
POWER=$((200 + RANDOM % 50))
echo "- Sending spike power ${POWER}W at $TIME"
curl -X POST -s -H "Content-Type: application/json" -d "{\"appliance_id\":\"laptop\",\"power\":$POWER,\"timestamp\":\"$TIME\"}" $URL
echo ""
