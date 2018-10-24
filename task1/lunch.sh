set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
echo "Copying task1 resources..."
mv ${OPSLAUNCH_DIR}/docker-opsmanager4.0 ${OPSLAUNCH_DIR}/docker-opsmanager4.0.bak
cp -R docker-opsmanager4.0 "${OPSLAUNCH_DIR}/"
mkdir -p /tmp/omworkshop/bin/
echo "Place an ops manager 4.0.x deb file under /tmp/omworkshop/bin/ and press Enter ... Control+C to abort"
read next
OPSLAUNCH_BASE=`dirname $OPSLAUNCH_DIR`

opslaunch --deploy --opsmgr_bin /tmp/omworkshop/bin/mongodb-mms_4.0.*.deb --machine_name task1-om && \
apiKey=`jq -r '.apiKey' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/task1-om/out1.json`
groupId=`jq -r '.id' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/task1-om/out2.json`
echo "################# Initial excersize instructions: #####"
echo "Adding '192.168.99.1' IP for Public API ..."
sleep 10
curl -u opslaunch@example.com:${apiKey} --digest -H "Content-Type: application/json"  -X PUT \"http://192.168.99.100:8080/api/public/v1.0/groups/${groupId}/automationConfig --data '@config.json'
echo "Once done start the excersize...If you succeded you should know the Primary RESIDENT MEMORY number... Good luck!"
mv ${OPSLAUNCH_DIR}/docker-opsmanager4.0.bak ${OPSLAUNCH_DIR}/docker-opsmanager4.0
