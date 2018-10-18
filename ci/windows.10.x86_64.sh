set -x
echo "CI: Windows 10 x86_64"

echo "CI: Building static release..."
make -j2 release-static-win64
if [ $? -ne 0 ]; then
	echo "CI: Build failed with error code: $?"
	exit 1
fi

echo "CI: Creating release archive..."
RELEASE_NAME="lethean-cli-win-64bit-$BUILD_VERSION"
cd build/release/bin/
mkdir $RELEASE_NAME
cp lethean-blockchain-export.exe $RELEASE_NAME/
cp lethean-blockchain-import.exe $RELEASE_NAME/
cp lethean-wallet-cli.exe $RELEASE_NAME/
cp lethean-wallet-rpc.exe $RELEASE_NAME/
cp lethean-wallet-vpn-rpc.exe $RELEASE_NAME/
cp letheand.exe $RELEASE_NAME/
cp ../../../ci/package-artifacts/CHANGELOG.txt $RELEASE_NAME/
cp ../../../ci/package-artifacts/README.txt $RELEASE_NAME/
zip -rv $RELEASE_NAME.zip $RELEASE_NAME
sha256sum $RELEASE_NAME.zip > $RELEASE_NAME.zip.sha256.txt
