# Minikube controlling library.

# Variables.
# Is minikube cluster was deployed?
MINIKUBE_CLUSTER_DEPLOYED=0
# Local cluster pods subnet.
MINIKUBE_CLUSTER_PODS_SUBNET="172.20.0.1/16"
# Minikube's VM IP.
MINIKUBE_VM_IP=""

#####################################################################
# Launches OS-specific routing adding function.
#####################################################################
function minikube_add_routes() {
    logger_log 1 "Adding routes to minikube's cluster..."
    if [ "${OS}" == "Darwin" ]; then
        _minikube_add_routes_macos
    elif [ "${OS}" == "Linux" ]; then
        _minikube_add_routes_linux
    fi
}

#####################################################################
# Deploys minikube cluster.
#####################################################################
function minikube_deploy() {
    logger_log 0 "Deploying minikube cluster..."
    common_execute minikube start --vm-driver virtualbox --cpus 2 --memory 4096 --disk-size 50g --docker-opt "bip=${MINIKUBE_CLUSTER_PODS_SUBNET}"
}

#####################################################################
# Checks if minikube cluster is deployed. If yes and it's stopped
# this function will launch it and set variable that prevents
# re-deploying.
#####################################################################
function minikube_check_if_minikube_cluster_is_deployed() {
    logger_log 0 "Checking if minikube cluster was deployed..."

    local status=$(minikube status | head -n 1 | cut -d ":" -f 2)
    logger_log 2 "\tStatus: '${status}'"
    if [[ ${#status} > 1 ]]; then
        logger_log 0 "\tMinikube cluster was successfully deployed. Will reuse it."
        MINIKUBE_CLUSTER_DEPLOYED=1
        if [ "${status/Stopped//}" != "${status}" ]; then
            logger_log 1 "Minikube's cluster stopped, starting it..."
            minikube start
        fi
    else
        logger_log 0 "\tMinikube cluster wasn't deployed, will deploy with following settings:"
        logger_log 0 "\t\tCPU: 2 cores"
        logger_log 0 "\t\tRAM: 4096mb"
        logger_log 0 "\t\tHDD: 50gb"
    fi
}

#####################################################################
# Gets minikube's cluster IP address.
#####################################################################
function minikube_get_ip() {
    MINIKUBE_VM_IP=$(minikube ip)
    logger_log 2 "Minikube's VM IP: ${MINIKUBE_VM_IP}"
    if [[ ${#MINIKUBE_VM_IP} == 0 ]]; then
        logger_error 0 "Cannot determine minikube's kubernetes cluster IP address!"
        exit 6
    fi
}

#####################################################################
# As we cannot be sure that sudo will be installed and correctly
# configured this function will show route adding command for Linux.
#####################################################################
function _minikube_add_routes_linux() {
    minikube_get_ip
    logger_log 0 "Execute these commands as root:"
    echo "ip route add ${MINIKUBE_CLUSTER_PODS_SUBNET} via ${MINIKUBE_VM_IP}"
}

#####################################################################
# Adds route on macOS.
#####################################################################
function _minikube_add_routes_macos() {
    minikube_get_ip
    common_execute sudo route add ${MINIKUBE_CLUSTER_PODS_SUBNET} ${MINIKUBE_VM_IP}
}