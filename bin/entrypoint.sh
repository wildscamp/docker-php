#!/bin/bash

typeset script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "$script_dir/timezone"

# Set timezone in container
_set_timezone "${TIMEZONE}"

# Set DocumentRoot to VOLUME_PATH
sed -i "s|\${VOLUME_PATH}|${VOLUME_PATH}|g" ${APACHE_CONFDIR}/apache2.conf

# Make sure xdebug is going to send events back to the correct IP.
if [[ -v XDEBUG_REMOTE_HOST ]]; then
	sed -i "s/xdebug.remote_host=.*/xdebug.remote_host=${XDEBUG_REMOTE_HOST}/" $PHP_INI_DIR/conf.d/xdebug.ini
else
	sed -i "s/xdebug.remote_host=.*/xdebug.remote_host=10.0.75.1/" $PHP_INI_DIR/conf.d/xdebug.ini
fi

# Set the Apache2 ServerName to the hostname of the container
# echo "ServerName `hostname`" > ${APACHE_CONFDIR}/conf-available/set-hostname.conf
a2enconf set-hostname > /dev/null

# Setup SSL
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo "No AWS access credentials found"
    if [[ ! -f /etc/pki/tls/certs/cert.pem ]] ; then
        echo "Generating self-signed certificate"
        # Generate self-signed certificate if we can't authenticate with AWS.
        mkdir -p /etc/pki/tls/certs
        mkdir -p /etc/pki/tls/private
        openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
            -keyout /etc/pki/tls/private/privkey.pem -out /etc/pki/tls/certs/cert.pem \
            -subj "/C=US/ST=SC/L=Taylors/O=The Wilds/CN=localdev.wildsca.org"
    fi
else
    # Use a prefix if one is configured.
    if [ -z "${LOCALDEV_DOMAIN_PREFIX}" ]; then
        cert_path=/etc/letsencrypt/live/localdev.wildsca.org
    else
        cert_path=/etc/letsencrypt/live/${LOCALDEV_DOMAIN_PREFIX}.localdev.wildsca.org
    fi

    if [[ ! -f "$cert_path/fullchain.pem" ]] ; then
        echo "Getting certificate from Let'sEncrypt"

        # NOTE: The order of the domain parameters is important, as it determines the path certificates will be written to.
        if [ -z "${LOCALDEV_DOMAIN_PREFIX}" ]; then
            certbot certonly --register-unsafely-without-email --non-interactive --agree-tos --dns-route53 -d localdev.wildsca.org -d *.localdev.wildsca.org
        else
            certbot certonly --register-unsafely-without-email --non-interactive --agree-tos --dns-route53 -d *.${LOCALDEV_DOMAIN_PREFIX}.localdev.wildsca.org -d localdev.wildsca.org -d *.localdev.wildsca.org
        fi
        echo "Completed generating certificates"
    else
        certbot renew --dns-route53
    fi

    # Make sure certificates are linked correctly
    rm -f /etc/pki/tls/private/privkey.pem
    rm -f /etc/pki/tls/certs/cert.pem
    mkdir -p /etc/pki/tls/certs
    mkdir -p /etc/pki/tls/private
    ln -s "$cert_path/privkey.pem" /etc/pki/tls/private/privkey.pem
    ln -s "$cert_path/fullchain.pem" /etc/pki/tls/certs/cert.pem
fi


# set appropriate permissions
chown -R root:staff ${CERTIFICATE_PATH}
chmod -R 775 ${CERTIFICATE_PATH}
chown -R www-data:www-data "${VOLUME_PATH}"
if [ -n "${LOG_PATH}" ] && [ -d "${LOG_PATH}" ] ; then
  chown -R www-data:www-data "${LOG_PATH}"
fi

exec "$@"
