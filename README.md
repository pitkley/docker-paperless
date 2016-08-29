# Paperless Docker container

Docker image for [Paperless](https://github.com/danielquinn/paperless/).
See [Docker Hub](https://hub.docker.com/r/pitkley/paperless/).

This README is very bare right now, to be extended.

## Setup

(This assumes the sample `docker-compose.yml`, adapt as needed.)

1. Create and start:

       docker-compose up -d

1. Create the superuser interactively:

   ```console
   $ docker-compose run --rm webserver createsuperuser
   ```

1. Connect and test

## Map default UID and GID

If you want the user and group IDs from the default `paperless` user in the image to be different from `1000`, you can specify the `USERMAP_UID` and `USERMAP_GID` environment variables.
This can be relevant if you want to map a host-directory to be the consumption directory and want to "passthrough" the UID and GID of the host-user that should own that directory.
