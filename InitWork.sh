 #! /bin/bash
 
echo "load omnet++ environment variables"
pushd $OMNETPP_ROOT
source setenv
popd

PRJ_HOME=$(pwd)
ANALYZE_BIN=$PRJ_HOME/src/analyze/bin

function execute_if_not_yet {
ARGS=($*)
LINKNAME=${ARGS[3]}
if [ -e $LINKNAME ]; then
	echo "link already exists $LINKNAME"
else	
	eval $*
fi
}

# check if analyze bin dir does not exists
if [ ! -d $ANALYZE_BIN ]; then
    echo "create analyze bin directory"
    mkdir $ANALYZE_BIN
fi

echo "create symlinks to analyze scripts"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/performEventTest.sh $ANALYZE_BIN/pet"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/performRuntimeTest.sh $ANALYZE_BIN/prt"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/performRealTimeTest.sh $ANALYZE_BIN/prtt"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/sweepCpuTime.sh $ANALYZE_BIN/sct"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/sweepSimTime.sh $ANALYZE_BIN/sst"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/sweepRealTimeEventManagers.sh $ANALYZE_BIN/srte"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/sweepRealTimePolling.sh $ANALYZE_BIN/srtp"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/sweepRealTimeSimtime.sh $ANALYZE_BIN/srts"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/testRuns.sh $ANALYZE_BIN/truns"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/testConfigurations.sh $ANALYZE_BIN/tconf"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/parseResults.py $ANALYZE_BIN/parseRes"
execute_if_not_yet "ln -s $PRJ_HOME/src/analyze/analyzeResults.sh $ANALYZE_BIN/analyzeRes"

echo "add analyze bin directory to PATH"
export PATH=$PATH:$ANALYZE_BIN/

# start enironment applications if parameter is passed
if [ $# -ge 1 ]; then

    echo "start omnet++ ide"
    omnetpp &
    
    echo "open omnet++ documentation"
    google-chrome $OMNETPP_ROOT/doc/manual/usman.html &

    echo "open masterthesis"
    texstudio doc/thesis/masterthesis.tex --master &

    echo "open doc folder"
    dolphin doc &
fi

echo "switch to src folder"
cd src
