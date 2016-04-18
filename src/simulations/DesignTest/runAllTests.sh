#! /bin/bash
# bash script for automated test runs

if [ $# -lt 1 ]; then
    echo "Choose via parameter the set of tests to run:"
    echo " sequential ... measurement evaluation tests and load tests with all"
    echo "                methods for sequential simulation"
    echo " parallel ..... measurement evaluation tests and load tests with all"
    echo "                methods for parallel simulation"
    exit
fi


# check parameter
if [ $1 = "sequential" ]; then
    ######################### sequential simulations ################################

    ########### measurement evaluation ################
    OUTPUTFOLDER=output/runtimeEval OUTPUTPREFIX= sst ./DesignTest -f simulations/cmdenv.ini

    OUTPUTFOLDER=output/eventEval OUTPUTPREFIX= sct ./DesignTest -f simulations/cmdenv.ini
    
    OUTPUTFOLDER=output/realtimeEval OUTPUTPREFIX= srts ./DesignTest -f simulations/realtime.ini -f simulations/intervalstudy-data-realtime-boundaries.ini


    ########### load measurement for fixed sim time ############
    OUTPUTFOLDER=output/runtimeEventManager RESULTFILE=simtimeEventManagerResults.txt OUTPUTPREFIX=eventManager_simtime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-eventmanagers.ini

    OUTPUTFOLDER=output/runtimePolling RESULTFILE=simtimePollingResults.txt OUTPUTPREFIX=polling_simtime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-polling.ini

    OUTPUTFOLDER=output/runtimeGeneration RESULTFILE=simtimeGenerationResults.txt OUTPUTPREFIX=generation_simtime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-data.ini

    ############## load measurements for fixed cpu time ###################

    OUTPUTFOLDER=output/eventEventManager RESULTFILE=cputimeEventManagerResults.txt OUTPUTPREFIX=eventManager_cputime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-eventmanagers.ini --sim-time-limit=0 --cpu-time-limit=1min

    OUTPUTFOLDER=output/eventPolling RESULTFILE=cputimePollingResults.txt OUTPUTPREFIX=polling_cputime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-polling.ini --sim-time-limit=0 --cpu-time-limit=1min

    OUTPUTFOLDER=output/eventGeneration RESULTFILE=cputimeGenerationResults.txt OUTPUTPREFIX=generation_cputime_1min truns 2 Modular Monolithic 0 -1 ./DesignTest -f simulations/cmdenv.ini -f simulations/intervalstudy-data.ini --sim-time-limit=0 --cpu-time-limit=1min

    ######### load measurements for real time testing ##################

    OUTPUTFOLDER=output/realtimeEventManager RESULTFILE=rtEventManagerResults.txt OUTPUTPREFIX=eventManager_realtime srte ./DesignTest -f simulations/realtime.ini -f simulations/intervalstudy-data-realtime-boundaries.ini

    OUTPUTFOLDER=output/realtimePolling RESULTFILE=rtPollingResults.txt OUTPUTPREFIX=polling_realtime srtp ./DesignTest -f simulations/realtime.ini -f simulations/intervalstudy-data-realtime-boundaries.ini

elif [ $1 = "parallel" ];then
    ####################### parallel simulations ###############################

    ########### measurement evaluation #####################
    OUTPUTFOLDER=output/simtimeParallel RESULTFILE=simtimeResultsParallel.txt OUTPUTPREFIX=mpi_nma_channeldelay_100ms truns 2 Modular Monolithic 0 -1 mpirun ./DesignTest -f simulations/parallel.ini -f simulations/intervalstudy-simtime.ini

    OUTPUTFOLDER=output/cputimeParallel RESULTFILE=cputimeResultsParallel.txt OUTPUTPREFIX=mpi_nma_channeldelay_100ms truns 2 Modular Monolithic 0 -1 mpirun ./DesignTest -f simulations/parallel.ini -f simulations/intervalstudy-cputime.ini

    OUTPUTFOLDER=output/realtimeParallel OUTPUTPREFIX=mpi_nma_channeldelay_100ms srts mpirun ./DesignTest -f simulations/realtime-parallel.ini -f simulations/intervalstudy-data-realtime-boundaries.ini

    ######### load measurement for fixed sim time #############
    OUTPUTFOLDER=output/eventManagersParallel RESULTFILE=simtimeEventManagerResultsParallel.txt OUTPUTPREFIX=mpi_nma_channeldelay_100ms truns 2 Modular Monolithic 0 -1 mpirun ./DesignTest -f simulations/parallel.ini -f simulations/intervalstudy-eventmanagers.ini

    OUTPUTFOLDER=output/pollingParallel RESULTFILE=simtimePollingResultsParallel.txt OUTPUTPREFIX=mpi_nma_channeldelay_100ms truns 2 Modular Monolithic 0 -1 mpirun ./DesignTest -f simulations/parallel.ini -f simulations/intervalstudy-polling.ini

    OUTPUTFOLDER=output/generationParallel RESULTFILE=simtimeGenerationResultsParallel.txt OUTPUTPREFIX=mpi_nma_channeldelay_100ms truns 2 Modular Monolithic 0 -1 mpirun ./DesignTest -f simulations/parallel.ini -f simulations/intervalstudy-data.ini


    ######### load measurements for real time testing ####################

    OUTPUTFOLDER=output/rtEventManagersParallel RESULTFILE=rtEventManagerResultsParallel.txt OUTPUTPREFIX=eventManager_realtime srte ./DesignTest -f simulations/realtime.ini -f simulations/intervalstudy-data-realtime-boundaries.ini

    OUTPUTFOLDER=output/rtPollingParallel RESULTFILE=rtPollingResultsParallel.txt OUTPUTPREFIX=polling_realtime srtp ./DesignTest -f simulations/realtime.ini -f simulations/intervalstudy-data-realtime-boundaries.ini

else
    echo "ERROR: invalid set of tests"
    exit
fi
