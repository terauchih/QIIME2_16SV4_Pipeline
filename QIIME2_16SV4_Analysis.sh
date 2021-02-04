#! /bin/bash

###################################################################
#This is a script that will take raw 16SV4 sequences and analyze them using QIIME2 software. 

#Be sure to change all the paths for each project 

#To run: sbatch QIIME2_16SV4_Analysis.sh

#Created: 2/27/2019

#Last Edited: 

###################################################################

#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name QIIME2_16SV4_Analysis

####################################################################
#Script: 

#Initializing anaconda environment
conda init bash

#activating QIIME2 software
conda activate qiime2-2019.1

#First make directory the sequences will be stored in
#(**Change the dir name!) 
mkdir XXX_Sequences

#Copy sequences from the Sequence_Archives to the newly made dir
#(***Change the path and the dir name!) 
cp /mnt/home/terauch1/Sequence_Archives/XXXXXXXXXX/*.fastq.gz ~/QIIME2_MC66_16SV4/Silva_128_release/XXX_Sequences/

#Import sequences as a QIIME file (**Change the input-path!)
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path XXX_Sequences --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path demux-paired-end.qza

#Summarizing sequences into a visual file
qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux-paired-end.qzv

#Joining ends
qiime vsearch join-pairs --i-demultiplexed-seqs demux-paired-end.qza --o-joined-sequences demux-joined.qza

#Summarizing joined sequences into a visual file
qiime demux summarize --i-data demux-joined.qza --o-visualization demux-joined.qsv

#Running quality control 
qiime quality-filter q-score-joined --i-demux demux-joined.qza --o-filtered-sequences demux-joined-filtered.qza --o-filter-stats demux-joined-filter-stats.qza

#Denoising with deblur
qiime deblur denoise-16S --i-demultiplexed-seqs demux-joined-filtered.qza --p-trim-length 251 --p-sample-stats --o-representative-sequences rep-seqs.qza --o-table table.qza --o-stats deblur-stats.qza

#Summarizing feature table into a visual file 
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv

#Checking for chimera (denovo)
qiime vsearch uchime-denovo --i-table table.qza --i-sequences rep-seqs.qza --output-dir uchime-dn-out

#Visualizing summary stats
qiime metadata tabulate --m-input-file uchime-dn-out/stats.qza --o-visualization uchime-dn-out/stats.qzv

#Getting version 128 of QIIME Silva release
#(**Update link and version as needed)
wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_128_release.tgz

#Unzipping a .tgz file
tar zxvf Silva_128_release.tgz

#Importing the reference file into a QIIME format 
#(***CHANGE THE input-path!!)
qiime tools import --input-path ~/QIIME2_MC66_16SV4/Silva_128_release/SILVA_128_QIIME_release/rep_set/rep_set_16S_only/97/97_otus_16S.fasta --output-path SILVA97-reference.qza --type 'FeatureData[Sequence]'

#Clustering at 97%
qiime vsearch cluster-features-closed-reference --i-table table.qza --i-sequences rep-seqs.qza --i-reference-sequences SILVA97-reference.qza --p-perc-identity 0.97 --o-clustered-table table-cr-97.qza --o-clustered-sequences rep-seqs-cr-97.qza --o-unmatched-sequences unmatched-cr-97.qza

#Making a feature table file without chimeras or borderline chimeras
#part 1
qiime feature-table filter-features --i-table table.qza --m-metadata-file uchime-dn-out/nonchimeras.qza --o-filtered-table uchime-dn-out/table-nonchimeric-wo-borderline.qza
#part 2
qiime feature-table filter-seqs --i-data rep-seqs.qza --m-metadata-file uchime-dn-out/nonchimeras.qza --o-filtered-data uchime-dn-out/rep-seqs-nonchimeric-wo-borderline.qza

#Summarizing filtered sequences without chimeras
qiime feature-table summarize --i-table uchime-dn-out/table-nonchimeric-wo-borderline.qza --o-visualization uchime-dn-out/table-nonchimeric-wo-borderline.qsv

#Importing taxonomy data 
#(***CHANGE THE input-path!!)
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ~/QIIME2_MC66_16SV4/Silva_128_release/SILVA_128_QIIME_release/taxonomy/16S_only/97/majority_taxonomy_7_levels.txt --output-path ref-taxonomy.qza

#Importing consensus taxonomy file
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ~/QIIME2_MC66_16SV4/Silva_128_release/SILVA_128_QIIME_release/taxonomy/16S_only/97/consensus_taxonomy_7_levels.txt --output-path consensus_ref_taxonomy.qza

#Classifying taxonomy to chimera-filtered sequences
qiime feature-classifier classify-consensus-vsearch --i-query uchime-dn-out/rep-seqs-nonchimeric-wo-borderline.qza --i-reference-reads SILVA97-reference.qza --i-reference-taxonomy consensus_ref_taxonomy.qza --o-classification taxonomy_output.qza

#Creating Barplot:
qiime taxa barplot --i-table uchime-dn-out/table-nonchimeric-wo-borderline.qza --i-taxonomy taxonomy_output.qza --m-metadata-file uchime-dn-out/nonchimeras.qza --o-visualization barplot.qzv

#########################END OF SCRIPTS#############################

##Make sure all the necessary input-path have been changed

##Check to see if Silva database has been updated

##Take barplot.qzv, visualize it on the QIIME2 view website, download CSV file 



















