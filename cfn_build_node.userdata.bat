:: start on Z:\ drive
cd /d Z:\
call cinst git.install
set PATH=%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin
setx PATH "%PATH%;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin" /m
call git clone https://github.com/mapbox/node-cpp11 Z:\node-cpp11
call Z:\node-cpp11\windows\install.bat

