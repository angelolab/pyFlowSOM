set -e
set -o pipefail

echo "### build.sh starting ###"

if [ ! -d "./.pyflowsom-venv" ]; then
    python3 -m venv .pyflowsom-venv
    pip install --upgrade pip setuptools wheel
    pip install -r requirements.txt -r requirements-test.txt
fi

source ./.pyflowsom-venv/bin/activate

python setup.py develop

echo "### build.sh finished ###"