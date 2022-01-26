#!/bin/sh
LOCAL_REPO=${HOME}/flatpak-repos/peek
REMOTE_REPO=s3://flatpak.uploadedlobster.com
REGION=eu-central-1

aws s3 sync --region="${REGION}" \
  "${REMOTE_REPO}" "${LOCAL_REPO}"
