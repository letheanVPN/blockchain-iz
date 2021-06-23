@echo off
echo Installing MingW 64, please pick the default options.
echo Version: 7.3.0
echo Architecture: x86_64
echo Threads: posix
echo Exception: seh
pause
%cd%\.build\environment\windows\mingw-w64-install.exe
pause

echo Great, now we can build... Some windows will pop up and leave.
echo Dont do anything with them, hit enter and wait, there will be another pause

CALL C:\\msys64\msys2_shell.cmd -mingw64 -here -defterm -shell bash -l -c "pacman -Syuu"
pause
CALL C:\\msys64\msys2_shell.cmd -mingw64 -here -defterm -shell bash -l -c "pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake"

echo "Ok, that is the build environment ready. This will be the last time you have to do this."
pause

CALL C:\\msys64\msys2_shell.cmd -mingw64 -here -defterm -shell bash -l -c "make release-static-win64"

echo If we didnt have an error, you can find the files in the build/release folder.
pause