#!/bin/bash
set -e

if [[ "$1" != "/"* ]]; then
    exec "/usr/src/paperless/src/manage.py" "$@"
fi

exec "$@"

