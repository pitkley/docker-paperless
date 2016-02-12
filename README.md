# Paperless Docker container

[Docker Hub](https://hub.docker.com/r/pitkley/paperless/).
See sample `docker-compose.yml`.

This README is very bare right now, to be extended.

## Setup

(This assumes the sample `docker-compose.yml`, adapt as needed.)

1. Create and start:
    `docker-compose up -d`

1. Create the superuser interactively (adapt `paperless_data_1` to your situation):
    `docker run --rm -it --volumes-from paperless_data_1 pitkley/paperless createsuperuser`

1. Connect and test

