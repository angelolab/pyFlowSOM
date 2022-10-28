set -e
set -o pipefail

echo "### build.sh starting ###"

if [ ! -d "./.pyflowsom-venv" ]; then
    python3 -m venv .pyflowsom-venv
    pip install --upgrade pip setuptools wheel
fi

source ./.pyflowsom-venv/bin/activate

pip install .[tests]

echo "### build.sh finished ###"