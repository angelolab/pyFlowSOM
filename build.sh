set -e
set -o pipefail

echo "### build.sh starting ###"

if [ ! -d "./.pyflowsom-venv" ]; then
    python3 -m venv .pyflowsom-venv
    pip install --upgrade pip
fi

source ./.pyflowsom-venv/bin/activate

pip install .

echo "### build.sh finished ###"