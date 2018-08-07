# Logger library.

# Debug messages array.
DEBUG_MESSAGES=("\033[1;32mINFO     \033[1;m" "\033[1;36mDEBUG    \033[1;m" "\033[1;31mHARDDEBUG\033[1;m")

# Colorize messages depending on verbosity level.
VERB_LVL_COLORS=("\033[1;m" "\033[1;33m" "\033[1;35m")

# Formatted message will be placed in this variable.
FORMATTED_MESSAGE=""

# We are defaulting our DEBUG level to 1.
# This value can be overriden with prepending "DEBUG=1" while launching
# this script.
# DEBUG_LEVEL will be taken from configuration.
if [ -z ${DEBUG_LEVEL} ]; then
    DEBUG_LEVEL=1
fi

if [ -z ${DEBUG} ]; then
    DEBUG=1
fi

#####################################################################
# This function checks for debug level and returns 1 or 0:
#   - 0: this debug level is okay to be printed.
#   - 1: this debug level should not be printed.
#####################################################################
function logger_check_debug() {
    local DEBUG_LVL=$1

    if [ ${DEBUG_LVL} -le ${DEBUG} ]; then
        return 0
    else
        return 1
    fi
}

#####################################################################
# Error logging function.
#####################################################################
function logger_error() {
    common_get_date
    
    local level=$1
    shift
    local message=$@
    
    logger_error_common ${level} "${message}"
    if [ $? -eq 0 ]; then
        echo -e "[${CURRENT_DATE}][\033[1;31mERROR\033[1;m    ] ${FORMATTED_MESSAGE}\033[1;m"
    fi
}

#####################################################################
# Same as logger_log_common()
#####################################################################
function logger_error_common() {
    # Executes some common things for logs.
    local DEBUG_LVL=$1
    local MESSAGE=$2

    logger_check_debug ${DEBUG_LVL}
    if [ $? -ne 0 ]; then
        return 1
    fi

    # All ok, printing...
    FORMATTED_MESSAGE="\033[1;31m${MESSAGE}\033[1;m"
    return 0
}

#####################################################################
# Logging function of logger.
#####################################################################
function logger_log() {
    common_get_date
    
    local level=$1
    shift
    local message=$@
    
    logger_log_common ${level} "${message}"
    if [ $? -eq 0 ]; then
        echo -e "[${CURRENT_DATE}]${FORMATTED_MESSAGE}\033[1;m"
    fi
}

#####################################################################
# This function performs checking of debug level (with help of
# logger_check_debug()), and preformats message for later printing.
#####################################################################
function logger_log_common() {
    # Executes some common things for logs.
    local DEBUG_LVL=$1
    shift
    local MESSAGE=$@

    logger_check_debug ${DEBUG_LVL}
    if [ $? -ne 0 ]; then
        return 1
    fi

    # All ok, printing...
    FORMATTED_MESSAGE="[${DEBUG_MESSAGES[${DEBUG_LVL}]}] ${VERB_LVL_COLORS[${level}]}${MESSAGE}${VERB_LVL_COLORS[0]}"
    return 0
}

#####################################################################
# This function asks user some question.
#####################################################################
function logger_question()
{
    local answers=$1
    local question=$2
    answers=`echo ${answers} | sed -e 's/\(.\)/\1\n/g'`
    
    common_get_date
    
    variants=""
    
    idx=0
    for item in ${answers}; do
        if [ ${idx} -eq 0 ]; then
            QUESTION_DEFAULT=${item}
            item=`echo ${item} | awk {' print toupper($0) '}`
        fi
        variants="${variants}/${item}"
        idx=$[ ${idx} + 1 ]
    done
        
    echo -ne "[${CURRENT_DATE}][${DEBUG_MESSAGES[${DEBUG_LVL}]}] ${VERB_LVL_COLORS[${level}]}${question} [${variants:1}]${VERB_LVL_COLORS[0]} "
    read QUESTION_ANSWER
}

#####################################################################
# This function compares user input with passed string.
# Useful for previous function.
#####################################################################
function logger_compare_input()
{
    local required=`echo $1 | awk {' print tolower($0) '}`
    local default=`echo ${QUESTION_DEFAULT} | awk {' print tolower($0) '}`
    if [ "${default}" == "${required}" -o "${QUESTION_ANSWER}" == "" ]; then
        if [ "${QUESTION_ANSWER}" == "${required}" -o "${QUESTION_ANSWER}" == "" ]; then
            logger_log 2 "Answer (or empty answer) matched with required"
            QUESTION_RESULT=0
        else
            logger_log 2 "Answer (or empty answer) NOT matched with required"
            QUESTION_RESULT=1
        fi
    else
        if [ "${QUESTION_ANSWER}" == "${required}" ]; then
            logger_log 2 "Answer matched with required"
            QUESTION_RESULT=0
        else
            logger_log 2 "Answer NOT matched with required"
            QUESTION_RESULT=1
        fi
    fi
}
