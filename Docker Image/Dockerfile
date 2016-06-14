FROM php:5.6-apache

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
	libmcrypt-dev \
    zlib1g-dev \
    telnet \
    git \
  && rm -rf /var/lib/apt/lists/*

COPY bin/* /usr/local/bin/

# Setup bare-minimum extra extensions for Laravel & others
RUN docker-php-ext-install mbstring mcrypt zip \
	&& docker-php-pecl-install xdebug \
	&& rm ${PHP_INI_DIR}/conf.d/docker-php-pecl-xdebug.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
	--install-dir=/usr/local/bin \
	--filename=composer

# You can use this to enable xdebug. start-apache2 script will enable xdebug
# if PHP_XDEBUG is set to 1
ENV PHP_XDEBUG 0
ENV PHP_TIMEZONE "UTC"
ENV VOLUME_PATH /var/www/html
VOLUME ${VOLUME_PATH}

# Setup apache
RUN a2enmod rewrite

# Copy configs
COPY xdebug.ini ${PHP_INI_DIR}/conf.d/docker-php-pecl-xdebug.ini.disabled


EXPOSE 80
ENTRYPOINT ["setup-container"]
CMD ["apache2-foreground"]