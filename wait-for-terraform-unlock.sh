#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
  echo "❌ Error: Usage: $0 <BUCKET_NAME> <LOCK_ID>"
  exit 1
fi

BUCKET_NAME="$1"
LOCK_ID="$2"
STATE_LOCK_PATH="gs://${BUCKET_NAME}/terraform/state/default.tflock"
ATTEMPTS=10
SLEEP_TIME=30

echo "🔍 Checking if Terraform state is locked..."
for i in $(seq 1 $ATTEMPTS); do
  if gsutil ls "$STATE_LOCK_PATH" >/dev/null 2>&1; then
    echo "🔒 Terraform state is locked. Attempt $i/$ATTEMPTS. Retrying in $SLEEP_TIME seconds..."
    sleep $SLEEP_TIME
  else
    echo "✅ Terraform state is unlocked. Proceeding..."
    exit 0
  fi
done

echo "⏳ Terraform state lock not released after $((ATTEMPTS * SLEEP_TIME)) seconds."
echo "⚠️ Forcing Terraform state unlock with LOCK_ID: $LOCK_ID..."
terraform force-unlock -force "$LOCK_ID" || {
  echo "❌ Failed to unlock Terraform state. Exiting..."
  exit 1
}

echo "✅ Terraform state successfully unlocked."
exit 0
