#! /bin/bash


# date: 23.03.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script testing multiple configurations of an given OMNeT++ 
#              simulation

VERSION=0.0.1
DRYRUN=false
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
    echo "  $(basename $0) [options] NUMCONFIGS {CONFIGS} SIMEXEC [SIM_OPTIONS]"
    echo "    NUMCONFIGS ... number of defined configuraions to execute"
    echo "    {CONFIGS} .... names of configurations to execute (must match the defined number"
    echo "                   may be 0"
    echo "    SIMEXEC ...... simulation executable"
    echo "    SIM_OPTIONS .. additional options and parameters are passed to simulation"
    echo "                   executable"
    echo "                   simulations started with seperate tool like opp_run*"
    echo "                   or mpirun can also be defined as executable an options"
    echo ""
    echo "    -h ........... printing help message"
    echo "    -v ........... print current version"
    echo "    -d ........... dry run, print parameter but don't execute simulation"
    echo "    -r ........... if no OUTPUTFOLDER is defined the files will be created at"
    echo "                   /media/ramdisk/configTest/"
    echo ""
    echo "Additional settings available via environment parameter:"
    echo "OUTPUTFOLDER ... destination folder of generated output files"
    echo "OUTPUTPREFIX ... prefix for generated output files"
    echo "SEPERATOR ...... seperator of fileprefix and config (default = '.')"
}



# parse optional parameters
while getopts "hvdr" opt; do
    case $opt in
    h)
        echo "$(basename $0)"
        echo "  script testing multiple configurations of an given OMNeT++ simulation"
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
    r)
        RAMDISK=true
        shift
        ;;
    \?)
        error "Invalid option: -$OPTARG"
        exit
        ;;
    esac
done

# check parameter
if [ $# -lt 2 ]; then
    error "Invalid number of parameter"
    printUsage
    exit 1
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
    error "Invalid number of configurations"
    printUsage
    exit 1
fi

NUMBER_OF_CONFIGS=$1;shift

if [ $# -le $NUMBER_OF_CONFIGS ]; then
    error "Invalid number of parameter"
    printUsage
    exit 1
fi

CONFIGS=

for (( i=0; i < $NUMBER_OF_CONFIGS; i++))
do
    CONFIGS=(${CONFIGS[*]} $1)
    shift
done

# set parameter
SIMEXEC=$1; shift
SIM_OPTIONS=$@

if [ -z $OUTPUTFOLDER ]; then
    if $RAMDISK; then
	    OUTPUTFOLDER=/media/ramdisk/configTest
    else
        OUTPUTFOLDER=configTestOutput
    fi
fi

if [ -z $OUTPUTPREFIX ]; then
    OUTPUTPREFIX=output 
fi

if [ -z $SEPERATOR ]; then
    SEPERATOR=. 
fi

# check if outputfolder exists
if [ ! -d "$OUTPUTFOLDER" ]; then
    log "create $OUTPUTFOLDER"
    run mkdir $OUTPUTFOLDER
fi

# print start message
log1 "$(basename $0) called at $(date) with parameter:"
log1 "  SIMEXEC         = $SIMEXEC"
log1 "  SIM_OPTIONS     = $SIM_OPTIONS"
log1 "  CONFIGURATIONS  = ${CONFIGS[*]}"
log1 "  OUTPUTFOLDER    = $OUTPUTFOLDER"


for CONFIG in ${CONFIGS[*]}
do
    log "simulate configuration: $CONFIG"
    
    OUTPUTFILE=$OUTPUTFOLDER/$OUTPUTPREFIX$SEPERATOR$CONFIG.txt
    
    run $SIMEXEC $SIM_OPTIONS -c $CONFIG --cmdenv-output-file=$OUTPUTFILE
done


# print final message
log1 "$(basename $0) finished at $(date)"
