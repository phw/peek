#!/bin/sh
LOCAL_REPO=${HOME}/flatpak-repo

if [ -z  "$1" ]; then
    BRANCH=master
else
    BRANCH=$1
fi

WORK_DIR=$(dirname $0)
cd $WORK_DIR

build_for_arch () {
  ARCH=$1
  mkdir -p .${ARCH}
  cd .${ARCH}
  cp ../flatpak-${BRANCH}.json .

  flatpak-builder --repo="${LOCAL_REPO}" com.uploadedlobster.peek \
    --gpg-sign=B539AD7A5763EE9C1C2E4DE24C14923F47BF1A02 \
    flatpak-${BRANCH}.json --force-clean --arch=${ARCH}
  cd ..
}

build_for_arch x86_64
build_for_arch i386
