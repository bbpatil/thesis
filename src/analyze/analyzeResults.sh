#! /bin/bash

# simple script for generating the parsed result files

 PARSE=parseRes
 
 # runtime
 $PARSE runtimeEval/runtimeResults.txt -t 0 -c 1 -i 2 -o ../ -g
 $PARSE runtimeEventManager/simtimeEventManagerResults.txt -t 6 -c 2 -i 3 -o ../runtime -g
 $PARSE runtimeGeneration/simtimeGenerationResults.txt -t 6 -c 2 -i 3 -o ../runtime -g
 $PARSE runtimePolling/simtimePollingResults.txt -t 6 -c 2 -i 3 -o ../runtime -g
 
 # correction value
 $PARSE runtimeEventManager/simtimeEventManagerResults.txt -t 6 -c 2 -i 4 -o ../event/correction -g
 $PARSE runtimeGeneration/simtimeGenerationResults.txt -t 6 -c 2 -i 4 -o ../event/correction -g
 $PARSE runtimePolling/simtimePollingResults.txt -t 6 -c 2 -i 4 -o ../event/correction -g
 
 # events
 $PARSE eventEval/eventResults.txt -t 0 -c 1 -i 2 -o ../ -g
 $PARSE eventEventManager/cputimeEventManagerResults.txt -t 6 -c 2 -i 4 -o ../event -g -f 2.149
 $PARSE eventGeneration/cputimeGenerationResults.txt -t 6 -c 2 -i 4 -o ../event -g -f 2.149
 $PARSE eventPolling/cputimePollingResults.txt -t 6 -c 2 -i 4 -o ../event -g -f 2.149
 
 # realtime
 $PARSE realtimeEval/realTimeResults.txt -t 0 -c 1 -i 4 -o ../ -g
 $PARSE realtimeEventManager/rtEventManagerResults.txt -t 0 -c 1 -i 4 -o ../realtime -g
 $PARSE realtimePolling/rtPollingResults.txt -t 0 -c 1 -i 4 -o ../realtime -g
