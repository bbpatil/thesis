 #! /bin/bash
 
echo "load omnet++ environment variables"
pushd $OMNETPP_ROOT
source setenv
popd

ANALYZE_BIN=$(realpath src/analyze/bin/)

echo "add analyze bin folder to PATH"
export PATH=$PATH:$ANALYZE_BIN

echo "start omnet++ ide"
omnetpp &

echo "open omnet++ documentation"
google-chrome https://omnetpp.org/documentation &

echo "open masterthesis"
texstudio doc/thesis/masterthesis.tex --master &

echo "open doc folder"
dolphin doc &

echo "switch to src folder"
cd src
