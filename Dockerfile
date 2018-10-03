FROM php:7.1-apache-jessie
MAINTAINER Joel Rowley <joel.rowley@wilds.org>

LABEL vendor="The Wilds" \
      org.wilds.docker-php.version="3.1.1"

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
        libmemcached-dev \
        python \
        python-pip \
		&& pip install -U pip setuptools \
		&& apt-get -qq install \
        libffi-dev \
        libssl-dev \
        openssl \
		&& python -m easy_install --upgrade pyOpenSSL \
		&& pip install idna==2.5 certbot-dns-route53 \
		&& apt remove --purge -y libffi-dev libssl-dev \
		&& apt-get clean \
		&& apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

RUN pecl install xdebug memcached \
    && docker-php-ext-install gd json mysqli \
    && docker-php-ext-enable xdebug memcached

COPY bin/* /usr/local/bin/

ADD apache-conf/set-hostname.conf /etc/apache2/conf-available/
ADD apache-conf/default-ssl.conf /etc/apache2/sites-available/

RUN a2enmod rewrite ssl \
    && chmod -R +x /usr/local/bin/ \
    && ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

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
