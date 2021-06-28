@echo off

if exist "C:\msys64\msys2_shell.cmd" (
  echo msys2-x86_64 install found
) else (

bitsadmin.exe /transfer "Msys2 Download"  /download /priority FOREGROUND https://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-x86_64-20210604.exe %cd%\.build\environment\windows\msys2-x86_64-install.exe

 %cd%\.build\environment\windows\msys2-x86_64-install.exe -t C:\\msys64 --da -c install
 pause
 CALL  C:\\msys64\msys2_shell.cmd -mingw64 -here -c "pacman -Suu --noconfirm "
 pause
 CALL C:\\msys64\msys2_shell.cmd -mingw64 -here -c "pacman -Sy --noconfirm git tar mingw-w64-x86_64-icu mingw-w64-x86_64-bzip2 mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake"
 pause
)

CALL C:\\msys64\msys2_shell.cmd -mingw64 -here -c "bash build.bash"
