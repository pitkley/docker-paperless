FROM python:3.5.1
MAINTAINER Pit Kleyersburg <pitkley@googlemail.com>

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tesseract-ocr tesseract-ocr-eng imagemagick ghostscript \
    && rm -rf /var/lib/apt/lists/*

# Clone and install paperless
ENV PAPERLESS_COMMIT 1d4b87ee46e86883b1b3d4d99c2dd60290d269ff
RUN mkdir -p /usr/src/paperless \
    && git clone https://github.com/danielquinn/paperless.git /usr/src/paperless \
    && (cd /usr/src/paperless && git checkout -q $PAPERLESS_COMMIT) \
    && (cd /usr/src/paperless && pip install -r requirements.txt)

# Migrate database
WORKDIR /usr/src/paperless/src
RUN ./manage.py migrate

# Create data-directory
RUN mkdir /data
ENV PAPERLESS_CONSUME "/data"

# Mount volumes
VOLUME ["/usr/src/paperless/data", "/data"]

# Setup entrypoint
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["--help"]
