FROM php:7.1.5-apache
MAINTAINER Joel Rowley <joel.rowley@wilds.org>

LABEL vendor="The Wilds" \
      org.wilds.docker-php.version="3.0.0"

RUN apt-get -qq update && apt-get -qq install \
        libcurl3-dev \
        curl \
        git \
        libmcrypt-dev \
        rsync \
        ssmtp \
        telnet \
        vim \
        libpng-dev \
        libjpeg-dev \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

COPY bin/* /usr/local/bin/

RUN pecl install xdebug \
    && docker-php-ext-install gd json mysqli \
    && docker-php-ext-enable xdebug

RUN a2enmod rewrite \
    && chmod -R +x /usr/local/bin/



ENV   CONFD_PATH=$PHP_INI_DIR/conf.d \
      APACHE_CONFDIR=/etc/apache2 \
      TIMEZONE='America/New_York' \
      VOLUME_PATH=/var/www/html \
      CERTIFICATE_PATH=/usr/local/share/ca-certificates \
      TERM=xterm

ENV APACHE_ENVVARS=$APACHE_CONFDIR/envvars

# Copy custom ini modules
COPY mods-available/*.ini $CONFD_PATH/

RUN ln -s $(which php) /usr/local/bin/php71

EXPOSE 80

WORKDIR ${VOLUME_PATH}

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]