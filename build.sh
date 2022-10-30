set -e
set -o pipefail

echo "### build.sh starting ###"

source ./.pyflowsom-venv/bin/activate

python setup.py install

echo "### build.sh finished ###"