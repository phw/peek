#!/bin/sh
LOCAL_REPO=${HOME}/flatpak-repo
REMOTE_REPO=s3://flatpak.uploadedlobster.com
REGION=eu-central-1

flatpak build-update-repo \
  --generate-static-deltas \
  --gpg-sign=B539AD7A5763EE9C1C2E4DE24C14923F47BF1A02 \
  --prune --prune-depth=20 \
  ${LOCAL_REPO}

# First sync all but the summary
aws s3 sync --region="${REGION}" \
  --acl public-read \
  --exclude="summary" --exclude="summary.sig" \
  "${LOCAL_REPO}" "${REMOTE_REPO}"

# Sync the summary
aws s3 sync --region="${REGION}" \
  --acl public-read \
  --exclude="*" --include="summary" --include="summary.sig" \
  "${LOCAL_REPO}" "${REMOTE_REPO}"

# As a last pass also sync deleted files
aws s3 sync --region="${REGION}" \
  --acl public-read \
  --delete \
  "${LOCAL_REPO}" "${REMOTE_REPO}"
