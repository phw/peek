#!/bin/sh
LOCAL_REPO=${HOME}/flatpak-repo

if [ -z  "$1" ]; then
    BRANCH=master
else
    BRANCH=$1
fi

cd `dirname $0`

flatpak-builder --repo="${LOCAL_REPO}" com.uploadedlobster.peek \
  --gpg-sign=B539AD7A5763EE9C1C2E4DE24C14923F47BF1A02 \
  flatpak-${BRANCH}.json --force-clean
