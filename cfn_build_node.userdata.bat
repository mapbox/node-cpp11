@echo off
:: start on Z:\ drive
cd /d Z:\

echo step 1a > state.txt
START /B cinst -y git.install > git-install.log
echo step 1b >> state.txt

call timeout 100 >> state.txt

echo step 1c >> state.txt
type git-install.log >> state.txt
:: https://github.com/mapbox/node-cpp11/issues/20#issuecomment-75631535
call TaskKill /IM git.installinstall.exe /F >> state.txt
call TaskKill /IM git.installinstall.tmp /F >> state.txt
echo step 1d >> state.txt
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin
call setx PATH "%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin" /m
call git clone https://github.com/mapbox/node-cpp11 Z:\node-cpp11 >> state.txt
call Z:\node-cpp11\windows\install.bat >> state.txt

