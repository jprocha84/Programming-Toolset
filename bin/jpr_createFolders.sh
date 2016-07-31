#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR="$( dirname "${DIR}" )"

python "${DIR}/scripts/create_folders.py" $PWD
