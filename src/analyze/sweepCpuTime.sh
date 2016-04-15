#! /bin/bash


# date: 06.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing runtime tests with cpu time sweep


CPUTIMES=(1s 1.5s 2s 2.5s 3s 3.5s 4s 4.5s 5s 7s 10s)

for CPUTIME in ${CPUTIMES[*]}
do
    echo "execute simulation for cputime: $CPUTIME"
    export OUTPUTPREFIX=event_cputime_$CPUTIME
    pet $* --cpu-time-limit=$CPUTIME
done
