#!/bin/bash -login

#date created: 4/8/2019
#date modified: 8/31/2022 (Added .qsv export)

#Hinako Terauchi 

#This is part 4 of second attempt at submission script of QIIME2 to HPCC

#In this script, it will import taxnomy reference file and classify taxonomy, ,then create a barplot 

#This is the last of the QIIME2 script series 

###################################################################

#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name QIIME2_16SV4_Analysis_Part4

####################################################################
#Script

#Initializing anaconda environment
conda init bash

#activating QIIME2 software
conda activate qiime2-2022.2

#**Importing taxonomy data**
# (Change the input-path for `PROJECT_DIR` below)
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ~/PROJECT_DIR/SILVA_128_QIIME_release/taxonomy/16S_only/97/majority_taxonomy_all_levels.txt --output-path ref-taxonomy.qza

#**Importing consensus taxonomy file**
# (Change the input-path for `PROJECT_DIR` below)
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ~/PROJECT_DIR/SILVA_128_QIIME_release/taxonomy/16S_only/97/consensus_taxonomy_all_levels.txt --output-path consensus_ref_taxonomy.qza

#Classifying taxonomy to chimera-filtered sequences
qiime feature-classifier classify-consensus-vsearch --i-query uchime-dn-out/rep-seqs-nonchimeric-wo-borderline.qza --i-reference-reads SILVA97-reference.qza --i-reference-taxonomy consensus_ref_taxonomy.qza --o-classification taxonomy_output.qza

#Generating visualized file of taxonomy classification
qiime metadata tabulate --m-input-file taxonomy_output.qza  --o-visualization taxonomy_output.qzv

# Exporting taxonomy_output.qzv:
qiime tools export --input-path taxonomy_output.qzv --output-path exportFiles/taxonOutput

#Creating Barplot:
qiime taxa barplot --i-table uchime-dn-out/table-nonchimeric-wo-borderline.qza --i-taxonomy taxonomy_output.qza --o-visualization barplot.qzv

# Export barplot.qzv:
## once complete, go into /exportedFiles/barplot and obtain level-6.csv
qiime tools export --input-path barplot.qzv --output-path exportFiles/barplot 












