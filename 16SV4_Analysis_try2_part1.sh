#!/bin/bash -login

#Date created: 4/8/2019
#Date modified: 8/31/2022 (Added .qzv export line)
#Hinako Terauchi 

#This is part 1 of second attempt at submission script of QIIME2 to HPCC
#Previous script(QIIME2_16SV4_Analysis.sh) kept running out of time
#In this script, it copies the sequences into a new directory and then join those sequences

#This script will call part 2 at the end 

###################################################################

#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name QIIME2_16SV4_Analysis_Part1

####################################################################
#Script:

#Initializing anaconda environment
conda init bash

#activating QIIME2 software
conda activate qiime2-2022.2

#**Go into the project directory**
# (change to appropriate dir name below)
cd PROJECT_DIR/

#**First make directory the sequences will be stored in**
# (Change the dir name below)
mkdir PROJECT_Sequences

#**Copy sequences from the Sequence_Archives to the newly made dir**
# (Change the path and the dir name below)
cp ~/Sequence_Archives/PROJECT_16S_data/*.fastq.gz ~/PROJECT_DIR/PROJECT_Sequences/

#**OPTIONAL depending on sequence file names**
# Change the "_" in sample names to "-"
# having "_" in sample name part clogs up Deblur
cd PROJECT_Sequences
cp ~/QIIME2_Scripts/renaming_seq_names.sh .
bash renaming_seq_names.sh
rm renaming_seq_names.sh
cd ..


#**Import sequences as a QIIME file**
# (Change the input-path below)
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path PROJECT_Sequences --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path demux-paired-end.qza

#Summarizing sequences into a visual file
qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux-paired-end.qzv

# Exporting the above visual file:
qiime tools export --input-path demux-paired-end.qzv --output-path exportFiles/demuxPairedEnd

#Joining ends
qiime vsearch join-pairs --i-demultiplexed-seqs demux-paired-end.qza --o-joined-sequences demux-joined.qza

#Summarizing joined sequences into a visual file
qiime demux summarize --i-data demux-joined.qza --o-visualization demux-joined.qzv

# Exporting the above visual file:
qiime tools export --input-path demux-joined.qzv --output-path exportFiles/demuxJoined

##########################################################################

#Calling script part 2
sbatch 16SV4_Analysis_try2_part2.sh 
