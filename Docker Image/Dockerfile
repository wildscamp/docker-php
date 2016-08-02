FROM debian:jessie
MAINTAINER Joel Rowley <joel.rowley@wilds.org>

# Adapted and modified from the following files:
#   - https://github.com/splattael/docker-debian-php/blob/master/jessie/Dockerfile
#   - https://github.com/docker-library/php/blob/f016f5dc420e7d360f7381eb014ac6697e247e11/5.6/apache/Dockerfile

ENV RELEASE_DATE 2016-07-28
ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get -qq update && \
  apt-get -qq install \
    apache2 php5 php5-cli ssmtp libapache2-mod-php5 php5-mysql php5-json php5-curl php5-gd \
    php5-xdebug libmcrypt-dev zlib1g-dev telnet git curl vim && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV MODS_AVAILABLE_PATH /etc/php5/mods-available
ENV CONFD_PATH /etc/php5/apache2/conf.d

# Copy custom ini modules
COPY mods-available/*.ini ${MODS_AVAILABLE_PATH}/

# Enable different module settings
RUN php5enmod xdebug

# Make sure opcache is disabled
RUN php5dismod opcache

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
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
	&& a2enconf docker-php

# Enable mod_rewrite
RUN a2enmod rewrite

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
	--install-dir=/usr/local/bin \
	--filename=composer

# Add a symbolic link to PHP that is the same as the web host.
# This is primarily for CLI php scripts run inside the container.
RUN ln -s $(which php) /usr/local/bin/php56

COPY bin/* /usr/local/bin/

ENV TIMEZONE 'America/New_York'

ENV VOLUME_PATH /var/www/html
ENV CERTIFICATE_PATH /usr/local/share/ca-certificates

VOLUME ${VOLUME_PATH}
VOLUME ${CERTIFICATE_PATH}

WORKDIR ${VOLUME_PATH}

EXPOSE 80

ENTRYPOINT ["setup-container"]
CMD ["apache2-foreground"]