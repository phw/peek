#!/bin/sh
LOCAL_REPO=${HOME}/flatpak-repo

if [ -z "$1" ]; then
    BRANCH=master
else
    BRANCH=$1
    if [[ "$BRANCH" != "stable" && "$BRANCH" != "master" ]]; then
      echo -e "\e[0;31mOnly branches \e[1;31mstable\e[0;31m and \e[1;31mmaster\e[0;31m are allowed\e[0m"
      exit 1
    fi
fi

WORK_DIR=$(dirname $0)
cd $WORK_DIR

build_for_arch () {
  ARCH=$1
  echo -e "\e[0;36mBuilding Peek \e[1;36m${BRANCH}\e[0;36m for \e[1;36m${ARCH}\e[0m"

  flatpak-builder \
    --require-changes \
    --repo="${LOCAL_REPO}" \
    --gpg-sign=B539AD7A5763EE9C1C2E4DE24C14923F47BF1A02 \
    --force-clean \
    --arch=${ARCH} \
    com.uploadedlobster.peek_${ARCH} flatpak-${BRANCH}.json

  if [ $? -eq 0 ];then
    echo -e "\e[0;32mBuild \e[1;32m${ARCH}\e[0;32m success!\e[0m\n"
  else
    echo -e "\e[0;31mBuild \e[1;31m${ARCH}\e[0;31m failed!\e[0m\n"
    exit $?
  fi
}

build_for_arch x86_64
build_for_arch i386

echo -e "\e[0;36mCopying flatpakref files\e[0m"
cp -v *.flatpakref ${LOCAL_REPO}

echo -e "\n\e[0;36mFinished \e[1;36m${BRANCH}\e[0;36m build and published to \e[1;36m${LOCAL_REPO}\e[0;36m.\e[0m"
echo -e "\e[0;36mRun \e[1;36m./sync-aws.sh\e[0;36m to publish the repository.\e[0m\n"
