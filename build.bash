#!/bin/bash
# shellcheck shell=bash

archType=null
osName=null
osVersion=null
buildScript=null
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

}

configureHostSettings() {

  echo "Testing your host to try and figure out if we can build."
  echo "$(lsb_release -a)"

  # macos setup
  if [ -x "$(command -v sw_vers)" ]; then
    osName="macos"
    osVersion=$(sw_vers -productVersion)
    osVersion="${osVersion%.*}"
    archType="$(uname -m)"

    if [ "${archType}" = "x86_64" ]; then
      if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "MacOS M1 - Rosetta 2 - Forcing Intel"
        archType='x86_64'
      else
        echo "Native Intel"
        archType='x86_64'
      fi
    elif [ "${archType}" = "arm64" ]; then
      echo "${archType}"
      archType="arm64"
    else
      echo "Unknown architecture: ${archType} on ${osVersion}, also, I dont know why you would ever see this error."
      echo "Please report it! contact@lethean.io or https://discord.lt.hn"
      exit 1
    fi

    buildScript="os-$osVersion-arch-$archType.bash"

  # Pi4 Model B	
  elif [ "$(lsb_release -sd)" == "Raspbian GNU/Linux 10 (buster)" ]; then

    osName='raspbian'
    processorType='armv8'
    archType="$(arch)"
    buildScript="$processorType-$archType.bash"


  # Linux setup
  elif [ -x "$(command -v lsb_release)" ]; then

    osName='linux'
    processorType=$(uname -p)
    archType=$(uname -i)
    buildScript="cpu-$processorType-arch-$archType.bash"


  # Windows setup
  elif [ -x "$(command -v uname)" ]; then
    osName='windows'
    osVersion=$(expr substr $(uname -s) 1 10)
    archType=$(uname -m)

    buildScript="$osVersion-arch-$archType.bash"

  fi

  export archType osName osVersion buildScript
}

configureBuildSettings() {

  git describe --tags --exact-match 2>/dev/null
  if [ $? -eq 0 ]; then
    BUILD_VERSION=$(git describe --tags --exact-match)
  else
    BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    BUILD_COMMIT=$(git rev-parse --short HEAD)
    BUILD_VERSION="$BUILD_BRANCH-$BUILD_COMMIT"
  fi
  BUILD_VERSION=${BUILD_VERSION//\//-}
  export BUILD_VERSION

  export OPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR"
  export BOOST_ROOT="$BOOST_ROOT"

  export DEVELOPER_LOCAL_TOOLS=1
}

configureEnvironment() {
  if [ -f ".build/environment/$osName/$buildScript" ]; then

    if [ "$osName" = "macos" ] && [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
      echo "Configure is running intel compat"
      /usr/bin/env arch -x86_64 bash ".build/environment/$osName/${buildScript}" "$1"
    else
      bash ".build/environment/$osName/${buildScript}" "$1"
    fi
    echo "Removing Lib Source Files, build/libs now has openssl and libboost. use make clean, it will keep them."
    rm -rf build/libs/src/arm build/libs/src/x86_64

  else
    echo "Sorry, the builder cant auto compile for you. Please tell us the name of the preloader we tried to use: "
    echo ".build/environment/$osName/${buildScript:?}"
    echo "Sorry I can't help you right now, you can try to compile yourself or use our pre compiled binaries."
    exit 1
  fi
}

startCompile() {

  # If OS is MacOS
  if [ "$osName" = "macos" ]; then
    if [ "$archType" = "i386" ] && [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
      echo "MacOS M1 (Rosetta 2) Compile"
      make release-static-mac-x86_64
    elif [ "$archType" = "arm64" ]; then
      echo "MacOS M1(arm64) Compile"
      make release-static-mac-arm64
    elif [ "$archType" = "x86_64" ]; then
      echo "MacOS Intel(x86_64) Compile"
      make release-static-mac-x86_64
    fi
  # If OS is Linux
  elif [ "$osName" = "linux" ]; then
    echo "Performing Linux x86_64 Compile"
    make release-static-linux-x86_64

  # If OS is Linux
  elif [ "$osName" = "raspbian" ]; then
    echo "Performing Raspbian 10 armv8-a Compile"
    make release-static-rasbian-armv8


  # If OS is Windows
  elif [ "$osName" = "windows" ]; then
    echo "Performing Windows 64 Compile"
    make release-static-win64
  fi

}

buildRelease() {

  # If OS is MacOS
  if [ "$osName" = "macos" ]; then
    if [ "$archType" = "i386" ] && [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
      echo "MacOS M1 (Rosetta 2) Compile"
#      make release-static-macos-x86_64
    elif [ "$archType" = "arm64" ]; then
      echo "MacOS M1(arm64) Compile"
#      make release-static-macos-arm64
    elif [ "$archType" = "x86_64" ]; then
      echo "MacOS Intel(x86_64) Compile"
#      make release-static-macos-x86_64
    fi
  # If OS is Linux
  elif [ "$osName" = "linux" ]; then
    echo "Performing Release Compile. Linux, Mac & FreeBSD"
    make release-static

  # If OS is Windows
  elif [ "$osName" = "windows" ]; then
    echo "Performing Windows 64 Compile"
#    make release-static-win64
  fi

}

while getopts qdrt: option; do
  # shellcheck disable=SC2220
  case "${option}" in
  q) QUIET=${OPTARG} ;;
  d) DEPS_ONLY=1 ;;
  r) BUILD_RELEASE=1 ;;
  t) BUILD_TARGET=${OPTARG} ;;
  esac
done

printWelcome

configureHostSettings "${@}"

configureEnvironment "${@}"

configureBuildSettings "${@}"

# We only want a dependency check, stop now
if [ -n "$DEPS_ONLY" ]; then
  echo "Dependencies have been installed. Option -d was used, exiting without compiling the code"
  exit 0
fi

if [ -n "$BUILD_TARGET" ]; then
  make "$BUILD_TARGET"
elif [ -n "$BUILD_RELEASE" ]; then
  buildRelease "${@}"
else
  startCompile "${@}"
fi
