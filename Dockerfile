FROM alpine:3.7

LABEL maintainer="Pit Kleyersburg <pitkley@googlemail.com>" \
    contributors="The Paperless Project https://github.com/danielquinn/paperless, Guy Addadi <addadi@gmail.com>, Sven Fischer <git-dev@linux4tw.de>"

ENV PAPERLESS_COMMIT a8d143d4c5192a6e44d8bb0f5f44bc9ce8624915
ENV PAPERLESS_CONSUMPTION_DIR /consume
ENV PAPERLESS_EXPORT_DIR /export

RUN \
    # Install required dependencies
    apk --no-cache --update add \
        python3 gnupg libmagic bash \
        sudo poppler tesseract-ocr imagemagick ghostscript unpaper optipng \
    # Install temporary build dependencies
    && apk --no-cache add --virtual .build-dependencies \
        git python3-dev poppler-dev gcc g++ musl-dev zlib-dev jpeg-dev postgresql-dev \
    # Bootstrap pip
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    # Clone and install paperless
    && mkdir -p /usr/src/paperless \
    && (cd /usr/src/paperless \
        # Only fetch given commit
        && git init \
        && git fetch --depth=1 https://github.com/danielquinn/paperless.git "$PAPERLESS_COMMIT" \
        && git checkout -q "$PAPERLESS_COMMIT" \
        # Install requirements
        && pip3 install --no-cache-dir -r requirements.txt) \
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
    && cp /usr/src/paperless/scripts/docker-entrypoint.sh /sbin/docker-entrypoint.sh \
    && chmod 755 /sbin/docker-entrypoint.sh


WORKDIR /usr/src/paperless/src

# Mount volumes
VOLUME ["/usr/src/paperless/data", "/usr/src/paperless/media", "/consume", "/export"]

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
CMD ["--help"]
