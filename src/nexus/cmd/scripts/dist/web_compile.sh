if [ -z "$1" ]; then
  echo "Specify a web app program to compile."
  exit 1
fi

rm bin/$1

echo "Compiling.."
nim --path:.. --path:$NEXUS_CORE_SRC_PATH $NIM_COMPILE_OPTIONS c view/web_app/$1.nim

mv view/web_app/$1 bin

