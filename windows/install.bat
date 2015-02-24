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
call aws s3 cp --acl public-read Z:\build1.log %S3_URL%/v%NODE_VERSION%/logs
call .\windows\build_node.bat 1> Z:\build-x64.log 2>&1
call aws s3 cp --acl public-read Z:\build-x64.log %S3_URL%/v%NODE_VERSION%/logs
call .\windows\settings.bat 32 14 release 1> Z:\build2.log 2>&1
call aws s3 cp --acl public-read Z:\build2.log %S3_URL%/v%NODE_VERSION%/logs
call .\windows\build_node.bat 1> Z:\build-x86.log 2>&1
call aws s3 cp --acl public-read Z:\build-x86.log %S3_URL%/v%NODE_VERSION%/logs

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%

:DONE

EXIT /b %EL%
