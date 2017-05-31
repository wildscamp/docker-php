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

# Copy custom ini modules
COPY mods-available/*.ini $PHP_INI_DIR/conf.d/

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]