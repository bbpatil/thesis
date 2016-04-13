#! /bin/bash


# date: 06.04.2016
# name: Franz Profelt
# email: franz.profelt@gmail.com
# description: script for performing runtime tests with number of eventmanagers
#               sweep


NUMBERS=(1 2 5 10 20 50 100 200 300 400 500)

FILE=parameter.ini

if [ -f $FILE ]; then
    rm $FILE
fi

for NUMBER in ${NUMBERS[*]}
do
    echo "[General]" >> $FILE
    echo "DataGeneration.**.numberOfEventManager=$NUMBER" >> $FILE
    
    echo "execute simulation for number of eventmanagers: $NUMBER"
    export OUTPUTPREFIX=$NUMBER
    prtt $* -f $FILE
    
    rm $FILE
done
