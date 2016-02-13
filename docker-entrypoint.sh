#!/bin/bash
set -e

# Source: https://github.com/sameersbn/docker-gitlab/
map_uidgid() {
    USERMAP_ORIG_UID=$(id -u paperless)
    USERMAP_ORIG_UID=$(id -g paperless)
    USERMAP_GID=${USERMAP_GID:-${USERMAP_UID:-$USERMAP_ORIG_GID}}
    USERMAP_UID=${USERMAP_UID:-$USERMAP_ORIG_UID}
    if [[ ${USERMAP_UID} != ${USERMAP_ORIG_UID} || ${USERMAP_GID} != ${USERMAP_ORIG_GID} ]]; then
        echo "Mapping UID and GID for paperless:paperless to $USERMAP_UID:$USERMAP_GID"
        groupmod -g ${USERMAP_GID} paperless
        sed -i -e "s|:${USERMAP_ORIG_UID}:${USERMAP_GID}:|:${USERMAP_UID}:${USERMAP_GID}:|" /etc/passwd
    fi
}

check_consume_directory() {
    if [ ! -d "$PAPERLESS_CONSUME" ]; then
        mkdir -p "$PAPERLESS_CONSUME"
    fi
}

set_permissions() {
    chown -Rh paperless:paperless /usr/src/paperless
    chown -Rh paperless:paperless "$PAPERLESS_CONSUME"
}

initialize() {
    check_consume_directory
    map_uidgid
    set_permissions
}

initialize


if [[ "$1" != "/"* ]]; then
    exec sudo -HEu paperless "/usr/src/paperless/src/manage.py" "$@"
fi

exec "$@"

