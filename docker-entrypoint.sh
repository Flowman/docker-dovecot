#!/bin/sh

set -e

for i in 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0; do
    if [ -f "/data/ssl/dh4096.pem" ]; then 
        break
    fi
    sleep 1
done
if [ "$i" = 0 ]; then
    echo "* initalizing certificate"    
    mkdir /data/ssl
    ./gencert.sh /data/ssl/
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

    # link in certs and remove alpine generated once
    rm /etc/ssl/dovecot/server.key /etc/ssl/dovecot/server.pem
    ln -s /data/ssl/server.key /etc/ssl/dovecot/server.key 2> /dev/null
    ln -s /data/ssl/server.crt /etc/ssl/dovecot/server.pem 2> /dev/null

    # set hostname for dovecot ehlo
    if [ ! -z "$HOSTNAME" ]; then
        export DOVECOT_HOSTNAME=$HOSTNAME
    fi

    if [ ! -f "/etc/dovecot/configured" ]; then
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD >> /etc/dovecot/dovecot-sql.conf.ext
        echo connect = host=$MYSQL_HOST dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD >> /etc/dovecot/dovecot-dict-sql.conf.ext
        touch /etc/dovecot/configured
    fi
fi

exec "$@"