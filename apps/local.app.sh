# Local deployment application.
# This application should be used for local deployments on developer's
# machine.

common_load "${SCRIPT_PATH}/lib/minikube.lib.sh"

APP_COMMAND="local"
APP_DESCRIPTION="Executes local deployment sequence for requested services.
                This requires minikube to be installed.
        
                Available subcommands:
                    addroutes               Adds (or show a command how to add)
                                            routes to local cluster so containers
                                            will be accessible from machine.

                    getip app               Get IP for deployed application.
                                            You should specify only one application
                                            here. If several instances was
                                            deployed - random IP from these
                                            instances will be returned.
                        
                    deploy [app app ...]    Deploy applications. Configuration
                                            for these applications must exist in
                                            configs directory.
            
                    undeploy [app app ...]  Undeploy applications. Configuration
                                            for these applications must exist in
                                            configs directory."

#####################################################################
# Main application function.
#####################################################################
function app_main() {
    local opts=($@)
    logger_log 0 "Starting local deployment application..."
    logger_log 2 "Passed parameters: '${opts}'"

    minikube_check_if_minikube_cluster_is_deployed
    if [ $MINIKUBE_CLUSTER_DEPLOYED -eq 0 ]; then
        minikube_deploy
    fi

    minikube_get_ip

    # Figure out what we will do.
    local action=${opts[0]}
    logger_log 1 "Action requested for minikube's powered kubernetes: ${action}"
    if [ "${action}" == "addroutes" ]; then
        minikube_add_routes
    elif [ "${action}" == "deploy" ]; then
        shift
        local_deploy ${opts[@]:1}
    elif [ "${action}" == "getip" ]; then
        local_getip ${opts[@]:1}
    elif [ "${action}" == "undeploy" ]; then
        shift
        local_undeploy ${opts[@]:1}
    else
        logger_error 0 "Unsupported action for local kubernetes action: ${opts[0]}"
    fi
}

#####################################################################
# This function responsible for deploying applications locally.
#####################################################################
function local_deploy() {
    local apps=$@
    logger_log 0 "Apps to deploy: ${apps}"

    for app in ${apps[@]}; do
        logger_log 0 "Trying to deploy application: ${app}..."
        logger_log 0 "================================================== ${app} START"

        # Do common things.
        _local_prepare_app ${app} 1

        # Check if deploy function is present.
        # They're same for local and non-local deployments.
        local deploy_func_name="${app}_deploy"
        declare -F ${deploy_func_name} &>/dev/null
        if [ $? -ne 0 ]; then
            logger_error 0 "Application ${app} has no ${deploy_func_name} function in it's configuration file! Cannot continue."
            exit 8
        fi

        logger_log 0 "Getting kubernetes-related sources..."

        # After all checks - execute sources obtaining procedure.
        local source_url_var=$(echo "${app}_URL" | awk {' print toupper($0) '})
        local source_installation_type_var=$(echo ${app}_INSTALLATION_TYPE | awk {' print toupper($0) '})
        local sources_obtaining_func="${!source_installation_type_var}_get"
        common_load "${SCRIPT_PATH}/lib/${!source_installation_type_var}.lib.sh"
        # Check if we have such source installation type library.
        declare -F ${sources_obtaining_func} &>/dev/null
        if [ $? -ne 0 ]; then
            logger_error 0 "Unsupported installation type: '${!source_installation_type_var}' (function ${sources_obtaining_func} wasn't found!)"
            exit 9
        fi

        logger_log 1 "Deploy configuration is managed as '${!source_installation_type_var}', launching helper..."
        ${sources_obtaining_func} ${app} ${!source_url_var}

        logger_log 2 "Launching ${deploy_func_name} function..."
        ${deploy_func_name} local

        logger_log 0 "${app} deployed."
        logger_log 0 "================================================== ${app} END"
    done
}

