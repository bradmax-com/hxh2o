# run haxe build.hxml based on current cpu architecture (arm64 or amd64)
# and current platform (linux, macos, windows)
echo "Building"
ARCH=$(uname -m)
PLATFORM=$(uname -s)
echo "Start"
echo 
if [ "$ARCH" = "aarch64" ]; then
    echo "aarch64"
    haxe build.hxml -D HXCPP_LINUX_ARM64 -D arm -D HXCPP_ARM64
elif [ "$ARCH" = "x86_64" ]; then
    echo "x86_64"
    haxe build.hxml
elif [ "$ARCH" = "amd64" ]; then
    echo "amd64"
    haxe build.hxml
fi