# Docker Apache + PHP 8.1 Server

![Docker Logo](https://www.gravatar.com/avatar/def8e498c0e2b4d1b0cb398ca164cddd?s=115) ![The Wilds Logo](https://www.gravatar.com/avatar/731d4f0ca8553a4f4b2a4f35d1d72280?s=115)

> This container is designed to be used for local development. As such, it has not been
> hardened as required for a production environment.

This container implements an Apache + PHP 8.1 server. See the list of features below to
understand what this container offers over the stock `php:<version>-apache` container.

The compiled versions of this container can be found in the
[container registry](https://github.com/wildscamp/docker-php/pkgs/container/php).

## Features

* Apache2 + PHP 8.1 server
* SSL Enabled
* Xdebug enabled with session cookie
* Apache access logs redirected to `STDOUT`
* [Composer](https://getcomposer.org/) pre-installed
* [WP-CLI](http://wp-cli.org/) pre-installed

## Environment variables

This image uses environment variables to allow the configuration of some parameters at run time:

### `TIMEZONE`

* **Description:** Set the timezone inside the container.
* **Default:** `America/New_York`

----

### `VOLUME_PATH`

* **Description:** The path of the folder that's served up by Apache.
* **Default:** `/var/www/html`

----

### `XDEBUG_REMOTE_HOST`

* **Description:** The DNS name or IP address of the computer where Xdebug events should
  be sent when debugging is enabled via the cookie or query string. See
  [Xdebug's docs](https://xdebug.org/docs/remote) about how to enable debugging.
* **Default:** `host.docker.internal`. See the
  [Docker documentation](https://docs.docker.com/docker-for-windows/networking/#use-cases-and-workarounds)
  for information regarding this DNS name.

----

### `XDEBUG_REMOTE_PORT`

* **Description:** The port of the computer where Xdebug events should
  be sent when debugging is enabled via the cookie or query string. See
  [Xdebug's docs](https://xdebug.org/docs/remote) about how to enable debugging.
* **Default:** `9003`. See the
  [Docker documentation](https://docs.docker.com/docker-for-windows/networking/#use-cases-and-workarounds)
  for information regarding this DNS name.

----

### `SERVER_HOSTNAME`

* **Description:** The hostname that Apache will assign to itself.
* **Default:** `local.dev`

#### Caveats

* If this is set incorrectly, Xdebug events will not make it to the Xdebug client that
  is listening for them.
* You most likely will need to open up TCP port `9003` on the Xdebug client computer as the
  Xdebug client computer's firewall will likely block this traffic.

----

### `TERM`

* **Description:** Tell the container what type of terminal you're using for displaying
  the output from the container.
* **Default:** `xterm`

----

### `WP_CACHE_MEMCACHED_ADDR`

* **Description:** The address and port for the memcached server.
* **Default:** Not set
* **Example:** `memcached:11211`

## Volumes

There are no official volumes in this container. However, here are some recommended locations
to attach volumes.

* `/var/www/html` - The path from which Apache serves up files.
* `/etc/pki/tls` - Used for SSL signing

## Ports

* `80` inbound - Apache listens on this port.
* `TCP 9003` outbound - If `XDEBUG_REMOTE_PORT` is defined to be something else, then that
  outbound port must be opened. Xdebug events are sent from the container to the address defined
  by the `XDEBUG_REMOTE_HOST` environment variable. This does not need to be opened in the
  Docker firewall. However, this port may need to be opened on the inbound firewall of the
  computer that is receiving the Xdebug events.

## SSL Certificates

If you are wanting to use SSL (port 443), the following certificate files must exist:

* **`/etc/pki/tls/cert/cert.pem`** - Corresponds to the Apache `SSLCertificateFile`
  file.
* **`/etc/pki/tls/private/privkey.pem`** - Corresponds to the Apache `SSLCertificateKeyFile`
  file.

## Examples

1) Start the container serving up files in a named volume.

  ```bash
  docker run --rm -v /home/jdoe/project/html:/var/www/html -v /home/jdoe/.letsencrypt:/etc/pki/tls \
      -t wildscamp/php
  ```
  
1) Start the container serving up files in a named volume but sending Xdebug events to
   `172.25.64.1`.

```bash
docker run --rm -v /home/jdoe/project/html:/var/www/html -v /home/jdoe/.letsencrypt:/etc/pki/tls \
    -e "XDEBUG_REMOTE_HOST=172.25.64.1" \
    -t wildscamp/php
```

1) Setting up in a docker-compose.yml. Full sample [here](https://github.com/wildscamp/docker-localphpdevenvironment/blob/master/docker-compose.yml).

```yaml
services:
  mysql:
    # Mysql container definition

  php:
    image: wildscamp/php
    environment:
      - TIMEZONE=America/New_York
      - XDEBUG_REMOTE_HOST=host.docker.internal
      - WP_CACHE_MEMCACHED_ADDR=memcached:11211
    ports:
      - "80:80"
      - "443:443"
    working_dir: /var/www/html
    volumes:
      - ./html:/var/www/html
      - ./certificates:/etc/pki/tls
    links:
      - mysql:db
    restart: on-failure
```
