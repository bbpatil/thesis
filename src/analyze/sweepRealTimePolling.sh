#! /bin/bash


# date: 12.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing runtime tests with polling interval sweep


TIMES=(1000ns 1100ns 1200ns 1300ns 1400ns 1500ns 2000ns 2500ns 3000ns 3500ns 4000ns 4500ns 5000ns)

FILE=parameter.ini

for TIME in ${TIMES[*]}
do
    echo "[General]" >> $FILE
    echo "DataGeneration.sink.historyPollingInterval=$TIME" >> $FILE
    
    echo "execute simulation for polling interval: $TIME"
    export OUTPUTPREFIX=$TIME
    prtt $* -f $FILE
    
    rm $FILE
done
