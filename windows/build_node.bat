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

ECHO.
ECHO ---------------- BUILDING  NODE %NODE_VERSION% --------------

SET BUILD_TYPE=Release

:: 64 bit
CALL vcbuild.bat %BUILD_TYPE% x64 nosign
IF ERRORLEVEL 1 GOTO ERROR

call aws s3 cp --acl public-read Release\node.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.lib s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\openssl-cli.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\openssl-cli.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
IF ERRORLEVEL 1 GOTO ERROR

:: TODO - not yet working - perhaps because settings.bat creates 64 compiler env
:: clean to prepare for 32 bit build
::CALL vcbuild.bat %BUILD_TYPE% clean x64 nosign

:: 32 bit
::CALL vcbuild.bat %BUILD_TYPE% x86 nosign
::IF ERRORLEVEL 1 GOTO ERROR

call aws s3 cp --acl public-read Release\node.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.lib s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\node.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\openssl-cli.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR
call aws s3 cp --acl public-read Release\openssl-cli.pdb s3://mapbox/node-cpp11/v%NODE_VERSION%/
IF ERRORLEVEL 1 GOTO ERROR

::ECHO.
::ECHO ------------------------------------------------------------
::ECHO running tests
::ECHO ------------------------------------------------------------
::ECHO.
::CALL vcbuild %BUILD_TYPE% x%TARGET_ARCH% nosign nobuild test-uv
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
