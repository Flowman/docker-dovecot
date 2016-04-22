#!/bin/sh

set -e

while [ ! -f "/data/ssl/dh4096.pem" ]; do 
   sleep 2
done

# if command starts with an option, prepend dovecot
if [ "${1:0:1}" = '-' ]; then
    set -- dovecot "$@"
fi

if [ "$1" = 'dovecot' ]; then
    # Get config

    if [ -z "$MYSQL_HOST" -o -z "$MYSQL_USER" -o -z "$MYSQL_DATABASE" ]; then
        echo mysql arugments required
        exit 1
    fi

    # link in certs
    mkdir /etc/dovecot/private
    ln -s /data/ssl/server.crt /etc/dovecot/dovecot.pem 2> /dev/null
    ln -s /data/ssl/server.key /etc/dovecot/private/dovecot.pem 2> /dev/null

    if [ ! -f "/etc/dovecot/dovecot-configured" ]; then
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASS >> /etc/dovecot/dovecot-sql.conf.ext
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASS >> /etc/dovecot/dovecot-dict-sql.conf.ext
        touch /etc/dovecot/dovecot-configured
    fi
fi

exec "$@"