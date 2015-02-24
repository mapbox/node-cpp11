@echo off
SETLOCAL
SET EL=0

:: install deps
call cinst -y wget
call cinst -y 7zip
call cinst -y curl
call cinst -y cmake
call cinst -y awscli
SET PATH=%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip
setx PATH "%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip" /m
PATH
:: TODO - does this go into C:\Python27 ?
call wget --no-check-certificate -q https://www.python.org/ftp/python/2.7.8/python-2.7.8.amd64.msi
call msiexec /quiet /i python-2.7.8.amd64.msi

:: build
cd Z:\node-cpp11
call .\windows\settings.bat 64 14 release 1> Z:\build1.log 2>&1
aws s3 cp build.log --acl public-read %S3URL%/v%NODE_VERSION%/logs/build.log
call .\windows\build_node.bat 1> Z:\build-x64.log 2>&1
aws s3 cp build-x64.log --acl public-read %S3URL%/v%NODE_VERSION%/logs/build-x64.log
call .\windows\settings.bat 32 14 release 1> Z:\build2.log 2>&1
aws s3 cp build2.log --acl public-read %S3URL%/v%NODE_VERSION%/logs/build2.log
call .\windows\build_node.bat 1> Z:\build-x86.log 2>&1
aws s3 cp build-x86.log --acl public-read %S3URL%/v%NODE_VERSION%/logs/build-x86.log

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%

:DONE

EXIT /b %EL%
