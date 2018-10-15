#!/usr/bin/env sh

echo "Stalling for OpsManager"
while true; do
    nc -q 1 opsmanager 8080 >/dev/null && break
done


## SSL Key generation
cd /etc/mongodb/ssl
myhostname=`hostname`
openssl req -new -newkey rsa:2048 -days 365 -keyout member.key -out member.csr -subj "/C=AU/ST=New South Wales/L=Sydney/O=MongoDB/OU=member/CN=${myhostname}/emailAddress=opslaunch@example.com" -nodes
echo "keyUsage=digitalSignature" >> extensions.txt
echo "extendedKeyUsage=clientAuth, serverAuth" >> extensions.txt
openssl x509 -req -in member.csr -CA root.crt -CAkey root.key -CAcreateserial -out member.crt -extfile extensions.txt
cat member.crt member.key > mongodb.pem
chmod 600 mongodb.pem
cd -

curl -OL http://opsmanager:8080/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.deb

dpkg -i mongodb-mms-automation-agent-manager_latest_amd64.deb

mkdir -p /data

service rsyslog start

if [ "`hostname`" = "server1" ]; then
  chown -R root:root /data
else
  chown -R mongodb:mongodb /data
fi

sudo -u mongodb  /opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent --config=/data/automation-agent.config 2>&1 >> /var/log/mongodb-mms-automation/agent.log
