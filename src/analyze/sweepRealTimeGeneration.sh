#! /bin/bash


# date: 06.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing runtime tests with generation interval
#               sweep


TIMES=(1000ns 1100ns 1200ns 1300ns 1400ns 1500ns 2000ns 2500ns 3000ns 3500ns 4000ns 4500ns 5000ns)

FILE=parameter.ini

for TIME in ${TIMES[*]}
do
    echo "[General]" >> $FILE
    echo "DataGeneration.generator.generationInterval=$TIME" >> $FILE

    echo "execute simulation for generation interval: $TIME"
    export OUTPUTPREFIX=$TIME
    prtt $* -f $FILE
    
    rm $FILE
done
