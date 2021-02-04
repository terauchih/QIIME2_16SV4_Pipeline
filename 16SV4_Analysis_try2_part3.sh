#!/bin/bash -login

#date created: 4/8/2019
#date modified: NA

#Hinako Terauchi 

#This is part 3 of second attempt at submission script of QIIME2 to HPCC

#In this script, it will run getting the newwest version of Silva, clustering, and making feature tables. 

#In the end, it will call and submit part 4 

###################################################################

#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name QIIME2_16SV4_Analysis_Part3

####################################################################
#Script
#Initializing anaconda environment
conda init bash

#activating QIIME2 software
conda activate qiime2-2019.1

#Getting version 128 of QIIME Silva release
#(**Update link and version as needed)
wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_128_release.tgz

#Unzipping a .tgz file
tar zxvf Silva_128_release.tgz

#Importing the reference file into a QIIME format
#(***CHANGE THE input-path!!)
qiime tools import --input-path ~/MC58_QIIME2/SILVA_128_QIIME_release/rep_set/rep_set_16S_only/97/97_otus_16S.fasta --output-path SILVA97-reference.qza --type 'FeatureData[Sequence]'

#Clustering at 97%
qiime vsearch cluster-features-closed-reference --i-table table.qza --i-sequences rep-seqs.qza --i-reference-sequences SILVA97-reference.qza --p-perc-identity 0.97 --o-clustered-table table-cr-97.qza --o-clustered-sequences rep-seqs-cr-97.qza --o-unmatched-sequences unmatched-cr-97.qza

#Making a feature table file without chimeras or borderline chimeras
#part 1
qiime feature-table filter-features --i-table table.qza --m-metadata-file uchime-dn-out/nonchimeras.qza --o-filtered-table uchime-dn-out/table-nonchimeric-wo-borderline.qza
#part 2
qiime feature-table filter-seqs --i-data rep-seqs.qza --m-metadata-file uchime-dn-out/nonchimeras.qza --o-filtered-data uchime-dn-out/rep-seqs-nonchimeric-wo-borderline.qza

#Summarizing filtered sequences without chimeras
qiime feature-table summarize --i-table uchime-dn-out/table-nonchimeric-wo-borderline.qza --o-visualization uchime-dn-out/table-nonchimeric-wo-borderline.qsv

########################################################################

#Calling and submitting part 4 

sbatch 16SV4_Analysis_try2_part4.sh





