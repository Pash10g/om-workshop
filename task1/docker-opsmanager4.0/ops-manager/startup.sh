#!/usr/bin/env sh

echo "Stalling for MongoDB"
while true; do
    nc -q 1 database1 27017 >/dev/null && break
done

##echo "Stalling for LDAP"
##while true; do
##    nc -q 1 ldap 389 >/dev/null && break
##done

sleep 10

/usr/bin/supervisord
