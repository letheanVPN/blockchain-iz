
REM This file is neccessary to set up MSYS2 environment in container.

C:\msys64\usr\bin\bash  -c "/c/msys64/usr/bin/pacman-key --init"
C:\msys64\usr\bin\bash  -c "/c/msys64/usr/bin/pacman-key --refresh-keys"
C:\msys64\usr\bin\bash  -c "/c/msys64/usr/bin/pacman-key --populate msys2"
