# Docker Apache + PHP Server

![Docker Logo](https://www.gravatar.com/avatar/def8e498c0e2b4d1b0cb398ca164cddd?s=115) ![The Wilds Logo](https://www.gravatar.com/avatar/731d4f0ca8553a4f4b2a4f35d1d72280?s=115)

**Note:** The primary use case of this container is as part of a local development
environment. Because of that, we would not recommend using this container in a production
environment.

This container implements an Apache + PHP server. The reason we created this from
[debian:jesse](https://hub.docker.com/_/debian/) instead of basing it off the
[official php container](https://hub.docker.com/_/php/) is because there is a
[bug in the official container in relation to Xdebug](https://github.com/docker-library/php/issues/133).
The `php5` library from `apt-get` does not have that problem, so this container uses that
version of PHP.

The compiled versions of this container can be found in the
[Docker registry](https://hub.docker.com/r/wildscamp/php/).

Features
----
* Apache2 + PHP server
* Xdebug enabled with session cookie
* Ability to debug static variable references. See [official php container issue](https://github.com/docker-library/php/issues/133).
* Apache access logs redirected to `STDOUT`

Environment variables
----

This image uses environment variables to allow the configuration of some parameters at run time:

`TIMEZONE`

* **Description:** Set the timezone inside the container. 
* **Default:** `America/New_York`

----

`VOLUME_PATH`

* **Description:** The path of the folder that's served up by Apache.
* **Default:** `/var/www/html`

----

`XDEBUG_REMOTE_HOST`

* **Description:** The DNS name or IP address of the computer where Xdebug events should
  be sent when debugging is enabled via the cookie or query string. See
  [Xdebug's docs](https://xdebug.org/docs/remote) about how to enable debugging.
* **Default:** `10.0.75.1`. This is the standard `vEthernet (DockerNAT)` interface IP address
  in the Docker for Windows implementation.

_Common Values_

| Environment        | IP             | Comment                   |
|--------------------|----------------|---------------------------|
| Docker for Windows | 10.0.75.1      | Default Hyper-V host IP   |
| boot2docker        | 192.168.99.100 | Default docker-machine IP |

_Caveats_

* If this is set incorrectly, Xdebug events will not make it to the Xdebug client that
  is listening for them.
* You most likely will need to open up port `9000` on the Xdebug client computer or the
  Xdebug client computer's firewall will likely block this traffic.

----

`TERM`

* **Description:** Tell the container what type of terminal you're using for displaying
  the output from the container.
* **Default:** `xterm`

Volumes
----
There are no official volumes in this container. However, here are some recommended locations
to attach volumes.

* `/var/www/html` - The path from which Apache serves up files.
* `/usr/local/share/ca-certificates` - Used for adding SSL certificates to the container.

### Named Data Volumes
Folders that are mounted [directly from the host computer](https://docs.docker.com/engine/tutorials/dockervolumes/#/mount-a-host-directory-as-a-data-volume)
are much slower than [named data volumes](https://docs.docker.com/engine/reference/commandline/volume_create/).
While not a requirement, we definitely recommend storing your application data in a named
volume. In our (unscientific) tests, switching to using named data volumes made requests
that were taking 4 seconds to respond (with volumes shared from the host computer) drop to
under 1 second with named data volumes.

Ports
----

* `80` inbound - Apache listens on this port.
* `TCP 9000` outbound - Xdebug events are sent from the container to the address defined
  by the `XDEBUG_REMOTE_HOST` environment variable. This does not need to be opened in the
  Docker firewall. However, this port may need to be opened on the inbound firewall of the
  computer that is receiving the Xdebug events.

Examples
----

1) Start the container serving up files in a named volume.

```bash
docker run --rm -v html-data:/var/www/html \
    -t wildscamp/php
```

2) Start the container serving up files in a named volume but sending Xdebug events to
   `192.168.99.100`.

```bash
docker run --rm -v html-data:/var/www/html \
    -e "XDEBUG_REMOTE_HOST=192.168.99.100" \
    -t wildscamp/php
```

3) Get a bash prompt into an already running container named `www-server`.

```bash
docker run -d --name www-server -v html-data:/var/www/html \
    -t wildscamp/php

docker exec -it www-server /bin/bash
```

4) Setting up in a docker-compose.yml. Full sample [here](https://github.com/wildscamp/docker-localphpenvironment/blob/master/docker-compose.yml).

```yaml
services:
  mysql:
    # Mysql container definition

  wordpress:
    container_name: wordpress
    image: wildscamp/php
    hostname: wordpress
    environment:
      - TIMEZONE=America/New_York
      - XDEBUG_REMOTE_HOST=10.0.75.1
    ports:
      - "80:80"
    working_dir: /var/www/html
    volumes:
      - docker-html:/var/www/html
      - docker-certificates:/usr/local/share/ca-certificates
    links:
      - mysql:db
    restart: on-failure
```