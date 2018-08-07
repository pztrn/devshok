# Common actions library.

#####################################################################
# This function prints command that will be executed to log and
# execute it.
#####################################################################
function common_execute() {
    local cmd=$@
    logger_log 2 "Executing command: ${cmd}"
    ${cmd}
    if [ $? -ne 0 ]; then
        logger_error 0 "Command '${cmd}': execution failed, exit code $?"
    else
        logger_log 2 "Command executed successfully"
    fi
}

#####################################################################
# This function sets current date to "CURRENT_DATE" variable, that
# can be used by other modules.
#####################################################################
function common_get_date()
{
    CURRENT_DATE=`date +'%Y/%m/%d %H:%M:%S'`
}

#####################################################################
# This function responsible for loading other parts of DevSHOK.
#####################################################################
function common_load()
{
    local what=$1
    logger_log 2 "Loading shell file: '${what}'"
    source "${what}"
    if [ $? -ne 0 ]; then
        logger_error 0 "Failed to load '${what}'!"
        exit 1
    fi

}
