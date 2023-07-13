# TFBS-Analysis-For-Multiome-Data

----------
OBJECTIVE
----------
The objective of this pipeline is to identify putative TF regulatory mechanisms focused on differentially accessible genes (DEGs) and differentially accessible chromatin regions (DARs) obtained from single cell multiome analysis, with scRNA-seq and scATAC-seq data.

Adapted to obtain gene coordinates from gencode.v41.annotation.gtf which can be downloaded here: https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz 

### Requirements

**python libraries:** argparse, h5py, io, numpy, os, pandas, sys

**R packages:**  Biostrings, circlize, devtools, gt, IRanges, paletteer, readr, seqinr, TFBSTools, tidyverse

-------------------
STEPS & HOW TO RUN
-------------------

Clone this repository, then enter it and download the gencode.v41.annotation.gtf.gz file:

    cd TFBS-Analysis-For-Multiome-Data
    wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz
    gunzip gencode.v41.annotation.gtf.gz

This is run in three steps:
---------------------------

### **Step 1:** This step is the bulk of the analysis. The automated wrapper script can be run as follows:

    ./Run_TBFS_Analysis_wrapper.sh -g <gene_list.txt> -t <detfs_list.txt> -d <dars_list.txt> -o <output_directory_path>

#### To run Step 1 manually:

#### 1.1) Find gene coordinates

This step takes in a list of genes and uses the gencode.v41.annotation.gtf file to obtained coordinates needed for defining cis-regulatory regions.

    ./scripts/get_deg_coords.sh -g <gene_list.txt> -a <gencode_gtf_file> -o  <output_directory_path>

#### 1.2) Find DARs overlapping gene body (TSS-500kb - TES+100kb)

This step takes in the gene coordinates file from step 1 along with a DARs csv file and an output directory path to generate a file which pairs DEGs with DARs.

    python ./scripts/find_overlapping_dars.py -g <gene_coordinates> -d <dars_file> -out <output_directory_path>

#### 1.3) Get DNA sequence for DARs overlapping DEGs
This step takes in relevant DARs and obtains hg38 reference sequence as a fasta file via UCSC.

    ./scripts/get_seqs.sh -d $dars_degs -o <output_directory_path>

#### 1.4) Query DARs for TFBS

This step takes in the DARs found to overlap DEGs and scan the sequences for potential TFBS for TFs of interest and outputs TFs linked to DEGs via DARs

    ./scripts/query_gene_for_tfbs.sh -d $dars_degs -t $detfs_list -o $output_dir

### **Step 2.)** Generate adjacency matrix

This script generates an adjacency matrix for a selected set of genes and transcription factors to summarize potential regulatory relationships. The output is used for generating a circos plot for visualization.

    python ./create_adj_matrix.py -g <gene_list> -d <detfs_list> -t <Master_Summary.txt> -p <path to TFBS Hits file> -o <output directory path>

### **Step 3.)** Plot interactions as a circos plot

This script takes in the adjacency matrix linking genes and transcription factors to visualize potential regulatory relationships.

    Rscript ./circos_plotter.R <adjacency_matrix.txt>

-----------
Input Files
-----------

**gene_list.txt**: A list of differentially expressed genes (DEGs) of interest, such as a pathway, potential targets of a transcription factor. First columns is "DEG" with the genenames, and the second column is the "avg_log2FC" (see gene_list.txt in the example directory).

**detfs_list.txt**: A list of differentially expressed transcription factors (DETFs) of interest, potential regulators of differentially expressed genes in the gene_list.txt file. Same format as gene_list.txt, with the first columns is "DEG" with the genenames, and the second column is the "avg_log2FC" (see detfs_list.txt in the example directory).

**

