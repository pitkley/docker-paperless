FROM python:3.6-alpine3.6

ENV PAPERLESS_COMMIT=af4623e60563f5e4328e87ec8027f79804f8d08a \
    PAPERLESS_CONSUMPTION_DIR=/consume \
    PAPERLESS_EXPORT_DIR=/export

COPY musl-find_library.patch /tmp/musl-find_library.patch
COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh

RUN \
    # Add edge repositories
    echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    # Install dependencies
    && apk add --no-cache --virtual .build-deps \
        gcc \
        git \
        libjpeg-turbo-dev \
        musl-dev \
        zlib-dev \
    && apk add --no-cache \
        bash \
        ghostscript@edge \
        gnupg \
        imagemagick@edge \
        libmagic \
        sudo \
        tesseract-ocr@edge \
        unpaper@edge \
    # Patch `ctypes.util.find_library`
    && patch -p1 /usr/local/lib/python3.6/ctypes/util.py /tmp/musl-find_library.patch \
    # Clone and install paperless
    && mkdir -p /usr/src/paperless \
    && git clone https://github.com/danielquinn/paperless.git /usr/src/paperless \
    && (cd /usr/src/paperless && git checkout -q $PAPERLESS_COMMIT) \
    && (cd /usr/src/paperless && pip install --no-cache-dir -r requirements.txt) \
    # Disable `DEBUG`
    && sed -i 's/DEBUG = True/DEBUG = False/' /usr/src/paperless/src/paperless/settings.py \
    # Create consumption and export directory
    && mkdir -p $PAPERLESS_CONSUMPTION_DIR \
    && mkdir -p $PAPERLESS_EXPORT_DIR \
    # Migrate database
    && (cd /usr/src/paperless/src && ./manage.py migrate) \
    # Create user
    && addgroup -g 1000 paperless \
    && adduser -D -u 1000 -G paperless -h /usr/src/paperless paperless \
    && chown -Rh paperless:paperless /usr/src/paperless \
    # Setup entrypoint
    #&& cp /usr/src/paperless/scripts/docker-entrypoint.sh /sbin/docker-entrypoint.sh \
    && chmod 755 /sbin/docker-entrypoint.sh \
    # Remove build dependencies
    && apk del --force .build-deps

WORKDIR /usr/src/paperless/src

# Mount volumes
VOLUME ["/usr/src/paperless/data", "/usr/src/paperless/media", "/consume", "/export"]

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
CMD ["--help"]
