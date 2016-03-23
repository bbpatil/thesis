#! /bin/bash


# date: 23.03.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing the runtime test

VERSION=0.0.1
DRYRUN=false
PRINT=false
RAMDISK=false

function error {
    echo -e "\e[31mERROR: $@\e[0m"
}

function log {
    echo -e "\e[92m+++ $@\e[0m"
}

function log1 {
    echo -e "\e[32m$@\e[0m"
}

# function for executing given commands only when dry run is deactivated
# additionally checks the succes of the commands and exits otherwise
function run {
    # check dryrun
    if $DRYRUN; then
        # print command
        log1 "$*"
        return 0
    fi
    
    # execute command
    eval "$@"
    
    # check return value
    RET=$?
    if [ $RET != 0 ]; then
        error "$*"
        error "failed with return code $RET"
        exit $RET
    fi
}

function printUsage {
    echo "USAGE:"
    echo "  $(basename $0) [options]"
    echo "    SIMEXEC ...... simulation executable"
    echo "    SIM_OPTIONS .. additional options and parameters are passed to simulation"
    echo "                   executable"
    echo "                   simulations started with seperate tool like opp_run*"
    echo "                   or mpirun can also be defined as executable an options"
    echo ""
    echo "    -h ........... printing help message"
    echo "    -v ........... print current version"
    echo "    -d ........... dry run, print parameter but don't execute simulation"
    echo ""
    echo "Additional settings available via environment parameter:"
    echo "RESULTFILE ... generated file with gathered results"
    echo "SEPERATOR ... seperator between results"
}

# parse optional parameters
while getopts "hvd" opt; do
    case $opt in
    h)
        echo "$(basename $0) SIMEXEC [SIM_OPTIONS]"
        echo "  script for performing the runtime test"
        printUsage
        echo "Version $VERSION"
        echo "(c) Franz Profelt 2016"
        exit
        ;;
    v)
        echo "$(basename $0) version $VERSION"
        exit
        ;;
    d)
        DRYRUN=true
        shift
        ;;
    \?)
        ;;
    esac
done

# check parameter
if [ $# -lt 2 ]; then
    error "Invalid number of parameter"
    printUsage
    exit 1
fi

# set parameter
SIMEXEC=$1; shift
SIM_OPTIONS=$@


if [ -z $RESULTFILE ]; then
    RESULTFILE=results.txt 
fi

if [ -z $SEPERATOR ]; then
    RESULT_SEP=' '
else
    RESULT_SEP=$SEPERATOR
fi



# print start message
log1 "$(basename $0) called at $(date) with parameter:"
log1 "  RESULTFILE   = $RESULTFILE"
log1 "  SEPERATOR    = $RESULT_SEP"

# settings for tconf
export OUTPUTFOLDER=output
export OUTPUTPREFIX=out
export SEPERATOR=.


# local settings
CONFIGS=(Modular Monolithic)

REGEX_GET_ELAPSED_TIME='(?<=Elapsed:\s)(\d+\.?\d*s)(?=\s\(.*100%)'
REGEX_GET_CONFIG="(?<=$OUTPUTFOLDER\/$OUTPUTPREFIX\\$SEPERATOR)\w+(?=\\$SEPERATOR.+)"

run tconf ${#CONFIGS[*]} ${CONFIGS[*]} $SIMEXEC $SIM_OPTIONS

log "analyze results"

for FILE in $OUTPUTFOLDER/*
do
    CONFIG=$(echo $FILE | grep -o -P $REGEX_GET_CONFIG)
    TIME=$(grep -o -P $REGEX_GET_ELAPSED_TIME $FILE)
    
    log "configuration $CONFIG resulted with: $TIME"
    
    echo "$CONFIG$RESULT_SEP$TIME" >> $OUTPUTFOLDER/$RESULTFILE
done

# print final message
log1 "$(basename $0) finished ad $(date)"
