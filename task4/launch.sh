set -e
set -o pipefail

OPSLAUNCH_SCRIPT=`readlink /usr/local/bin/opslaunch`

OPSLAUNCH_DIR=`dirname $OPSLAUNCH_SCRIPT`

opslaunch --remove --dir ../task3/data

echo "Found opslaunch location : ${OPSLAUNCH_DIR}"
echo "No deployment for this task :) ... Perhaps the `pwd`/diagnostics.zip file can help. "
echo "Once completed please input the required change to be provided to the customer (hint: answer format <PROPERTY>:<VALUE>=><PROPERTY>:<VALUE>... Good luck!"
echo "Hint: you can use the 00389925 case for https://proactive.corp.mongodb.com/diagnostics"
