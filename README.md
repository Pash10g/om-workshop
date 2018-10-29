# om-workshop

## Introduction

The following workshop allows you to perform hands-on issue solving with Ops Manager 4.0 environments.

There are 4 environments - each one simulates a customer issue with their Ops Manager deployment.

## Prerequisites

This exercise requires the [`opslaunch` utility](https://github.com/10gen/scripts-and-snippets/tree/master/OpsManager/opslaunch).  Please see the [INSTALL.MD](https://github.com/10gen/scripts-and-snippets/blob/master/OpsManager/opslaunch/INSTALL.md) of `opslaunch` and install it before starting this workshop.

Additionally, you will need to create the following directory and place an Ubuntu 16.04 deb file of Ops Manager 4.0 latest release. Use [MongoDB download center](https://www.mongodb.com/download-center/ops-manager/releases) to obtain this binary (please do not change its name and make sure it is the **only** file in the directory):
```
/tmp/omworkshop/bin/
```

Finally, you'll need to have Python27 installed on your Mac. Running Python3+ is not supported by opslaunch (yet).

## Workshop

Clone or download this project:
```
git clone https://github.com/Pash10g/om-workshop.git
```


Please access the following google form: https://docs.google.com/forms/d/e/1FAIpQLSc22IvyfAK_bPPMVfVZKSzB4YbiSsBACJdpEGqQp6PgsCcSgg/viewform?usp=sf_link and login with your user.

Follow the instructions on the form to complete the workshop.

Please note that each task takes about 10 minute to set up!

## Troubleshooting

1. Reset connection by peer when starting a task:
```
Starting OpsManager deployment...Creating network "dockeropsmanager40_om" with driver "bridge"
Pulling database1 (mongo:4.0)...
ERROR: error pulling image configuration: read tcp 10.0.2.15:38546->104.18.124.25:443: read: connection reset by peer
OpsManager deploymnet for version 4.0.4.50216 finished
```

**Action to resolve:** Rerun the `./launch.sh` script again from the same task directory:
EXAMPLE
```
/om-workshop/task1> ./launch.sh
```
2. The machine is unresponsive after deployment (due to mac going into sleep etc.)

**Action to resolve:** Drop the environment:
```
/om-workshop/task1>  opslaunch --remove
...
/om-workshop/task1> ./launch.sh
```

3. Getting `mv: rename scripts-and-snippets/OpsManager/opslaunch/opslaunch/docker-opsmanager4.0 to scripts-and-snippets/OpsManager/opslaunch/opslaunch/docker-opsmanager4.0.bak/docker-opsmanager4.0: Directory not empty`

**Action to resolve:** Remove the `scripts-and-snippets/OpsManager/opslaunch/opslaunch/docker-opsmanager4.0.bak/docker-opsmanager4.0` directory and try again
