set -x

# determine build version
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
		echo "CI: builds not yet implemented for macOS version $macOSVersion"
	fi
elif [ -x "$(command -v lsb_release)" ]; then
	ubuntuVersion=`lsb_release --release --short`
	ubuntuArchitecture=`uname -i`
	ubuntuScript="./ci/ubuntu.$ubuntuVersion.$ubuntuArchitecture.sh"
	if [ -f $ubuntuScript ]; then
		$ubuntuScript $1
	else
		echo "CI: builds not yet implemented for Ubuntu version $ubuntuVersion $ubuntuArchitecture"
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
		echo "CI: builds not yet implemented for $osVersion $osArchitecture"
	fi
else
	echo "CI: unable to determine build system"
fi
