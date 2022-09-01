#!/bin/bash -login

#date created: 4/8/2019
#date modified: 8/31/2022 (Added .qsv export)

#Hinako Terauchi 

#This is part 2 of second attempt at submission script of QIIME2 to HPCC

#In this script, it will run quality control, deblur denoising, then check for chimera 

#In the end, it will call and submit part 3 

###################################################################

#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name QIIME2_16SV4_Analysis_Part2

####################################################################
#Script

#Initializing anaconda environment
conda init bash

#activating QIIME2 software
conda activate qiime2-2022.2

#Running quality control
qiime quality-filter q-score --i-demux demux-joined.qza --o-filtered-sequences demux-joined-filtered.qza --o-filter-stats demux-joined-filter-stats.qza

#Denoising with deblur
qiime deblur denoise-16S --i-demultiplexed-seqs demux-joined-filtered.qza --p-trim-length 251 --p-sample-stats --o-representative-sequences rep-seqs.qza --o-table table.qza --o-stats deblur-stats.qza

#Summarizing feature table into a visual file
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv

# Exporting table.qzv:
qiime tools export --input-path table.qzv --output-path exportFiles/table

#Checking for chimera (denovo)
qiime vsearch uchime-denovo --i-table table.qza --i-sequences rep-seqs.qza --output-dir uchime-dn-out

#Visualizing summary stats
qiime metadata tabulate --m-input-file uchime-dn-out/stats.qza --o-visualization uchime-dn-out/stats.qzv

# Exporting stats.qsv:
qiime tools export --input-path uchime-dn-out/stats.qzv --output-path exportFiles/stats


####################################################################

#Calling part 3

sbatch 16SV4_Analysis_try2_part3.sh 

