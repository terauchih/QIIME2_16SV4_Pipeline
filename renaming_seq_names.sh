#!/bin/bash

## MC69 Sequences have '_' which plugs up Deblur in QIIME2

## This script will reduce down the '_' thats in the names

# Created: 8/15/2019
# Last Edited: 8/16/2019
# Hinako Terauchi 

######################################################################3

#        mv ${name} ${name:0:5}${name:6};


for name in $(ls *.fastq.gz); do
	echo $name
	a=$(echo ${name%_L001*} | tr -d \_)
	mv ${name} $a${name:(-21)}
done




### trying to put the replaced first part into a variable 
