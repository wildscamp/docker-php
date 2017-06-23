#!/bin/bash

typeset script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "$script_dir/timezone"

# Set timezone in container
_set_timezone "${TIMEZONE}"

# Set DocumentRoot to VOLUME_PATH
sed -i "s|\${VOLUME_PATH}|${VOLUME_PATH}|g" ${APACHE_CONFDIR}/apache2.conf

# Make sure xdebug is going to send events back to the correct IP.
sed -i "s/xdebug.remote_host=.*/xdebug.remote_host=${XDEBUG_REMOTE_HOST}/" $PHP_INI_DIR/conf.d/xdebug.ini

# Set the Apache2 ServerName to the hostname of the container
# echo "ServerName `hostname`" > ${APACHE_CONFDIR}/conf-available/set-hostname.conf
a2enconf set-hostname > /dev/null

# set appropriate permissions
chown -R root:staff ${CERTIFICATE_PATH}
chmod -R 775 ${CERTIFICATE_PATH}
chown -R www-data:www-data "${VOLUME_PATH}"

exec "$@"
