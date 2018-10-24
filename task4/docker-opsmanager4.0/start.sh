#!/bin/bash

set -e
set -o pipefail

GREEN='\033[0;32m'
NC='\033[0m'
# Create docker deamon + opsmananager containers(blockstore+database+webserver)

printf "Starting docker VM..."
docker-machine create `head -n 1 ../cloud-driver.conf` $1 >> /dev/null || eval $(docker-machine env $1) && \
   mkdir -p ops-manager/src && \
   cp $2 ops-manager/src/mongodb-mms-server.deb && \
   { cp /usr/local/m/opsmanager-current/mongodb-mms-backup*  ops-manager/src/mongodb-mms-backup.deb 2>/dev/null || true;} && \
   eval $(docker-machine env $1) && \
   printf "${GREEN}done.${NC}\n"
   sed -i  "s#mms\.centralUrl=.*#mms\.centralUrl=http://$(docker-machine ip $1):8080#g" ./ops-manager/config/conf-mms.properties && \
   sed -i  "s#mms\.centralUrl=.*#mms\.centralUrl=http://$(docker-machine ip $1):8080#g" ./ops-manager/config/conf-deamon.properties &&  \
   printf "Building $1 OpsManager deployment (apx 10min, but it depends on the driver...) "
   if [ "$4" = "--deploy_ldap" ]; then
     docker-compose build ldap opsmanager database1 database2 database3 blockstore1 blockstore2 blockstore3 2>&1 >> /dev/null && printf "${GREEN}done.${NC}\n" && printf "Starting OpsManager deployment..." && \
     docker-compose up -d ldap opsmanager database1 database2 database3 blockstore1 blockstore2 blockstore3 2>&1 >> /dev/null
   else
      docker-compose build  opsmanager database1 database2 database3 blockstore1 blockstore2 blockstore3  2>&1 >> /dev/null && printf "${GREEN}done.${NC}\n" && printf "Starting OpsManager deployment..." && \
      docker-compose up -d  opsmanager database1 database2 database3 blockstore1 blockstore2 blockstore3 2>&1 >> /dev/null
   fi
   printf "${GREEN}done.${NC}\n" && sleep 10 && \
   docker-compose  exec  database1 mongo admin --port 27017 --eval 'rs.initiate(); while(!db.isMaster().ismaster){print ("waiting on appdb replica..."); sleep(1000);} db.createUser({ user: "opslaunch", pwd: "mongodb123", roles: [ { role: "root", db: "admin" } ] });rs.add("database2:27017");rs.add("database3:27017");' && \
   docker-compose  exec  blockstore1 mongo admin --port 27018 --eval 'rs.initiate(); while(!db.isMaster().ismaster){print ("waiting on blockstore replica..."); sleep(1000);} db.createUser({ user: "opslaunch", pwd: "mongodb123", roles: [ { role: "root", db: "admin" } ] }); rs.status(); rs.add("blockstore2:27018");rs.add("blockstore3:27018");'

   sed -i  "s#mms\.centralUrl=.*#mms\.centralUrl=http://ROUTABLE_IP:8080#g" ./ops-manager/config/conf-mms.properties && \
   sed -i  "s#mms\.centralUrl=.*#mms\.centralUrl=http://ROUTABLE_IP:8080#g" ./ops-manager/config/conf-deamon.properties && \
   #cat ./ldap/ldap/ldap-overrides.properties >> ./ops-manager/config/conf-mms.properties


printf "Waiting for Ops Manager to start (300 sec)..."
sleep 300
printf "${GREEN}done.${NC}\n"
printf "Installing automation agent..."

mkdir -p $1
base_dir=`pwd`
cd $1

if [ $(uname -s | grep Darwin) ]; then
   curl -OL --retry 5 --retry-delay 15 http://`docker-machine ip $1`:8080/download/agent/automation/mongodb-mms-automation-agent-latest.osx_x86_64.tar.gz >>/dev/null
else
   curl -OL --retry 5 --retry-delay 15 http://`docker-machine ip $1`:8080/download/agent/automation/mongodb-mms-automation-agent-latest.linux_x86_64.tar.gz >>/dev/null
fi

tar -xvf mongodb-mms-automation-agent-latest* >>/dev/null

agent_dir=$(ls -tr | tail -n 1)

cd $agent_dir
automation_path=`pwd`

cd ..


opsmanager_url="http://`docker-machine ip $1`:8080"

curl -H "Content-Type: application/json" -i -X POST "$opsmanager_url/api/public/v1.0/unauth/users" --data '
 {
   "username": "opslaunch@example.com",
   "emailAddress": "opslaunch@example.com",
   "password": "Opensaseme1.",
   "firstName": "admin",
   "lastName": "admin"
 }'  | tail -n 1 > out1.json

apiKey=`jq -r '.apiKey' out1.json`
printf "${GREEN}done.${NC}\n"

printf "Creating group 'main'..."
curl -u "opslaunch@example.com:$apiKey" -H "Content-Type: application/json" --digest -i -X POST "$opsmanager_url/api/public/v1.0/groups" --data '
{
  "name": "main"
}'  | tail -n 1 > out2.json

groupId=`jq -r '.id' out2.json`

groupApiKey=`jq -r '.agentApiKey' out2.json`