#####################################################################
# Prints requested service's IP address.
#####################################################################
function local_getip() {
    local app=$1
    logger_log 0 "Getting IP address for application ${app}..."

    # Do common things.
    _local_prepare_app ${app} 0

    local endpoints=$(kubectl describe service ${app} | grep "Endpoints" | head -n 1 | awk {' print $2 '})
    logger_log 2 "Endpoints: ${endpoints}"

    local endpoints_count=$(echo ${endpoints} | awk -v RS=',' 'END{print NR'})
    logger_log 2 "Endpoints count: ${endpoints_count}"
    local random_endpoint_id=$(echo $[ $RANDOM % ${endpoints_count} ])
    random_endpoint_id=$[ ${random_endpoint_id} + 1 ]
    logger_log 2 "Random endpoint #${random_endpoint_id}"
    local ip=$(echo ${endpoints} | cut -d "," -f ${random_endpoint_id} | cut -d ":" -f 1)
    logger_log 0 "Endpoint IP: ${ip}"
}

#####################################################################
# Undeploys application(s).
#####################################################################
function local_undeploy() {
    local apps=$@
    logger_log 0 "Apps to undeploy: ${apps}"

    for app in ${apps[@]}; do
        logger_log 0 "Trying to undeploy application: ${app}..."
        logger_log 0 "================================================== ${app} START"

        # Do common things.
        _local_prepare_app ${app} 1

        # Check if deploy function is present.
        # They're same for local and non-local deployments.
        local undeploy_func_name="${app}_undeploy"
        declare -F ${undeploy_func_name} &>/dev/null
        if [ $? -ne 0 ]; then
            logger_error 0 "Application ${app} has no ${undeploy_func_name} function in it's configuration file! Cannot continue."
            exit 8
        fi

        logger_log 0 "Getting kubernetes-related sources..."

        # After all checks - execute sources obtaining procedure.
        local source_url_var=$(echo "${app}_URL" | awk {' print toupper($0) '})
        local source_installation_type_var=$(echo ${app}_INSTALLATION_TYPE | awk {' print toupper($0) '})
        local sources_obtaining_func="${!source_installation_type_var}_get"
        common_load "${SCRIPT_PATH}/lib/${!source_installation_type_var}.lib.sh"
        # Check if we have such source installation type library.
        declare -F ${sources_obtaining_func} &>/dev/null
        if [ $? -ne 0 ]; then
            logger_error 0 "Unsupported installation type: '${!source_installation_type_var}' (function ${sources_obtaining_func} wasn't found!)"
            exit 9
        fi

        logger_log 1 "Deploy configuration is managed as '${!source_installation_type_var}', launching helper..."
        ${sources_obtaining_func} ${app} ${!source_url_var}

        logger_log 2 "Launching ${undeploy_func_name} function..."
        ${undeploy_func_name} local

        logger_log 0 "${app} undeployed."
        logger_log 0 "================================================== ${app} END"
    done
}

#####################################################################
# Checks if application configuration exists.
#####################################################################
function _local_prepare_app() {
    local app=$1
    local continue=$2

    # Make sure that config is present.
    if [ ! -f "${SCRIPT_PATH}/configs/${app}.config.sh" ]; then
        logger_error 0 "Failed to deploy application '${app}' - no config file was found!"
        if [ ${continue} -ne 1 ]; then
            exit 12
        fi
    fi

    # Load config.
    source "${SCRIPT_PATH}/configs/${app}.config.sh"
    appnamevar=$(echo "${app}_APPNAME" | awk {' print toupper($0) '})
    logger_log 2 "Loaded configuration file for '${!appnamevar}' (this comes from ${appnamevar} variable from configuration file. If there is nothing here - then configuration file is INVALID!)"

    # Verify required variables. They're should not be empty.
    if [ "${!appnamevar}" == "" ]; then
        logger_error 0 "Configuration file for ${app} is invalid (variable ${!appnamevar} is empty)."
        exit 7
    fi
}