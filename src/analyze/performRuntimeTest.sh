#! /bin/bash


# date: 23.03.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing the runtime test of an OMNeT++ simulation

VERSION=0.0.1
DRYRUN=false

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

function command_exists {
    type "$1" &> /dev/null ;
}

function printUsage {
    echo "USAGE:"
    echo "  $(basename $0) [options] SIMEXEC [SIM_OPTIONS]"
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
    echo "RESULTFILE ..... generated file with gathered results"
    echo "SEPERATOR ...... seperator between results"
    echo "OUTPUTFOLDER ... folder for generated output files"
    echo "OUTPUTPREFIX ... prefix for generated output files"
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
if [ $# -lt 1 ]; then
    error "Invalid number of parameter"
    printUsage
    exit 1
fi

# set parameter
SIMEXEC=$1; shift
SIM_OPTIONS=$@


if [ -z $RESULTFILE ]; then
    RESULTFILE=runtimeResults.txt 
fi

if [ -z $SEPERATOR ]; then
    RESULT_SEP=' '
else
    RESULT_SEP=$SEPERATOR
fi


if [ -z $OUTPUTFOLDER ]; then
    export OUTPUTFOLDER=output
fi

if [ -z $OUTPUTPREFIX ]; then
    export OUTPUTPREFIX=runtime
fi

# check necessary commands
TCONF=tconf

if ! command_exists $TCONF; then
    error "$TCONF command is not in PATH"
    exit 1
fi

# print start message
log1 "$(basename $0) called at $(date) with parameter:"
log1 "  RESULTFILE   = $RESULTFILE"
log1 "  SEPERATOR    = $RESULT_SEP"

# settings for tconf
export SEPERATOR=.


# local settings
CONFIGS=(Modular Monolithic)
CPU_TIME_OPT=--cpu-time-limit=0

REGEX_GET_ELAPSED_TIME='(?<=Elapsed:\s)(\d+\.?\d*s)(?=\s\(.*100%)'
REGEX_GET_FILENAME_PARTS='[^\s^/.]+(?=\..+)'

# execute simulations
run $TCONF ${#CONFIGS[*]} ${CONFIGS[*]} $SIMEXEC $CPU_TIME_OPT $SIM_OPTIONS

# check if results file does not yet exist
if [ ! -f $OUTPUTFOLDER/$RESULTFILE ]; then
    log "write header of result file"
    if [ ! $DRYRUN ]; then
        echo "Prefix"$RESULT_SEP"Configuration"$RESULT_SEP"Runtime"$RESULT_SEP"JobId" >> $OUTPUTFOLDER/$RESULTFILE
    fi
fi

log "analyze results"

for FILE in $OUTPUTFOLDER/*
do
    PARTS=($(echo $FILE | grep -o -P $REGEX_GET_FILENAME_PARTS))
    if [ "${PARTS[0]}" == "$OUTPUTPREFIX" ]; then
        
        CONFIG=${PARTS[1]}
        
        TIME=$(grep -o -P $REGEX_GET_ELAPSED_TIME $FILE)
    
        log "configuration $CONFIG resulted with: $TIME"
        
        if ! $DRYRUN ; then
            # check job information
            if [ ${#PARTS[*]} -gt 3 ]; then
                run $(echo "$OUTPUTPREFIX$RESULT_SEP$CONFIG$RESULT_SEP$TIME$RESULT_SEP${PARTS[3]}" >> $OUTPUTFOLDER/$RESULTFILE)
            else
                run $(echo "$OUTPUTPREFIX$RESULT_SEP$CONFIG$RESULT_SEP$TIME" >> $OUTPUTFOLDER/$RESULTFILE)
            fi
        fi
    fi
done

# print final message
log1 "$(basename $0) finished at $(date)"
