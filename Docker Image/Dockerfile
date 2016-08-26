FROM debian:jessie
MAINTAINER Joel Rowley <joel.rowley@wilds.org>

LABEL vendor="The Wilds" \
      org.wilds.docker-wpdevenvironment.version="2.1.0"

# Adapted and modified from the following files:
#   - https://github.com/splattael/docker-debian-php/blob/master/jessie/Dockerfile
#   - https://github.com/docker-library/php/blob/f016f5dc420e7d360f7381eb014ac6697e247e11/5.6/apache/Dockerfile

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get -qq update && apt-get -qq install \
    apache2 \
    curl \
    git \
    libapache2-mod-php5 \
    libmcrypt-dev \
    php5 \
    php5-cli \
    php5-curl \
    php5-gd \
    php5-json \
    php5-mysql \
    php5-xdebug \
    rsync \
    ssmtp \
    telnet \
    vim \
    zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV MODS_AVAILABLE_PATH=/etc/php5/mods-available \
    CONFD_PATH=/etc/php5/apache2/conf.d \
    APACHE_CONFDIR=/etc/apache2 \
    XDEBUG_REMOTE_HOST=10.0.75.1 \
    TIMEZONE='America/New_York' \
    VOLUME_PATH=/var/www/html \
    CERTIFICATE_PATH=/usr/local/share/ca-certificates \
    TERM=xterm

ENV APACHE_ENVVARS=$APACHE_CONFDIR/envvars

RUN set -e \

    # logs should go to stdout / stderr
    && . "$APACHE_ENVVARS" \
    && ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log" \

    # PHP files should be handled by PHP, and should be preferred over any other file type
    && { \

        echo '<FilesMatch \.php$>'; \
        echo '\tSetHandler application/x-httpd-php'; \
        echo '</FilesMatch>'; \
        echo; \
#		echo 'DirectoryIndex disabled'; \
        echo 'DirectoryIndex index.php index.html'; \
        echo; \
        echo '<Directory /var/www/>'; \
        echo '\tOptions -Indexes'; \
        echo '\tAllowOverride All'; \
        echo '</Directory>'; \
    } | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
    && a2enconf docker-php \

	# Add a symbolic link to PHP that is the same as the web host.
    # This is primarily for CLI php scripts run inside the container.
	&& ln -s $(which php) /usr/local/bin/php56

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

COPY bin/* /usr/local/bin/

# Copy custom ini modules
COPY mods-available/*.ini ${MODS_AVAILABLE_PATH}/

# Enable different module settings
RUN php5enmod xdebug # enable xdebug settings \
    && php5dismod opcache # disable opcache \
    && a2enmod rewrite # enable mod_rewrite

WORKDIR ${VOLUME_PATH}

EXPOSE 80

ENTRYPOINT ["setup-container"]
CMD ["apache2-foreground"]