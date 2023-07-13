#!/usr/sbin/anaconda

import argparse
import h5py
import io
import numpy as np
import os
import pandas as pd
import sys

### 03-12-23 ###
# This script generates an adjacency matrix
# for circos plot input
#
# To run:
# python ./create_adj_matrix.py -g <gene_list> -d <detfs_list> -t <Master_Summary.txt> -p <path to TFBS Hits file> -o <output directory path> 

# ============================================
def parse_my_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-g", "--gene_list", type = str, help = "gene_list.txt")
    parser.add_argument("-d", "--detfs_list", type = str, help = "detfs_list.txt")
    parser.add_argument("-t", "--tfbs_summary", type = str, help = "Master_Summary.txt")
    parser.add_argument("-p", "--tfbs_hits_path", type = str, help = "path to TFBS Hits files")
    parser.add_argument("-out", "--output_dir", type = str, help = "output directory path")
    return vars(parser.parse_args())

# ============================================
def get_relscores(dars_list, detf, tfbs_hits_path):
    # get dar_TFBS_Hits.txt file for dar
    dar_relscores = []
    for dar in dars_list:
        filename = tfbs_hits_path + "/" + dar + "_TFBS_Hits.txt"
        # Adjust for extra spaces
        data = []
        with open(filename) as fp:
            lines = fp.read()
            data = lines.split('\n')
        df_data = []
        for item in data:
            item = item.split(' ')
            item = list(filter(None, item))
            df_data.append(item)
        tfbs_df = pd.DataFrame(df_data)
        # fix format
        nrow = len(tfbs_df.index) - 1
        top_df = tfbs_df.iloc[1:int(nrow/2)]
        bottom_df = tfbs_df.iloc[int(nrow/2+1):nrow, 0:6]
        final_df = pd.merge(top_df, bottom_df, on = 0)
        final_df = final_df.dropna(axis = 1)
        final_df.columns = ["RowID", "DAR", "source", "feature", "start", "end", "absScore", "relScore", "strand", "ID", "TF", "class", "siteSeqs"]
        # get relScores for DETF
        detf_df = final_df[final_df["TF"] == detf]
        detf_df["relScore"] = pd.to_numeric(detf_df["relScore"], downcast = "float")
        dar_relscores.extend(detf_df["relScore"].to_list())
    # get mean relscore for this TF on this gene
    average_relscore = np.mean(dar_relscores)
    return average_relscore

# ============================================
def get_gene_hits(gene, detfs_df, tfbs_df, tfbs_hits_path):
    # subset tfbs_df for target gene
    sub_tfbs = tfbs_df[tfbs_df["DEG"] == gene]
    # filter for only up regulated DETFs
    sub_tfbs = sub_tfbs[sub_tfbs["DETF_AvgLog2FC"] > 0]
    # filter for only open chromatin
    sub_tfbs = sub_tfbs[sub_tfbs["DAR_AvgLog2FC"] > 0]
    # for each DETF, get average relscore
    detf_relscores = {}
    for detf in set(sub_tfbs["DETF"].to_list()):
        # get list of dars for each detf
        dars_list = set(sub_tfbs[sub_tfbs["DETF"] == detf]["DAR"].to_list())
        # get rel scores for each time a TF hits DAR
        avg_relscore = get_relscores(dars_list, detf, tfbs_hits_path)
        detf_relscores[detf] = avg_relscore
    return detf_relscores

# ============================================
if __name__ == "__main__":

    # 1.) parse arguments
    args = parse_my_args()
    gene_list = args["gene_list"]
    detfs_list = args["detfs_list"]
    tfbs_summary = args["tfbs_summary"]
    tfbs_hits_path = args["tfbs_hits_path"]
    outdir = args["output_dir"]

    # 2.) load in files:
    gene_df = pd.read_csv(gene_list, sep = "\t")
    detfs_df = pd.read_csv(detfs_list, sep = "\t")
    tfbs_df = pd.read_csv(tfbs_summary, sep = "\t")

    # 3.) For each gene, get avg relscore for each TF
    tfbs_hits = {}
    for gene in gene_df["DEG"].to_list():
        relscores = get_gene_hits(gene, detfs_df, tfbs_df, tfbs_hits_path) # returned as a dict: {detf: score}
        tfbs_hits[gene] = relscores

    summary_df = (pd.DataFrame.from_dict(tfbs_hits)).transpose()
    summary_df = summary_df.dropna(axis = 1, how = "all") # remove empty columns

    # check empty rows; if gene name not a column name and entire row is empty, remove.
    empty_rows = summary_df.index[summary_df.isnull().all(1)].tolist()

    for gene in empty_rows:
        if gene not in summary_df.columns.tolist():
            summary_df = summary_df.drop(gene)

    # 4.) Add DEG AvgLog2FC to first column
    summary_df["DEG"] = summary_df.index
    final_df = pd.merge(gene_df, summary_df, on = "DEG")

    # 4.) write to output:
    filename = outdir + "/adjacency_matrix.txt"
    final_df.to_csv(filename, index = None, sep = "\t", mode = "w")


