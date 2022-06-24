#!/bin/bash

typeset script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "$script_dir/timezone"

# Set timezone in container
_set_timezone "${TIMEZONE}"

# Set DocumentRoot to VOLUME_PATH
sed -i "s|\${VOLUME_PATH}|${VOLUME_PATH}|g" ${APACHE_CONFDIR}/apache2.conf

# This is to enable legacy support for the XDEBUG_REMOTE_HOST env variable
if [[ -v XDEBUG_REMOTE_HOST ]]; then
  XDEBUG_CLIENT_HOST=$XDEBUG_REMOTE_HOST
fi

# Make sure xdebug is going to send events back to the correct IP.
if [[ -v XDEBUG_CLIENT_HOST ]]; then
	sed -i "s/xdebug.client_host=.*/xdebug.client_host=${XDEBUG_CLIENT_HOST}/" $PHP_INI_DIR/conf.d/xdebug.ini
fi

# Make sure xdebug is going to send events back to the correct IP.
if [[ -v XDEBUG_CLIENT_PORT ]]; then
	sed -i "s/xdebug.client_port=.*/xdebug.client_port=${XDEBUG_CLIENT_PORT}/" $PHP_INI_DIR/conf.d/xdebug.ini
fi

if [[ -v SSL_HOSTNAME ]]; then
  echo "ServerName $SSL_HOSTNAME" > /etc/apache2/conf-available/set-hostname.conf
fi

# Set the Apache2 ServerName to the hostname of the container
# echo "ServerName `hostname`" > ${APACHE_CONFDIR}/conf-available/set-hostname.conf
a2enconf set-hostname > /dev/null

# set appropriate permissions
chown -R root:staff ${CERTIFICATE_PATH}
chmod -R 775 ${CERTIFICATE_PATH}
setfacl -Rm g:www-data:rwX,d:g:www-data:rwX "${VOLUME_PATH}"

if [ -n "${LOG_PATH}" ] && [ -d "${LOG_PATH}" ] ; then
  setfacl -Rm g:www-data:rwX,d:g:www-data:rwX "${LOG_PATH}"
fi

until [ -f /etc/pki/tls/private/privkey.pem ]
do
    echo "Waiting 1 second for certificate file..."
    sleep 1
done

exec "$@"
