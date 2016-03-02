 #! /bin/bash
 
 echo "load omnet++ environment variables"
 source src/omnetpp-4.6/setenv
 
 echo "start omnet++ ide"
 omnetpp &
 
 echo "open masterthesis"
 texstudio doc/thesis/masterthesis.tex &
