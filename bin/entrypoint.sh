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
