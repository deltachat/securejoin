#!/usr/bin/env sh
set -e
python -m venv --upgrade-deps venv
. ./venv/bin/activate
pip install -r requirements.txt
sphinx-build -M html source build
