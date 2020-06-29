#!/bin/sh

# HAXE_VERSION=3.4.7
# NEKO_VERSION=2.2.0
# NEKO_VERSION_DASH=2-2-0
HAXE_VERSION=4.1.2
NEKO_VERSION=2.3.0
NEKO_VERSION_DASH=2-3-0

echo ""
echo "---------------------------------------"
echo "    Removing Haxe (if installed)"
echo "---------------------------------------"

set +e
apt-get remove haxe neko
set -e


echo ""
echo "---------------------------------------"
echo "    Downloading Neko $NEKO_VERSION (64-bit)"
echo "---------------------------------------"

wget -c https://github.com/HaxeFoundation/neko/releases/download/v$NEKO_VERSION_DASH/neko-$NEKO_VERSION-linux64.tar.gz


echo ""
echo "---------------------------------------"
echo "    Installing Neko $NEKO_VERSION"
echo "---------------------------------------"

# Extract and copy files to /usr/lib/neko

tar xvzf neko-$NEKO_VERSION-linux64.tar.gz
mkdir -p /usr/lib/neko
rm -rf /usr/lib/neko/neko
rm -rf /usr/lib/neko/nekotools
cp -r neko-$NEKO_VERSION-linux64/* /usr/lib/neko

# Add symlinks

rm -rf /usr/bin/neko
rm -rf /usr/bin/nekoc
rm -rf /usr/bin/nekotools
rm -rf /usr/lib/libneko.so

ln -s /usr/lib/neko/libneko.so /usr/lib/libneko.so
ln -s /usr/lib/neko/libneko.so /usr/lib/libneko.so.2
ln -s /usr/lib/neko/neko /usr/bin/neko
ln -s /usr/lib/neko/nekoc /usr/bin/nekoc
ln -s /usr/lib/neko/nekotools /usr/bin/nekotools

if [ -d "/usr/lib64" ]; then
    set +e
    rm -rf /usr/lib64/libneko.so
    ln -s /usr/lib/neko/libneko.so /usr/lib64/libneko.so
    ln -s /usr/lib/neko/libneko.so /usr/lib64/libneko.so.2
    set -e
fi

# Cleanup

rm -rf neko-$NEKO_VERSION-linux
rm neko-$NEKO_VERSION-linux64.tar.gz

# Install libgc, which is required for Neko

apt-get -y install libgc-dev

if [ -d "/usr/lib64" ] && [ ! -f "/usr/lib64/libpcre.so.3" ]; then
    set +e
    ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.3
    set -e
fi

echo ""
echo "---------------------------------------"
echo "    Downloading Haxe $HAXE_VERSION (64-bit)"
echo "---------------------------------------"

wget -c https://github.com/HaxeFoundation/haxe/releases/download/$HAXE_VERSION/haxe-$HAXE_VERSION-linux64.tar.gz

echo ""
echo "---------------------------------------"
echo "    Installing Haxe $HAXE_VERSION"
echo "---------------------------------------"

# Extract and copy files to /usr/lib/haxe

mkdir -p /usr/lib/haxe
rm -rf /usr/lib/haxe/haxe
tar xvzf haxe-$HAXE_VERSION-linux64.tar.gz -C /usr/lib/haxe --strip-components=1

# Add symlinks

rm -rf /usr/bin/haxe
rm -rf /usr/bin/haxelib
rm -rf /usr/bin/haxedoc

ln -s /usr/lib/haxe/haxe /usr/bin/haxe
ln -s /usr/lib/haxe/haxelib /usr/bin/haxelib

# Set up haxelib

mkdir -p /usr/lib/haxe/lib
chmod -R 777 /usr/lib/haxe/lib
haxelib setup /usr/lib/haxe/lib

# Cleanup

rm haxe-$HAXE_VERSION-linux64.tar.gz

echo ""