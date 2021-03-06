set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

abort() {
  printf "\033[31mError: $@\033[0m\n" && echo "For usage details and installation prerequisties please see : https://github.com/10gen/scripts-and-snippets/tree/master/OpsManager/opslaunch" && exit 1
}

check_dependencies() {
   which vboxwebsrv > /dev/null  || abort "virtualbox is required"
   which mlaunch > /dev/null || abort "mlaunch is required please install from https://github.com/rueckstiess/mtools or pip install mlaunch"
   which docker-machine > /dev/null || abort "docker-machine is required https://docs.docker.com/machine/ for mac clients can be installed via docker-toolbox"
   which docker-compose > /dev/null || abort "docker-compose is required https://docs.docker.com/compose/ for mac clients can be installed via docker-toolbox"
   touch test.txt && sed -i 's///g' test.txt > /dev/null || abort "gnu-sed is required - brew install coreutils ; brew install gnu-sed"
   rm -f test.txt
   which jq > /dev/null ||  abort "jq is required -- brew install jq"
   pip show pymongo > /dev/null 2>&1 || abort "pymongo is required. pip install pymongo"
   which opslaunch > /dev/null || abort "opslaunch is not installed. To install run: \"sudo python setup.py install\" from the opslaunch directory"
}

check_dependencies && echo "Dependencies satistfied..."

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
opslaunch --remove --dir ../task2/data
echo "Copying task3 resources..."
mv ${OPSLAUNCH_DIR}/docker-opsmanager4.0 ${OPSLAUNCH_DIR}/docker-opsmanager4.0.bak
cp -R docker-opsmanager4.0 "${OPSLAUNCH_DIR}/"
chmod  -R +x "${OPSLAUNCH_DIR}/docker-opsmanager4.0/"
mkdir -p /tmp/omworkshop/bin/
echo "Place an ops manager 4.0.x deb file under /tmp/omworkshop/bin/ and press Enter ... Control+C to abort"
read next
OPSLAUNCH_BASE=`dirname $OPSLAUNCH_DIR`
MACHINE_NAME=task3-om
opslaunch --deploy --opsmgr_bin /tmp/omworkshop/bin/mongodb-mms_4.0.*.deb --machine_name $MACHINE_NAME && \
apiKey=`jq -r '.apiKey' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/$MACHINE_NAME/out1.json`
groupId=`jq -r '.id' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/$MACHINE_NAME/out2.json`
echo "################# Initial exercise instructions: #####"
echo "Adding '192.168.99.1' IP for Public API ..."
sleep 10

#echo "Once done start the exercise... Once Finished please input the data size the deployment... Good luck!"
curl -u opslaunch@example.com:${apiKey} --digest \
 --header 'Accept: application/json' \
 --header 'Content-Type: application/json' \
 --include \
 --request PUT http://`docker-machine ip task3-om`:8080/api/public/v1.0/admin/backup/daemon/configs/opsmanager/%2Fvar%2Flib%2Fmongodb%2Fbackup%2F?pretty=true \
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
 --request POST http:/`docker-machine ip task3-om`:8080/api/public/v1.0/admin/backup/snapshot/mongoConfigs?pretty=true \
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
--request POST http://`docker-machine ip task3-om`:8080/api/public/v1.0/admin/backup/oplog/mongoConfigs?pretty=true \
--data '{
 "assignmentEnabled" : true,
 "id" : "oplogstore",
 "encryptedCredentials" : false,
 "uri" : "mongodb://blockstore1:27018,blockstore2:27018,blockstore3:27018"
}' && \
curl -u opslaunch@example.com:${apiKey} --digest -H "Content-Type: application/json"  -X PUT http://`docker-machine ip task3-om`:8080/api/public/v1.0/groups/${groupId}/automationConfig --data '@config1.json'
echo "Once done start the exercise... Once Finished please input the backup file size of the replica set... Good luck!"
echo "Hint: To ssh into the servers, from this directory (`pwd`) run \"opslaunch ssh --server <SERVER_NAME>\""
rm -rf ${OPSLAUNCH_DIR}/docker-opsmanager4.0
mv ${OPSLAUNCH_DIR}/docker-opsmanager4.0.bak ${OPSLAUNCH_DIR}/docker-opsmanager4.0
