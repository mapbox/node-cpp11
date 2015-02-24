@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )
IF "%S3_URL%"=="" ( echo "S3_URL variable not set" && GOTO DONE )

ECHO NODE_VERSION: %NODE_VERSION%
ECHO NAME: %NAME%
ECHO BRANCH: %BRANCH%
ECHO BUILDPLATFORM: %BUILDPLATFORM%
ECHO BUILD_TYPE: %BUILD_TYPE%
ECHO ROOTDIR: %ROOTDIR%
ECHO S3_URL: %S3_URL%

SET PUB=0
IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)

ECHO using %NODE_VERSION%

cd %PKGDIR%
if NOT EXIST node-v%NODE_VERSION%-%BUILDPLATFORM% (
    git clone https://github.com/mapbox/node.git -b %BRANCH% node-v%NODE_VERSION%-%BUILDPLATFORM%
)

cd node-v%NODE_VERSION%-%BUILDPLATFORM%
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
IF %BUILDPLATFORM% EQU x64 (SET ARCHPATH=x64/)

call aws s3 cp --acl public-read %BUILD_TYPE%\node.exe %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.lib %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.exp %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\node.pdb %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\openssl-cli.exe %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read %BUILD_TYPE%\openssl-cli.pdb %S3_URL%/v%NODE_VERSION%/%ARCHPATH%
::IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
