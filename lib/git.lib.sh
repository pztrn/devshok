# Git helper library.

#####################################################################
# Gets sources for application's configuration via Git.
#####################################################################
function git_get() {
    local app=$1
    local url=$2
    local CACHEDIR="${HOME}/.cache/devshok/${app}"
    logger_log 1 "Getting kubernetes-related sources for ${app} from ${url}..."
    if [ ! -d "${CACHEDIR}" ]; then
        logger_log 2 "Cache directory '${CACHEDIR}' doesn't exist, creating..."
        mkdir -p "${CACHEDIR}"
    fi

    cd "${CACHEDIR}"

    if [ ! -d "${CACHEDIR}/.git" ]; then
        common_execute git clone ${url} .
    else
        common_execute git pull
    fi
}