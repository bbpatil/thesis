#! /bin/bash


# date: 30.03.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing the real time test of an OMNeT++ simulation

VERSION=0.0.1
DRYRUN=false
DEBUG=false

function error {
    echo -e "\e[31mERROR: $@\e[0m"
}

function log {
    echo -e "\e[92m+++ $@\e[0m"
}

function log1 {
    echo -e "\e[32m$@\e[0m"
}

function logd {
    if [ $DEBUG = true ]; then
        log $*
    fi
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

# embedded python function for reading all peformance ratios and compare them
# to the environmental borders
function ratios_within {
python - $* <<END
import sys
import os
import re

# regex for perf ratio
REGEX_GET_PERF_RATIO = r'(\d+\.\d+)(?=\s*ev\/simsec)'


file = sys.argv[1]
upperBorder = float(os.getenv("RATIO_UPPER"))
lowerBorder = float(os.getenv("RATIO_LOWER"))

# open file and read all lines
with open(file) as f:
    output = f.read()

# get list of floats from found ratios
perfs = [float(perf) for perf in re.findall(REGEX_GET_PERF_RATIO, output)]

for perf in perfs:
    # check condition
    if lowerBorder > perf or perf > upperBorder:
        exit(1)
        
exit(0)
END
return $?
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
    echo "RUNSTART ....... first run number to simulate, default: 0"
    echo "RATIO_UPPER .... upper border for a valid real time ratio"
    echo "RATIO_LOWER .... lower border for a valid real time ratio"
    echo "RUNS_WITHIN .... number of runs that must be within the defined ratio"
    echo "PAR_NAME ....... name of run parameter"
    echo "DEBUG .......... detailed debug output"
}

# parse optional parameters
while getopts "hvd" opt; do
    case $opt in
    h)
        echo "$(basename $0) SIMEXEC [SIM_OPTIONS]"
        echo "  script for performing the real time test"
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
    RESULTFILE=realTimeResults.txt
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
    OUTPUTPREFIX_DEF=realtime
else
    OUTPUTPREFIX_DEF=$OUTPUTPREFIX
fi

if [ -z $RUNSTART ]; then
    RUNSTART=0
fi

if [ -z $RATIO_UPPER ]; then
    export RATIO_UPPER=1.1
fi

if [ -z $RATIO_LOWER ]; then
    export RATIO_LOWER=0.9
fi

if [ -z $RUNS_WITHIN ]; then
    RUNS_WITHIN=3
fi

if [ -z $PAR_NAME ]; then
    PAR_NAME=generationInterval
fi

# check necessary commands
TCONF=tconf

if ! command_exists $TCONF; then
    error "$TCONF command is not in PATH"
    exit 1
fi

# print start message
log1 "$(basename $0) called at $(date) with parameter:"
log1 "  SIMEXEC      = $SIMEXEC"
log1 "  SIM_OPTIONS  = $SIM_OPTIONS"
log1 "  RESULTFILE   = $RESULTFILE"
log1 "  SEPERATOR    = $RESULT_SEP"
log1 "  OUTPUTFOLDER = $OUTPUTFOLDER"
log1 "  OUTPUTPREFIX = $OUTPUTPREFIX"
log1 "  RUNSTART     = $RUNSTART"
log1 "  RATIO_UPPER  = $RATIO_UPPER"
log1 "  RATIO_LOWER  = $RATIO_LOWER"
log1 "  RUNS_WITHIN  = $RUNS_WITHIN"
log1 "  PAR_NAME     = $PAR_NAME"

# settings for tconf
export SEPERATOR=.

# local settings
CONFIGS=(Modular Monolithic)
SIM_TIME_OPT=--sim-time-limit=0

REGEX_GET_NUMBER_OF_RUNS='(?<=Number\sof\sruns:\s)(\d+)'
REGEX_GET_PARAMETER="(?<=\\\$$PAR_NAME=)\\d+"

# check if results file does not yet exist
if [ ! -f $OUTPUTFOLDER/$RESULTFILE ]; then
    log "write header of result file"
    if [ $DRYRUN = false ]; then
        echo "Prefix"$RESULT_SEP"Configuration"$RESULT_SEP"RunNumber"$RESULT_SEP"Parameter" >> $OUTPUTFOLDER/$RESULTFILE
    fi
fi

# loop through configurations
for CONFIG in ${CONFIGS[*]}
do
    
    # get number of runs
    NUMBER=($($SIMEXEC $SIM_OPTIONS -x $CONFIG | grep -o -P $REGEX_GET_NUMBER_OF_RUNS))
    
    # use first number (parallel support)
    NUMBER=${NUMBER[0]}

    log "Configuration $CONFIG expands to $NUMBER runs"    
    
    # check run begin
    if [ $RUNSTART -ge $NUMBER ]; then
        error "Invalid RUNSTART defined: $RUNSTART"
        exit 1
    fi
    
    WITHIN_COUNTER=0
    VALID_RUN_NUMBER=
    
    # loop through runs
    for (( RUN=$RUNSTART; RUN<$NUMBER; RUN++ ))
    do
        log "simulate run $RUN for configuration $CONFIG"
        
        # export outputprefix for tconf
        export OUTPUTPREFIX=$OUTPUTPREFIX_DEF$SEPERATOR$RUN
        
        # execute simulation for defined run and configuratio
        run $TCONF 1 $CONFIG $SIMEXEC $SIM_OPTIONS -r$RUN
        
        # analyze results
        
        RUN_VALID=true
        
        # loop through current result files
        for FILE in $(find $OUTPUTFOLDER/ -name "$OUTPUTPREFIX$SEPERATOR$CONFIG$SEPERATOR*")
        do
            logd "Analyzing file: $FILE"
        
            # check if ratios in file are within defined border
            ratios_within $FILE
            
            if [ $? != 0 ]; then
                logd "file resulted invalid"
                RUN_VALID=false
            fi
        done
        
        # check if current run was valid
        if $RUN_VALID; then
            WITHIN_COUNTER=$((WITHIN_COUNTER+1))
        
            log "run $RUN resulted valid"
                
            # check if valid run number is set
            if [ -z $VALID_RUN_NUMBER ]; then
                logd "first valid run in sequence"
                VALID_RUN_NUMBER=$RUN
            fi
            
            # check if necessary runs are analyzed
            if [ $WITHIN_COUNTER -ge $RUNS_WITHIN ]; then
                log "$WITHIN_COUNTER consecutive runs matching real time constraints starting at run $VALID_RUN_NUMBER"
                break;
            fi
        else
            logd "invalid run"
            WITHIN_COUNTER=0
            VALID_RUN_NUMBER=
        fi
    done
    
    logd "finished analzye $VALID_RUN_NUMBER"
    
    # check if run was detected
    if [ -n "$VALID_RUN_NUMBER" ]; then
        
        logd "valid run detected"
        # get parameter of resulting run
        FILES=($(find $OUTPUTFOLDER/ -name "$OUTPUTPREFIX_DEF$SEPERATOR$VALID_RUN_NUMBER$SEPERATOR$CONFIG$SEPERATOR*"))
        PAR=$(grep -o -P $REGEX_GET_PARAMETER ${FILES[0]})
        
        # write results
        run 'echo "$OUTPUTPREFIX_DEF$RESULT_SEP$CONFIG$RESULT_SEP$VALID_RUN_NUMBER$RESULT_SEP$VALID_RUN_PAR$RESULT_SEP$PAR" >> $OUTPUTFOLDER/$RESULTFILE'
    fi
    
    logd "done with configuration $CONFIG"
    
done


# print final message
log1 "$(basename $0) finished at $(date)"
