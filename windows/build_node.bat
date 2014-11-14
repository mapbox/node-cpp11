@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET PUB=0
IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)

ECHO using %NODE_VERSION%

cd %PKGDIR%
if NOT EXIST node-v%NODE_VERSION% (
    git clone https://github.com/mapbox/node.git -b v%NODE_VERSION%-nodecpp11 node-v%NODE_VERSION%
)

cd node-v%NODE_VERSION%
IF ERRORLEVEL 1 GOTO ERROR

:: clear out previous builds
if EXIST %BUILD_TYPE% (
    rd /q /s %BUILD_TYPE%
)

ECHO.
ECHO ---------------- BUILDING  NODE %NODE_VERSION% --------------

CALL vcbuild.bat %BUILD_TYPE% %BUILDPLATFORM% nosign
IF ERRORLEVEL 1 GOTO ERROR

SET ARCHPATH=
IF %BUILDPLATFORM% EQU x64 (SET ARCHPATH="x64/")

call aws s3 cp --acl public-read %BUILD_TYPE%\node.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.lib s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\openssl-cli.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\openssl-cli.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
