#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/ai.storyteller.deckcraft.png
export DESKTOP=/usr/share/applications/ai.storyteller.deckcraft.desktop
export DEPLOY_OPENGL=1
export DEPLOY_PULSE=1

# Deploy dependencies
quick-sharun /usr/bin/deckcraft /usr/bin/deckcraft-cli /usr/bin/zenity

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
# The CI has no GPU, so wgpu cannot create a device and the app exits
quick-sharun --simple-test ./dist/*.AppImage
