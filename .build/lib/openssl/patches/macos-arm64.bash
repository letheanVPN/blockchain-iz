#!/usr/bin/env bash

arm64CompileTarget() {
  cp -f .build/lib/openssl/patches/files/10-main.conf "${OPENSSL_SRC_DIR}/Configurations/10-main.conf"
  printf "Applied Mac ARM Patches\n"

}


arm64CompileTarget