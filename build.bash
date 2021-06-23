#!/bin/bash

printWelcome() {
cat <<EOF
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*     ___      _______  __   __  __    _        ___   _______     *
*    |   |    |       ||  | |  ||  |  | |      |   | |       |    *
*    |   |    |_     _||  |_|  ||   |_| |      |   | |   _   |    *
*    |   |      |   |  |       ||       |      |   | |  | |  |    *
*    |   |___   |   |  |   _   ||  _    | ___  |   | |  |_|  |    *
*    |       |  |   |  |  | |  || | |   ||   | |   | |       |    *
*    |_______|  |___|  |__| |__||_|  |__||___| |___| |_______|    *
*                                                                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                 *
*          Welcome to Lethean VPN - The Peoples Network           *
*                                                                 *
*      We are about to run a custom compile of the code.          *
*      All files downloaded are checksum validated, please        *
*      don't comment out checksum errors it ensures the code      *
*      that is about to be run is the EXACT code our developers   *
*      have intended to install.                                  *
*                                                                 *
*      Please report bugs to us, we will fix it!                  *
*         Help Docs: https://chain.lethean.help                   *
*         Discord:   https://discord.lt.hn                        *
*                                                                 *
*            And away~ we go!                                     *
*                                                                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
EOF

#sleep 15
}

git describe --tags --exact-match 2> /dev/null
if [ $? -eq 0 ]; then
	BUILD_VERSION=`git describe --tags --exact-match`
else
	BUILD_BRANCH=`git rev-parse --abbrev-ref HEAD`
	BUILD_COMMIT=`git rev-parse --short HEAD`
	BUILD_VERSION="$BUILD_BRANCH-$BUILD_COMMIT"
fi
BUILD_VERSION=${BUILD_VERSION//\//-}
export BUILD_VERSION
# determine build host
if [ -x "$(command -v sw_vers)" ]; then
	macOSVersion=`sw_vers -productVersion`
	macOSVersion="${macOSVersion%.*}"
	macOSScript="./ci/macos.$macOSVersion.sh"
	if [ -f $macOSScript ]; then
		$macOSScript $1
	else
		echo "Builds not yet implemented for macOS version $macOSVersion"
		exit 1
	fi
elif [ -x "$(command -v lsb_release)" ]; then
	processorType=$(uname -i)
	kernelName=$(uname -s)
	archName=$(uname -m)
	buildScript=".build/environment/$kernelName/cpu-$processorType-arch-$archName.bash"
	if [ -f "$buildScript" ]; then
	  printWelcome
		bash "${buildScript}" "$1"
	else
		echo "Builds not yet implemented for Linux version ${buildScript:?}"
		exit 1
	fi
elif [ -x "$(command -v uname)" ]; then
	osVersion=`expr substr $(uname -s) 1 10`
	osArchitecture=`uname -m`
	if [ "$osVersion" = "MSYS_NT-10" ] && [ "$osArchitecture" = "x86_64" ]; then
		./ci/windows.10.x86_64.sh
	elif [ "$osVersion" = "MINGW64_NT" ]; then
		./ci/windows.10.x86_64.sh
	elif [ "$osVersion" = "MSYS_NT-10" ] && [ "$osArchitecture" = "i686" ]; then
		./ci/windows.10.x86.sh
	elif [ "$osVersion" = "MINGW32_NT" ]; then
		./ci/windows.10.x86.sh
	else
		echo "Builds not yet implemented for $osVersion $osArchitecture"
		exit 1
	fi
else
	echo "Unable to determine build system"
	exit 1
fi

export OPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR"
export BOOST_ROOT="$BOOST_ROOT"

export DEVELOPER_LOCAL_TOOLS=1

# If OS is MacOS
if [ -x "$(command -v sw_vers)" ]; then
  make release-static-mac-x86_64

# If OS is Linux
elif [ -x "$(command -v lsb_release)" ]; then
  make release-static-linux-x86_64

# If OS is Windows
elif [ -x "$(command -v uname)" ]; then
  make release-static-win64
fi