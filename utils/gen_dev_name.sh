#!/bin/sh
# set -euo

grep_prop() {
    local REGEX="s/^$1=//p"
    shift
    local FILES=$@
    cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1

    return 0
}

grep_prop_space() {
    local REGEX="s/^$1 = //p"
    shift
    local FILES=$@
    cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1

    return 0
}

# Kernel Branch and KMI Generation
get_kernel_version() {
    local BRANCH
    local KMI_GENERATION
    local time

    time="$(date +"%H:%M:%S")"

    VERSION="$(grep_prop_space VERSION "$KERNEL_DIR/Makefile")"
    PATCHLEVEL="$(grep_prop_space PATCHLEVEL "$KERNEL_DIR/Makefile")"
    SUBLEVEL="$(grep_prop_space SUBLEVEL "$KERNEL_DIR/Makefile")"

    KERNEL_VER="$VERSION.$PATCHLEVEL.$SUBLEVEL"
    KERNEL_LOCALVER=$(grep_prop "CONFIG_LOCALVERSION" "$OUT_DIR/.config" | tr -d '"')

    BRANCH="$(grep_prop "BRANCH" "$KERNEL_DIR/build.config.constants")"
    [ -z "$BRANCH" ] && BRANCH="$(grep_prop "BRANCH" "$KERNEL_DIR/build.config.common")"
    KMI_GENERATION="$(grep_prop "KMI_GENERATION" "$KERNEL_DIR/build.config.common")"
    android_release=$(echo "$BRANCH" | sed -e '/android[0-9]\{2,\}/!{q255};s/^\(android[0-9]\{2,\}\)-.*/\1/')
    kernel_version="$(echo "$BRANCH" | awk -F- '{print $2}')"

    BETA_VERSION=""
    BETA_VERSION="$WEEK$DAY"
    MODULE_VER="$BETA_VERSION"
    MODULE_VERCODE="$(date +"%g%m%d")"

    BUILD_NUMBER="$(date +"%s")"
    BUILD_NUMBER="$(echo "$BUILD_NUMBER" | cut -c1-8)"
    KMI_VER="$android_release-$KMI_GENERATION"
    SCM_VERSION="$KMI_VER-g$(git rev-parse --verify HEAD | cut -c1-12)"
    FULL_VERSION="$KERNEL_VER-$SCM_VERSION"
    [ -n "$BUILD_NUMBER" ] && FULL_VERSION="$FULL_VERSION-ab$BUILD_NUMBER-$KERNEL_NAME-$BETA_VERSION"
    FULL_VERSION="$FULL_VERSION$KERNEL_LOCALVER"
    export KERNELRELEASE="$FULL_VERSION"
    echo "$FULL_VERSION"   
}

KERNEL_NAME="$1"

# Build Number
KERNEL_DIR="."
# Resources
WEEK="$(date +"%gw%V")"

DAY=$(date +%u | awk '{printf "%c", 96+$1}')

get_kernel_version
echo $FULL_VERSION >tmp
