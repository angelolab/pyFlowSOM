set -e
set -o pipefail

echo "### test.sh starting ###"

source ./.pyflowsom-venv/bin/activate

python ./pyflowsom_test.py

echo "### test.sh finished ###"