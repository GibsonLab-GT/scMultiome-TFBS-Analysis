#!/usr/sbin/anaconda

import argparse
import numpy as np
import pandas as pd
import sys

# 03-01-2023
# This script takes in DARs and a gene coordinates file
# to find DARs which overlap a gene body
#
# How to run:
# python ./find_overlapping_dars.py -g <gene coordinates file> -d <dars file> -out <output dir path>

# ============================================
def parse_my_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-g", "--gene_coords", type = str, help = "gene coordinates")
    parser.add_argument("-d", "--dars", type = str, help = "differentially accessible regions")
    parser.add_argument("-out", "--output_dir", type = str, help = "output directory path")
    return vars(parser.parse_args())

# ============================================
def get_dars(dars_df, gene, chr, start, stop):
    ## extract DARs in window for this gene
    if start > 0:
        gene_dars = dars_df[(dars_df["seqnames"] == chr) & (dars_df["start"].astype(int) >= start) & (dars_df["end"].astype(int) <= stop)]
        return gene_dars
    else:
        start = 0
        ## extract DARs in window for this gene
        gene_dars = dars_df[(dars_df["seqnames"] == chr) & (dars_df["start"].astype(int) >= start) & (dars_df["end"].astype(int) <= stop)]
        return gene_dars

# ============================================
if __name__ == "__main__":

    # 1.) parse arguments
    args = parse_my_args()
    gene_coords = args["gene_coords"]
    dars = args["dars"]
    outdir = args["output_dir"]

    # 2.) Initiate output data frame:
    col_names = ["DEG", "DEG_AvgLog2FC_Sign",  "DEG_AvgLog2FC", "DAR", "DAR_AvgLog2FC_Sign", "DAR_AvgLog2FC"]
    output_df = pd.DataFrame(columns = col_names)

    # 3.) for each gene, get dars
    genes_df = pd.read_csv(gene_coords, sep = "\t")
    dars_df = pd.read_csv(dars, sep = ",")
    
    for gene in genes_df.Gene:
        print("Finding DARs for gene: " + gene)
        chr = genes_df.loc[genes_df["Gene"] == gene, "CHR"].iloc[0]
        start = genes_df.loc[genes_df["Gene"] == gene, "Start"].iloc[0]
        stop = genes_df.loc[genes_df["Gene"] == gene, "Stop"].iloc[0]
        # use get_dars() function:
        gene_dars = get_dars(dars_df, gene, chr, start, stop)
        # format output
        dar = gene_dars["seqnames"].astype(str) + ":" + gene_dars["start"].astype(str) + "-" + gene_dars["end"].astype(str)
        dar_log2FC = gene_dars["Log2FC"]
        dar_sign = np.sign(dar_log2FC)
        deg_log2FC = genes_df.loc[genes_df["Gene"] == gene, "DEG_avgLog2FC"].iloc[0]
        deg_sign = np.sign(deg_log2FC)
        # create temp df for gene
        temp_dict = {
                "DEG": [gene]*len(dar),
                "DEG_AvgLog2FC_Sign": [deg_sign]*len(dar),
                "DEG_AvgLog2FC": [deg_log2FC]*len(dar),
                "DAR" : dar.tolist(),
                "DAR_AvgLog2FC_Sign" : dar_sign.tolist(),
                "DAR_AvgLog2FC" : dar_log2FC.tolist()
                }
        temp_df = pd.DataFrame.from_dict(data = temp_dict)
        # add temp df to output_df
        output_df = pd.concat([output_df, temp_df])

    # 4.) write to output
    filename = outdir + "dars_degs.txt"
    output_df.to_csv(filename, index=None, sep='\t', mode='w')
    
    print("Done! Output is located here: " + filename)
