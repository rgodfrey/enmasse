#!/bin/bash

# This script is for deploying EnMasse into Kubernetes. The target of
# installation can be an existing Kubernetes deployment or an all-in-one
# container can be started.
#
# In either case, access to the `kubectl` command is required.
#
# example usage:
#
#    $ deploy-kubernetes.sh -c 10.0.1.100 -l
#
# this will deploy EnMasse into the Kubernetes master running at 10.0.1.100
# and apply the external load balancer support for Azure, AWS etc.  For further
# parameters please see the help text.

if which kubectl &> /dev/null
then :
else
    echo "Cannot find oc command, please check path to ensure it is installed"
    exit 1
fi

SCRIPTDIR=`dirname $0`
TEMPLATE_PARAMS=""
ENMASSE_TEMPLATE=$SCRIPTDIR/kubernetes/enmasse.yaml
DEFAULT_NAMESPACE=enmasse
GUIDE=false

while getopts dgk:lm:n:s:t:vh opt; do
    case $opt in
        d)
            ALLINONE=true
            ;;
        g)
            GUIDE=true
            ;;
        k)
            SERVER_KEY=$OPTARG
            ;;
        l)
            EXTERNAL_LB=true
            ;;
        m)
            MASTER_URI=$OPTARG
            ;;
        n)
            NAMESPACE=$OPTARG
            ;;
        s)
            SERVER_CERT=$OPTARG
            ;;
        t)
            ALT_TEMPLATE=$OPTARG
            ;;
        v)
            set -x
            ;;
        h)
            echo "usage: deploy-kubernetes.sh [options]"
            echo
            echo "deploy the EnMasse suite into a running Kubernetes cluster"
            echo
            echo "optional arguments:"
            echo "  -h             show this help message"
            echo "  -d             create an all-in-one minikube VM on localhost"
            echo "  -k KEY         Server key file (default: none)"
            echo "  -m MASTER      Kubernetes master URI to login against (default: https://localhost:8443)"
            echo "  -n NAMESPACE   Namespace to deploy EnMasse into (default: $DEFAULT_NAMESPACE)"
            echo "  -o HOSTNAME    Custom hostname for messaging endpoint (default: use autogenerated from template)"
            echo "  -s CERT        Server certificate file (default: none)"
            echo "  -t TEMPLATE    An alternative Kubernetes template file to deploy EnMasse"
            echo
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit
            ;;
    esac
done

source $SCRIPTDIR/common.sh

if [ -z "$NAMESPACE" ]
then
    NAMESPACE=$DEFAULT_NAMESPACE
fi

if [ -n "$ALLINONE" ]
then
    if [ -n "$MASTER_URI" ]
    then
        echo "Error: You have requested an all-in-one deployment AND specified a cluster address."
        echo "Please choose one of these options and restart."
        exit 1
    fi
    runcmd "minikube start" "Start local minikube cluster"
fi

runcmd "kubectl create sa enmasse-service-account -n $NAMESPACE" "Create service account for address controller"

if [ -n "$SERVER_KEY" ] && [ -n "$SERVER_CERT" ]
then
    runcmd "kubectl secret new ${NAMESPACE}-certs ${SERVER_CERT} ${SERVER_KEY} -n $NAMESPACE" "Create certificate secret"
    runcmd "kubectl secret add serviceaccount/default secrets/${PROJECT}-certs --for=mount -n $NAMESPACE" "Add certificate secret to default service account"
    TEMPLATE_PARAMS="INSTANCE_CERT_SECRET=${PROJECT}-certs ${TEMPLATE_PARAMS}"
fi

if [ -n "$ALT_TEMPLATE" ]
then
    ENMASSE_TEMPLATE=$ALT_TEMPLATE
fi

runcmd "kubectl apply -f $ENMASSE_TEMPLATE -n $NAMESPACE" "Deploy EnMasse to $NAMESPACE"

if [ "$EXTERNAL_LB" == "true" ]
then
    runcmd "kubectl apply -f kubernetes/addons/external-lb.yaml"
fi
