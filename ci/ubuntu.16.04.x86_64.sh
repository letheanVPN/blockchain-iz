set -x
echo "CI: Ubuntu 16.04 x86_64"

if [ "$1" = "prep" ]; then

	installDependencyIfNeeded () {
		if [ $(dpkg-query -W -f='${Status}' $@ 2>/dev/null | grep -c "ok installed") -ne 0 ]; then
			echo "CI: Found $@"
		else
			echo "CI: Missing dependency, installing $@..."
			sudo apt-get install $@ -y
			if [ $? -eq 0 ]; then
				echo "CI: Installed $@ successfully."
			else
				echo "CI: Failed to install $@."
				exit 1
			fi
		fi
	}

	# dependencies
	installDependencyIfNeeded build-essential
	installDependencyIfNeeded libssl-dev
	installDependencyIfNeeded libboost-all-dev
	installDependencyIfNeeded pkg-config
	installDependencyIfNeeded cmake

	exit 0

fi

echo "CI: Building static release..."
make -j2 release-static
if [ $? -ne 0 ]; then
	echo "CI: Build failed with error code: $?"
	exit 1
fi

echo "CI: Creating release archive..."
RELEASE_NAME="lethean-cli-linux-64bit-$BUILD_VERSION"
cd build/release/bin/
mkdir $RELEASE_NAME
cp lethean-blockchain-export $RELEASE_NAME/
cp lethean-blockchain-import $RELEASE_NAME/
cp lethean-wallet-cli $RELEASE_NAME/
cp lethean-wallet-rpc $RELEASE_NAME/
cp lethean-wallet-vpn-rpc $RELEASE_NAME/
cp letheand $RELEASE_NAME/
cp ../../../ci/package-artifacts/CHANGELOG.txt $RELEASE_NAME/
cp ../../../ci/package-artifacts/README.txt $RELEASE_NAME/
tar -cvjf $RELEASE_NAME.tar.bz2 $RELEASE_NAME
sha256sum $RELEASE_NAME.tar.bz2 > $RELEASE_NAME.tar.bz2.sha256.txt
