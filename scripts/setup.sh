#!/usr/bin/bash

SECRET_NAME="$1"

if [[ !  -n ${SECRET_NAME} ]]; then
    echo "Usage: ./setup.sh <SECRET_NAME>"
    exit 1
fi

DIRNAME=$(dirname ${BASH_SOURCE[0]})
CMD=$(${DIRNAME}/authenticate.py ${SECRET_NAME})

eval ${CMD}
