set -e
set -o pipefail

echo "### test.sh starting ###"

source ./.pyflowsom-venv/bin/activate

python -m pytest --randomly-seed=42 --randomly-dont-reorganize --cov=pyFlowSOM --pycodestyle test

echo "### test.sh finished ###"