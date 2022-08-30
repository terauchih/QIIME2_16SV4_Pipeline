#!/bin/bash

## Some 16S Sequences have '_' within their sample number, which plugs up Deblur in QIIME2

## This script will reduce down the '_' thats in the names

# Created: 8/15/2019
# Last Edited: 8/30/2022 (removed hard coding and added variables)
## - Added saving the original and the new names in a .csv
# Hinako Terauchi 

######################################################################3

#        mv ${name} ${name:0:5}${name:6};

# initialize a .csv with column names:
echo originalName \, changedName >> ../seqNameChanges.csv

for name in $(ls *.fastq.gz); do
	echo $name
	ogName=$(echo ${name%_S[0-9]*})
	newName=$(echo $ogName | tr \_ \-) 
	
	echo $ogName \, $newName >> ../seqNameChanges.csv
	mv ${name} $newName${name##$ogName}
done




### trying to put the replaced first part into a variable 
