#!/bin/bash
set -e

check_consume_directory() {
    [ -z "$PAPERLESS_CONSUME" ] && return

    if [ ! -d "$PAPERLESS_CONSUME" ]; then
        mkdir -p "$PAPERLESS_CONSUME"
    fi
}

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

set_permissions() {
    chown -Rh paperless:paperless /usr/src/paperless
    if [ ! -z "$PAPERLESS_CONSUME" ]; then
        chown -Rh paperless:paperless "$PAPERLESS_CONSUME"
    fi
}

initialize() {
    check_consume_directory
    map_uidgid
    set_permissions
}

install_languages() {
    local langs="$1"
    read -ra langs <<<"$langs"

    # Check that it is not empty
    if [ ${#langs[@]} -eq 0 ]; then
        return
    fi

    # Update apt-lists
    apt-get update

    # Loop over languages to be installed
    for lang in "${langs[@]}"; do
        pkg="tesseract-ocr-$lang"
        if dpkg -s "$pkg" 2>&1 > /dev/null; then
            continue
        fi

        if ! apt-cache show "$pkg" 2>&1 > /dev/null; then
            continue
        fi

        apt-get install "$pkg"
    done

    # Remove apt lists
    rm -rf /var/lib/apt/lists/*
}


if [[ "$1" != "/"* ]]; then
    initialize

    # Install additional languages if specified
    if [ ! -z "$PAPERLESS_LANGUAGES"  ]; then
        install_languages "$PAPERLESS_LANGUAGES"
    fi

    exec sudo -HEu paperless "/usr/src/paperless/src/manage.py" "$@"
fi

exec "$@"

