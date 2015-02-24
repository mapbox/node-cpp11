:: start on Z:\ drive
cd /d Z:\
echo step 1a | aws s3 cp - --acl public-read %S3URL%/v%NODE_VERSION%/logs/state.txt
call cinst -y awscli
SET PATH=%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip
setx PATH "%PATH%;C:\Python27;C:\Program Files\Amazon\AWSCLI;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\7-Zip" /m
PATH
echo step 1b | aws s3 cp - --acl public-read %S3URL%/v%NODE_VERSION%/logs/state.txt
call cinst -y git.commandline
echo step 1c | aws s3 cp - --acl public-read %S3URL%/v%NODE_VERSION%/logs/state.txt
:: https://github.com/mapbox/node-cpp11/issues/20#issuecomment-75631535
::call TaskKill /IM git.installinstall.exe /F
::call TaskKill /IM git.installinstall.tmp /F
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin
setx PATH "%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin" /m
echo step 1d | aws s3 cp - --acl public-read %S3URL%/v%NODE_VERSION%/logs/state.txt
call git clone https://github.com/mapbox/node-cpp11 Z:\node-cpp11
echo step 1e | aws s3 cp - --acl public-read %S3URL%/v%NODE_VERSION%/logs/state.txt
call Z:\node-cpp11\windows\install.bat

