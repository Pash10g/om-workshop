set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
echo "No deployment for this task :) ... Perhaps the `pwd`/diagnostics.zip file can help. "
echo "Once completed please input the required change to be provided to the customer (hint: answer format <PROPERTY>:<VALUE>=><PROPERTY>:<VALUE>... Good luck!"
echo "Hint: To ssh into the servers, from this directory (`pwd`) run \"opslaunch ssh --server <SERVER_NAME>\""
