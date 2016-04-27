#!/bin/sh

set -e

for i in {30..0}; do
    if [ -f "/data/ssl/dh4096.pem" ]; then 
        break
    fi
    sleep 1
done
if [ "$i" = 0 ]; then
    echo "* initalizing certificate"    
    mkdir /data/ssl
    ./gencert.sh /data/ssl/
    openssl dhparam -dsaparam -out /data/ssl/dh4096.pem 4096    
fi

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
    if [ ! -f /etc/dovecot/private/dovecot.pem ] && [ -e /data/ssl/server.key ]; then
        mkdir /etc/dovecot/private 2> /dev/null
        ln -s /data/ssl/server.key /etc/dovecot/private/dovecot.pem 2> /dev/null
    fi  
    if [ ! -f /etc/dovecot/dovecot.pem ] && [ -e /data/ssl/server.crt ]; then
        ln -s /data/ssl/server.crt /etc/dovecot/dovecot.pem 2> /dev/null
    fi

    if [ ! -f "/etc/dovecot/configured" ]; then
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD >> /etc/dovecot/dovecot-sql.conf.ext
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD >> /etc/dovecot/dovecot-dict-sql.conf.ext
        touch /etc/dovecot/configured
    fi
fi

exec "$@"