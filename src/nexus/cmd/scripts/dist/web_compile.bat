@echo off
echo.

if "%~1"=="" (
  echo Specify a web program to compile.
  echo This program is expected to be under view\web_app, don't specify the .nim extension
  echo e.g. web_compile web_app
) else (
  del bin\%1.exe

  echo Compiling..
  nim --path:.. --path:"%NEXUS_CORE_SRC_PATH%" %NIM_COMPILE_OPTIONS% c view\web_app\%1.nim

  move view\web_app\%1.exe bin
)

echo.

