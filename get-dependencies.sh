#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cargo             \
	libxcursor        \
	libxi             \
	libxkbcommon      \
	libxkbcommon-x11

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-opengl --prefer-nano

# Comment this out if you need an AUR package
make-aur-package zenity-rs-bin

# If the application needs to be manually built that has to be done down here
echo "Building deckcraft..."
echo "---------------------------------------------------------------"
git clone https://github.com/storytold/deckcraft.git ./deckcraft && (
	cd ./deckcraft

	# No releases yet, so track the default branch until there are tags
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	if [ -n "$TAG" ]; then
		git checkout "$TAG"
		echo "${TAG#v}" > ~/version
	else
		git rev-parse --short HEAD > ~/version
	fi

	cargo build --locked --release -p deckcraft -p deckcraft-cli

	cp -v ./target/release/deckcraft ./target/release/deckcraft-cli /usr/bin
	chmod +x /usr/bin/deckcraft /usr/bin/deckcraft-cli
	cp -v ./packaging/linux/ai.storyteller.deckcraft.desktop /usr/share/applications
	mkdir -p /usr/share/icons
	cp -rv ./assets/app-icon/hicolor /usr/share/icons
)
