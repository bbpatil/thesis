#! /bin/bash


# date: 11.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script testing multiple runs of an given OMNeT++ 
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
    if [ $DRYRUN = true ]; then
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
    echo "  $(basename $0) [options] NUMCONFIGS {CONFIGS} RUNSTART RUNEND SIMEXEC [SIM_OPTIONS]"
    echo "    NUMCONFIGS ... number of defined configuraions to execute"
    echo "    {CONFIGS} .... names of configurations to execute (must match the defined number"
    echo "                   may be 0"
    echo "    RUNSTART ..... starting runnumber"
    echo "    RUNEND ....... final runnumber (-1 for all available runs)"
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

# embedded python function for reading all peformance ratios and calculate avg
function get_avg_ratio {
python - $* <<END
import sys
import re

# regex for perf ratio
REGEX_GET_PERF_RATIO = r'(\d+\.\d+)(?=\s*ev\/simsec)'


file = sys.argv[1]

# open file and read all lines
with open(file) as f:
    output = f.read()

# get list of floats from found ratios
perfs = [float(perf) for perf in re.findall(REGEX_GET_PERF_RATIO, output)]

# calculate avg
average = sum(perfs)/float(len(perfs))

# print result
print average
        
exit(0)
END
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
RUNSTART=$1; shift
RUNEND=$1; shift

SIMEXEC=$1; shift
SIM_OPTIONS=$@

if [ -z $RESULTFILE ]; then
    RESULTFILE=results.txt 
fi


if [ -z $OUTPUTFOLDER ]; then
    if $RAMDISK; then
	    OUTPUTFOLDER=/media/ramdisk/runTest
    else
        OUTPUTFOLDER=output
    fi
fi

if [ -z $OUTPUTPREFIX ]; then
    OUTPUTPREFIX=output 
fi

if [ -z $SEPERATOR ]; then
    SEPERATOR=. 
fi

if [ -z $RESULT_SEPERATOR ]; then
    RESULT_SEPERATOR=' '
fi

REGEX_GET_NUMBER_OF_RUNS='(?<=Number\sof\sruns:\s)(\d+)'

REGEX_GET_PARAMETER_NAMES='\w+(?==.*\$repetition)'
REGEX_GET_PARAMETER_VALUES='\d+(?=.*\$repetition)'

REGEX_GET_ELAPSED_TIME='(?<=Elapsed:\s)(\d+\.?\d*s)(?=\s\(.*10[\d]%)'
REGEX_GET_CREATED_EVENTS='(?<=simulation\sstopped\sat\sevent\s#)(\d*)(?=,\s)'

# check if outputfolder exists
if [ ! -d "$OUTPUTFOLDER" ]; then
    log "create $OUTPUTFOLDER"
    run mkdir $OUTPUTFOLDER
fi

# check if results file does not yet exist
if [ ! -f $OUTPUTFOLDER/$RESULTFILE ]; then
    log "write header of result file"
    run 'echo "Prefix"$RESULT_SEPERATOR"RunNumber"$RESULT_SEPERATOR"Configuration"$RESULT_SEPERATOR"Runtime"$RESULT_SEPERATOR"CreatedEvents"$RESULT_SEPERATOR"Sec/Simsec"$RESULT_SEPERATOR"StudyParameter" >> $OUTPUTFOLDER/$RESULTFILE'
fi

# print start message
log1 "$(basename $0) called at $(date) with parameter:"
log1 "  SIMEXEC         = $SIMEXEC"
log1 "  SIM_OPTIONS     = $SIM_OPTIONS"
log1 "  CONFIGURATIONS  = ${CONFIGS[*]}"
log1 "  OUTPUTFOLDER    = $OUTPUTFOLDER"
log1 "  OUTPUTPREFIX    = $OUTPUTPREFIX"
log1 "  RUNSTART        = $RUNSTART"
log1 "  RUNEND          = $RUNEND"
log1 "  RESULTFILE      = $RESULTFILE"

# loop through configurations
for CONFIG in ${CONFIGS[*]}
do

    # get number of runs
    NUMBER=($($SIMEXEC $SIM_OPTIONS -x $CONFIG | grep -o -P $REGEX_GET_NUMBER_OF_RUNS))
    
	# check if multiple numbers (parallel)
	if [ ${#NUMBER[*]} -gt 1 ]; then
		NUMBER=${NUMBER[1]}
	fi
	
    log "Configuration $CONFIG expands to $NUMBER runs"    

    # check run begin
    if [ $RUNSTART -ge $NUMBER ]; then
        error "Invalid RUNSTART defined: $RUNSTART"
        exit 1
    fi

    # loop through runs
    for (( RUN=$RUNSTART; RUN<$NUMBER; RUN++ ))
    do
        log "simulate run $RUN for configuration $CONFIG"
        
        # define output file name
        OUTPUTBASE=$OUTPUTFOLDER/$OUTPUTPREFIX$SEPERATOR$RUN$SEPERATOR$CONFIG        
        OUTPUTFILE=$OUTPUTBASE.txt
        
        # execute simulation for defined run and configuration
        run $SIMEXEC $SIM_OPTIONS -c $CONFIG --cmdenv-output-file=$OUTPUTFILE -r $RUN
        
        # loop through generated output files (for parallel support)
        FILES=($OUTPUTBASE*)
        NUMBER_OF_FILES=${!FILES[*]}
        FILEIDX=0
        for OUTFILE in ${FILES[*]}
        do
            # get output for study parameters
            STUDY_PARAM_NAMES=$(grep -o -P $REGEX_GET_PARAMETER_NAMES $OUTFILE)
            STUDY_PARAM_VALUES=$(grep -o -P $REGEX_GET_PARAMETER_VALUES $OUTFILE)
            
            # get output for performance values and accumulate values
            RUNTIME=$(grep -o -P $REGEX_GET_ELAPSED_TIME $OUTFILE)
            EVENTS=$(grep -o -P $REGEX_GET_CREATED_EVENTS $OUTFILE)
            PERFRATIO=$(get_avg_ratio $OUTFILE)
            
                    
            # write results
            RESULTS="$OUTPUTPREFIX$RESULT_SEPERATOR$RUN$RESULT_SEPERATOR$CONFIG$RESULT_SEPERATOR$RUNTIME$RESULT_SEPERATOR$EVENTS$RESULT_SEPERATOR$PERFRATIO"
            
            log1 "Run $RUN - $FILEIDX for configration $CONFIG and study parameter"
            for IDX in ${!STUDY_PARAM_NAMES[*]}
            do
                log1 "   ${STUDY_PARAM_NAMES[$IDX]} : ${STUDY_PARAM_VALUES[$IDX]}"
                RESULTS="$RESULTS$RESULT_SEPERATOR${STUDY_PARAM_VALUES[$IDX]}"
            done
            # append file index for parallel support
            RESULTS="$RESULTS$RESULT_SEPERATOR$FILEIDX"
            
            log1 "resulted with:"
            log1 "   runtime    : "$RUNTIME
            log1 "   events     : "$EVENTS
            log1 "   perfratio  : "$PERFRATIO
            
            run 'echo "$RESULTS" >> $OUTPUTFOLDER/$RESULTFILE'
        
            let FILEIDX+=1
        done
    done
done


# print final message
log1 "$(basename $0) finished at $(date)"
