 #! /bin/bash
 
 echo "load omnet++ environment variables"
pushd $OMNETPP_ROOT
 . setenv
 popd
 
 echo "start omnet++ ide"
 omnetpp &
 
 echo "open omnet++ documentation"
 google-chrome https://omnetpp.org/documentation &
 
 echo "open masterthesis"
 texstudio doc/thesis/masterthesis.tex &
