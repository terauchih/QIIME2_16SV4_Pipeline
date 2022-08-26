#!/bin/bash

## Some 16S Sequences have '_' within their sample number, which plugs up Deblur in QIIME2

## This script will reduce down the '_' thats in the names

# Created: 8/15/2019
# Last Edited: 8/26/2022
## - Added saving the original and the new names in a .csv
# Hinako Terauchi 

######################################################################3

#        mv ${name} ${name:0:5}${name:6};

# initialize a .csv with column names:
echo originalName \, changedName >> ../seqNameChanges.csv

for name in $(ls *.fastq.gz); do
	echo $name
	a=$(echo ${name%_L001*} | tr \_ \-)
	echo ${name%_L001*} \, $a >> ../seqNameChanges.csv
	mv ${name} $a${name:(-21)}
done




### trying to put the replaced first part into a variable 
