gcc ./pyflowsom.c $(python-config --cflags) -shared -o pyflowsom.so

echo "### build.sh finished ###"