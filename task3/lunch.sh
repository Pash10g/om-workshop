set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
opslaunch --remove --dir ../task2/data
echo "Copying task3 resources..."
cp -R docker-opsmanager4.0 "${OPSLAUNCH_DIR}/"
mkdir -p /tmp/omworkshop/bin/
echo "Place an ops manager 4.0.x deb file under /tmp/omworkshop/bin/ and press Enter ... Control+C to abort"
read next
OPSLAUNCH_BASE=`dirname $OPSLAUNCH_DIR`
MACHINE_NAME=task3-om
opslaunch --deploy --opsmgr_bin /tmp/omworkshop/bin/mongodb-mms_4.0.*.deb --machine_name $MACHINE_NAME && \
apiKey=`jq -r '.apiKey' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/$MACHINE_NAME/out1.json`
groupId=`jq -r '.id' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/$MACHINE_NAME/out2.json`
echo "################# Initial excersize instructions: #####"
echo "Login via the details above & Place '192.168.99.1' IP in the public API entry (Top right corner admin user > account > Public API Settings), once done press enter..."
echo "Press enter to proceed launching the environment...Control+C to abort"
read next

#echo "Once done start the excersize... Once Finished please input the data size the deployment... Good luck!"
curl -u opslaunch@example.com:${apiKey} --digest \
 --header 'Accept: application/json' \
 --header 'Content-Type: application/json' \
 --include \
 --request PUT http://192.168.99.100:8080/api/public/v1.0/admin/backup/daemon/configs/opsmanager/%2Fvar%2Flib%2Fmongodb%2Fbackup%2F?pretty=true \
--data '{
   "configured" : true,
   "machine" : {
     "headRootDirectory" : "/var/lib/mongodb/backup/",
     "machine" : "opsmanager"
   }
 }' && \
 curl -u opslaunch@example.com:${apiKey} --digest \
 --header 'Accept: application/json' \
 --header 'Content-Type: application/json' \
 --include \
 --request POST http://192.168.99.100:8080/api/public/v1.0/admin/backup/snapshot/mongoConfigs?pretty=true \
 --data '{
  "assignmentEnabled" : false,
  "id" : "blockstore",
  "encryptedCredentials" : false,
  "uri" : "mongodb://blockstore1:27018,blockstore2:27018,blockstore3:27018"
}' && \
curl -u opslaunch@example.com:${apiKey} --digest \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--include \
--request POST http://192.168.99.100:8080/api/public/v1.0/admin/backup/oplog/mongoConfigs?pretty=true \
--data '{
 "assignmentEnabled" : true,
 "id" : "oplogstore",
 "encryptedCredentials" : false,
 "uri" : "mongodb://blockstore1:27018,blockstore2:27018,blockstore3:27018"
}' && \
curl -u opslaunch@example.com:${apiKey} --digest -H "Content-Type: application/json"  -X PUT http://192.168.99.100:8080/api/public/v1.0/groups/${groupId}/automationConfig --data '@config1.json'
echo "Once done start the excersize... Once Finished please input the backup file size of the replica set... Good luck!"
