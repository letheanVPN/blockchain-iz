
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Switch to PowerShell
SHELL [ "powershell", "-command" ]

# Copy and install 7z
ADD http://www.7-zip.org/a/7z1604-x64.exe c:\\7zsetup.exe
RUN Start-Process C:\7zsetup -ArgumentList '/S /D=c:/7zip' -Wait

# Copy and install msys2 
# helper_script will install it later.
ADD http://repo.msys2.org/distrib/msys2-x86_64-latest.tar.xz C:\\msys2-x86_64-latest.tar.xz
#Copy helper_script.bat itself into container
ADD helper_script.bat C:\\helper_script.bat

RUN C:\\7zip\\7z.exe e C:\\msys2-x86_64-latest.tar.xz -o"C:\\" -Y
RUN C:\\7zip\\7z.exe x C:\\msys2-x86_64-latest.tar -o"C:\\" -Y

SHELL [ "C:\\msys64\\usr\\bin\\bash.exe" ,"--login", "-c" ]


RUN cmd /c C:\helper_script.bat

RUN "/c/msys64/usr/bin/pacman -Syy git mingw-w64-x86_64-toolchain mingw-w64-x86_64-make mingw-w64-x86_64-graphviz mingw-w64-x86_64-doxygen cmake make mingw-w64-x86_64-boost openssl-devel --noconfirm"

ENV MSYSTEM MINGW64

RUN "git clone https://gitlab.com/lethean.io/blockchain/cli --branch feature/windows-build --single-branch /c/cli"
RUN "mkdir -p /c/cli/build/release"

SHELL [ "powershell", "-command" ]
WORKDIR C:\\cli\\build\\release

RUN C:\\msys64\\usr\\bin\\cmake -G "MSYS Makefiles" -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=../../cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=c:/msys64 ../.. 
RUN C:\\msys64\\usr\\bin\\make -j4

