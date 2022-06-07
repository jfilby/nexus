if [ -z "$1" ]; then
  echo "Specify a program to compile."
  exit 1
fi

echo "Compiling.."
nim $NIM_COMPILE_OPTIONS c programs/$1.nim

mv programs/$1 bin

