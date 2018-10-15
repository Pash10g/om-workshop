#!/usr/bin/env sh

echo "Stalling for MongoDB"
while true; do
    nc -q 1 database1 27017 >/dev/null && break
done

##echo "Stalling for LDAP"
##while true; do
##    nc -q 1 ldap 389 >/dev/null && break
##done

cd /opt/mongodb/mms/mongodb-releases

curl -OL http://downloads.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-4.0.0.tgz

chown mongodb-mms:mongodb-mms mongodb-linux-x86_64-ubuntu1604-4.0.0.tgz



sleep 10

/usr/bin/supervisord
