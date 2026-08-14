#!/bin/bash
set -e

mkdir -p final_model

if [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${TRAINING_BUCKET_NAME}" ]; then
  if [ -n "${MODEL_S3_TIMESTAMP}" ]; then
    MODEL_PREFIX="${MODEL_S3_TIMESTAMP}"
  else
    MODEL_PREFIX="$(aws s3 ls "s3://${TRAINING_BUCKET_NAME}/final_model/" \
      | awk '{print $2}' \
      | sed 's:/$::' \
      | sort -r \
      | head -n 1)"
  fi

  if [ -n "${MODEL_PREFIX}" ]; then
    echo "Syncing model from s3://${TRAINING_BUCKET_NAME}/final_model/${MODEL_PREFIX}/"
    aws s3 sync "s3://${TRAINING_BUCKET_NAME}/final_model/${MODEL_PREFIX}/" final_model/
  else
    echo "No model artifacts found in S3; /predict may fail until training uploads a model."
  fi
else
  echo "AWS/S3 env not set; skipping model sync from S3."
fi

exec python3 app.py
