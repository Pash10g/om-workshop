set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
echo "Copying task1 resources..."
cp -R docker-opsmanager4.0 "${OPSLAUNCH_DIR}/"

OPSLAUNCH_BASE=`dirname $OPSLAUNCH_DIR`

${OPSLAUNCH_BASE}/quick_start.sh && \
apiKey=`jq -r '.apiKey' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/task1-om/out1.json`
groupId=`jq -r '.id' ${OPSLAUNCH_DIR}/docker-opsmanager4.0/task1-om/out2.json`
echo "################# Initial excersize instructions: #####"
echo "Place '192.168.99.1' IP in the public API entry (Top right corner admin user > account > Public API Settings)"
echo "Run the following command : curl -u opslaunch@example.com:${apiKey} --digest -H \"Content-Type: application/json\"  -X PUT \"http://192.168.99.100:8080/api/public/v1.0/groups/${groupId}/automationConfig\" --data '@config.json'"
echo "Once done start the excersize... Good luck!"
