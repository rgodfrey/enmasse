#!/bin/sh
HOST=${1:-localhost}
NAMESPACE=${2-myproject}
USER=${3-developer}

export OPENSHIFT_USER=$USER
export OPENSHIFT_TOKEN=`oc whoami -t`
export OPENSHIFT_MASTER_URL=https://${HOST}:8443
export OPENSHIFT_NAMESPACE=${NAMESPACE}
