#!/usr/bin/bash

# 03-01-2023
# This script takes a gene of interest (must be a DEG overlapping a DAR)
# and identifies which DETF's could potentially be interacting with that gene
#
# To Run:
# ./Run_TFBS_Analysis_wrapper.sh -g <gene list> -t <tf list> -d <differentially accessible regions> -o <output dir>
#
# Order of operations:
# 1.) Get genomic coordinates for gene in gene list: get_deg_coords.sh
# 2.) Find DARs overlapping gene body (TSS-500kb - TES+100kb): find_overlapping_dars.py
# 3.) Get DNA sequence for DARs overlapping DEGs: get_seqs.sh
# 4.) Query DARs for TFBS: query_gene_for_tfbs.sh, run_TFBSTools.R
# 5.) Construct adjacency matrix for linking TFs to DEGs via DARs: TBD

while getopts "g:t:d:o:" option
do
        case $option in
                g) gene_list=$OPTARG;;
                t) detfs_list=$OPTARG;;
                d) dars_file=$OPTARG;;
                o) output_dir=$OPTARG;;
        esac
done

# ======= 1.) Get genomic coordinates for gene in gene list =======
# This step takes in a list of degs with their avglog2FC values, gencode annotations file,
# and an output directory path to generate a file which lists the coordinates
# for each gene of interest.

genecode="gencode.v41.annotation.gtf"

echo "STEP 1 of 5: Finding gene coordinates"
./scripts/get_deg_coords.sh -g $gene_list -a $genecode -o $output_dir

# ======= 2.) Find DARs overlapping gene body (TSS-500kb - TES+100kb) =======
# This step takes in the gene coordinates file from step 1 along with a DARs csv file
# and an output directory path to generate a file which pairs DEGs with DARs

gene_coords="$output_dir"genelist_coords.txt

echo "STEP 2 of 5: Overlapping DARs"
python ./scripts/find_overlapping_dars.py -g $gene_coords -d $dars_file -out $output_dir

# ======= 3.) Get DNA sequence for DARs overlapping DEGs =======
# This step takes in relevant DARs and obtains hg38 reference
# sequence as a fasta file via UCSC

dars_degs="$output_dir/dars_degs.txt"

echo "STEP 3 of 5: Getting DNA sequences"
./scripts/get_seqs.sh -d $dars_degs -o $output_dir

# ======= 4.) Query DARs for TFBS =======
# This step takes in the DARs found to overlap DEGs
# and scan the sequences for potential TFBS for TFs
# of interest and outputs TFs linked to DEGs via DARs

echo "STEP 4 of 5: Querying gene's DARs for TFBS"
./scripts/query_gene_for_tfbs.sh -d $dars_degs -t $detfs_list -o $output_dir
