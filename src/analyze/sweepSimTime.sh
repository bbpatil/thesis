#! /bin/bash


# date: 06.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing runtime tests with simulation time sweep


SIMTIMES=(1s 2s 5s 10s 20s 50s 1min 2min 5min 10min 20min 30min 1h 2h)

for SIMTIME in ${SIMTIMES[*]}
do
    echo "execute simulation for simtime: $SIMTIME"
    export OUTPUTPREFIX=$SIMTIME
    prt $* --sim-time-limit=$SIMTIME
done
