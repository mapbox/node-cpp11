:: install deps
cinst wget
cinst 7zip
cinst curl
cinst cmake
cinst awscli
SET PATH=%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip
setx PATH "%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip" /m
PATH
call wget --no-check-certificate -q https://www.python.org/ftp/python/2.7.8/python-2.7.8.amd64.msi
call msiexec /quiet /i python-2.7.8.amd64.msi

:: build
cd Z:\node-cpp11
call .\windows\settings.bat 64 14 release 1> Z:\build1.log 2>&1
call .\windows\build_node.bat 1> Z:\build2.log 2>&1

