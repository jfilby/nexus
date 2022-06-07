@echo off
echo.

if "%~1"=="" (
  echo Specify a program to compile.
  echo This program is expected to be under programs, don't specify the .nim extension
  echo e.g. compile tests
) else (
  del bin\%1.exe

  echo Compiling..
  nim --path:.. %NIM_COMPILE_OPTIONS% c programs/%1.nim

  move programs\%1.exe bin
)

echo.

