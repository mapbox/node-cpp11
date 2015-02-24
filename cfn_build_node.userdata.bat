:: start on Z:\ drive
cd /d Z:\
echo step 1a > state.txt
aws s3 cp --acl public-read state.txt %S3_URL%/v%NODE_VERSION%/logs/state.txt
START /B cinst -y git.install > git-install.log
echo step 1b > state.txt
echo step 1c | aws s3 cp --acl public-read - %S3_URL%/v%NODE_VERSION%/logs/state.txt
timeout 30
:: https://github.com/mapbox/node-cpp11/issues/20#issuecomment-75631535
call TaskKill /IM git.installinstall.exe /F
call TaskKill /IM git.installinstall.tmp /F
echo step 1d | aws s3 cp --acl public-read - %S3_URL%/v%NODE_VERSION%/logs/state.txt
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin
setx PATH "%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin" /m
call git clone https://github.com/mapbox/node-cpp11 Z:\node-cpp11
call Z:\node-cpp11\windows\install.bat

