# Consul cluster configuration and helper functions.
# This is an example config which isn't working.

CONSUL_APPNAME="consul-example"
CONSUL_INSTALLATION_TYPE="git"
CONSUL_URL="COMPLETE_GIT_URL"

#####################################################################
# Deploy function.
#####################################################################
function consul_deploy() {
    local mode=$1
    logger_log 0 "Deploying Consul cluster (mode: ${mode})..."

    # Empty deployment mode isn't supported.
    if [ "${mode}" == "" ]; then
        logger_error 0 "Empty deployment mode isn't supported!"
        exit 11
    fi

    # Consul cluster configuration have two configurations - for local
    # deployment using minikube's cluster and remote deployment (read:
    # production deployment).
    if [ "${mode/local//}" != "${mode}" ]; then
        _consul_deploy_local
    else
        logger_error 0 "Deployment mode '${mode}' isn't supported"
        exit 10
    fi
}

#####################################################################
# Undeploy function.
#####################################################################
function consul_undeploy() {
    local mode=$1
    logger_log 0 "Undeploying Consul cluster (mode: ${mode})..."

    # Empty deployment mode isn't supported.
    if [ "${mode}" == "" ]; then
        logger_error 0 "Empty deployment mode isn't supported!"
        exit 11
    fi

    # Consul cluster configuration have two configurations - for local
    # deployment using minikube's cluster and remote deployment (read:
    # production deployment).
    if [ "${mode/local//}" != "${mode}" ]; then
        _consul_undeploy_local
    else
        logger_error 0 "Deployment mode '${mode}' isn't supported"
        exit 10
    fi
}

#####################################################################
# Local deployment.
#####################################################################
function _consul_deploy_local() {
    logger_log 1 "Starting local deployment..."

    _consul_deploy_common

    logger_log 1 "Executing local-specific deployment commands..."
    common_execute kubectl create -f statefulset-dev.yaml
}

#####################################################################
# Common deployment.
#####################################################################
function _consul_deploy_common() {
    logger_log 1 "Executing common deployment commands..."
    common_execute kubectl create configmap consul --from-file=config.json=server.json
    common_execute kubectl create -f service.yaml
}

#####################################################################
# Local undeployment.
#####################################################################
function _consul_undeploy_local() {
    logger_log 1 "Deleting local Consul cluster..."

    _consul_undeploy_common
}

#####################################################################
# Common undeployment.
#####################################################################
function _consul_undeploy_common() {
    logger_log 1 "Executing common undeploy commands..."
    common_execute kubectl delete statefulset consul
    common_execute kubectl delete pvc data-consul-0 data-consul-1 data-consul-2
    common_execute kubectl delete svc consul
    common_execute kubectl delete configmaps consul
}