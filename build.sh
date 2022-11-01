set -e
set -o pipefail

echo "### build.sh starting ###"

if [ ! -d "./.pyflowsom-venv" ]; then
    python3 -m venv .pyflowsom-venv
    pip install --upgrade pip setuptools wheel
    pip install --editable .[tests]
fi

source ./.pyflowsom-venv/bin/activate

python setup.py develop

echo "### build.sh finished ###"