printf "Configure agent ..."
sed -i  -e "s#mmsGroupId=.*#mmsGroupId=$groupId#g" -e "s#mmsApiKey=.*#mmsApiKey=$groupApiKey#g"   $automation_path/local.config

if [ "$3" = "--deploy_nodes" ]; then
   cd $base_dir
   mkdir -p mms-automation-agent/src && \
   sed -i  -e "s#mmsBaseUrl=.*#mmsBaseUrl=http://opsmanager:8080#g" $automation_path/local.config
   cp $automation_path/local.config mms-automation-agent/src/  && \
   docker-compose build server1 server2 server3 2>&1 >> /dev/null && printf "${GREEN}done.${NC}\n" && printf "Starting OpsManager deployment..." && docker-compose up -d server1 server2 server3  >>/dev/null && \
   printf "${GREEN}done.${NC}\n"
else
   sed -i -e "s#mmsBaseUrl=.*#mmsBaseUrl=$opsmanager_url#g" $automation_path/local.config
   printf "${GREEN}done.${NC}\n"

   printf "Launching automation agent on host `hostname`..."
   echo "  kill -9 \$(ps aux | grep 'mms-automation' | grep -v 'grep' | awk '{print \$2}') 2>/dev/null " > $automation_path/../start_agent.sh
   echo "  nohup $automation_path/mongodb-mms-automation-agent --config=$automation_path/local.config >> /var/log/mongodb-mms-automation/automation-agent.log 2>&1 &" >> $automation_path/../start_agent.sh

   echo "  kill -9 \$(ps aux | grep 'mms-automation' | grep -v 'grep' | awk '{print \$2}') 2>/dev/null "  > $automation_path/../stop_agent.sh

   chmod +x $automation_path/../start_agent.sh
   chmod +x $automation_path/../stop_agent.sh

   $automation_path/../start_agent.sh
   printf "${GREEN}done.${NC}\n"
fi
#echo "Lunching Monitoring and Backup agents on host `hostname`..."
#curl -u "admin@mlaunch.com:$apiKey" --digest -i "$opsmanager_url/api/public/v1.0/groups/$groupId/automationConfig" | tail -n 1 > out3.json
#
#sed -i  -e "s#\"monitoringVersions\":\[\]#\"monitoringVersions\" : \[ {\"name\": \"latest\" , \"hostname\": \"`hostname`\",\"baseUrl\": null } \]#g"  -e "s#\"backupVersions\":\[\]#\"backupVersions\":\[ {\"name\": \"latest\" , \"hostname\": \"`hostname`\",\"baseUrl\": null } \]#g" out3.json
#
#curl -u "admin@mlaunch.com:$apiKey" -H "Content-Type: application/json" --digest -i "$opsmanager_url/api/public/v1.0/groups/$groupId/automationConfig" -X PUT --data @out3.json
docker-compose  exec  database1 mongo admin --port 27017 --eval 'db.getSiblingDB("mmsdbconfig").config.users.find().forEach(function(docs){ db.getSiblingDB("mmsdbconfig").config.userApiWhitelists.insert({ userId: docs._id, "createdAt" : ISODate("2018-10-18T11:37:40.827Z"), "ipAddress" : "192.168.99.1", "count" : 0 } ); });'
echo ""
echo "############################################################"
echo "OpsManager Version : $1 Deployed."
echo "Connect to the WEB-UI via $opsmanager_url"
echo "Username : opslaunch@example.com"
echo "Password : Passw0rd!"
echo " "
echo "Backup:"
echo "Use <hostname> : blockstore1:27018,blockstore2:27018,blockstore3:27018 for snapshot storage database when setting up the backup daemon on \"Backup\" -> \"configure the backup module\""
echo "Use <options> : ?replicaSet=bkr"
echo "Use /snapshots for Filesystem snapshot storage filesystem when setting up the backup daemon on \"Backup\" -> \"configure the backup module\""
if [ "$3" = "--deploy_nodes" ]; then
  echo " "
  echo "MongoDB SSL:"
  echo "Use the following in your security settings:"
  echo "CAFile: /etc/mongodb/ssl/rootCA.pem"
  echo "sslPEMKeyFile: /etc/mongodb/ssl/mongodb.pem"
  echo "(optional) clusterFile: /etc/mongodb/ssl/mongodb.pem"
fi
if [ "$4" = "--deploy_ldap" ]; then
  echo " "
  echo "MongoDB & OpsManager LDAP:"
  echo "Use the following in your security settings:"
  echo "LDAP Server: ldap:389"
  echo "For OM User LDAP settings go to: $opsmanager_url/v2/admin#general/setup"
  echo "For MongoDB LDAP automation settings use:"
  echo "    - Select : Native LDAP Authentication"
  echo "    - Servers: ldap"
  echo "    - Transport Security: NONE"
  echo "    - BindMethod: Simple"
  echo "    - Query User: cn=admin,dc=babypearfoo,dc=com"
  echo "    - Query Password: DontChangeMe1"
  echo "    - Authorization Query Template: {USER}?memberOf?base"
  echo "    - User to Distinguished Name Mapping: { match: \"(.+)\", ldapQuery: \"dc=babypearfoo,dc=com??sub?(uid={0})\"}"

fi
echo "############################################################"

#Luanching a browser
open $opsmanager_url
