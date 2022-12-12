set -e
set -o pipefail

echo "### build.sh starting ###"

if [ ! -d "./.pyflowsom-venv" ]; then
    python3 -m venv .pyflowsom-venv
    pip install -r requirements.txt -r requirements-test.txt
fi

source ./.pyflowsom-venv/bin/activate

pip install -ve .

echo "### build.sh finished ###"