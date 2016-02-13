FROM python:3.5.1
MAINTAINER Pit Kleyersburg <pitkley@googlemail.com>

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        tesseract-ocr tesseract-ocr-eng imagemagick ghostscript \
    && rm -rf /var/lib/apt/lists/*

# Clone and install paperless
ENV PAPERLESS_COMMIT 68fa7d68fa519f175cabb09a369a727b09af1051
RUN mkdir -p /usr/src/paperless \
    && git clone https://github.com/danielquinn/paperless.git /usr/src/paperless \
    && (cd /usr/src/paperless && git checkout -q $PAPERLESS_COMMIT) \
    && (cd /usr/src/paperless && pip install -r requirements.txt)

# Migrate database
WORKDIR /usr/src/paperless/src
RUN ./manage.py migrate

# Create user
RUN groupadd -g 1000 paperless \
    && useradd -u 1000 -g 1000 -d /usr/src/paperless paperless \
    && chown -Rh paperless:paperless /usr/src/paperless

# Setup entrypoint
COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh
RUN chmod 755 /sbin/docker-entrypoint.sh

# Mount volumes
VOLUME ["/usr/src/paperless/data", "/usr/src/paperless/media"]

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
CMD ["--help"]
