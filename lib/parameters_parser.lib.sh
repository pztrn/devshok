# CLI parameters parsing library.

######################################################################
# This function parses dash-params (starting with --) and exports
# them as environment variables.
# Value should be next to variable, e.g. "--with ololo", wihtout
# "="!
# "-" will be replaced with "_".
######################################################################
function paramparser_parse() {
    logger_log 1 "Parsing CLI parameters..."
    local opts=($@)

    local idx=0
    for opt in ${opts[@]}; do
        if [ "${opt/\-\-//}" != "${opt}" ]; then
            local optvar=$(echo ${opt/\-\-/} | awk {' print toupper($0) '} | tr "-" "_")
            local optvalidx=$[ ${idx} + 1 ]
            logger_log 2 "Exporting '${optvar}' => '${opts[${optvalidx}]}' (idx: ${idx} / ${optvalidx})"
            export ${optvar}=${opts[${optvalidx}]}
        fi
        idx=$[ $idx + 1 ]
    done
}