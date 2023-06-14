#!/usr/sbin/anaconda

import argparse
import h5py
import io
import numpy as np
import os
import pandas as pd
import sys

### 03-07-23 ###
# Take in uniq_dars_hits.csv file which has DARs/DEGs pairs with a TFBS
# and the DARs converted to hg19. Also takes in the subsetted vcf file
# generated from plink and checks for any genotypes overlapping DARs
#
# To Run:
# python check_genotypes.py -d <uniq_dars_hits.csv> -g <vcf_new.vcf> -o <output dir>

# ============================================
def parse_my_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-d", "--tfbs_hits", type = str, help = "uniq_dars_hits.csv")
    parser.add_argument("-g", "--vcf_genotypes", type = str, help = "vcf_new.vcf")
    parser.add_argument("-out", "--output_dir", type = str, help = "output directory path")
    return vars(parser.parse_args())

# ============================================
def load_vcf_file(vcf_genotypes):
    with open(vcf_genotypes, 'r') as f:
        lines = [l for l in f if not l.startswith('##')]
    return pd.read_csv(
        io.StringIO(''.join(lines)),
        dtype={'#CHROM': str, 'POS': int, 'ID': str, 'REF': str, 'ALT': str,
               'QUAL': str, 'FILTER': str, 'INFO': str},
        sep='\t'
    ).rename(columns={'#CHROM': 'CHROM'})
  
# ============================================
def overlap_genos_dars(tfbs_df, genos):
    df = pd.DataFrame()
    for dar in tfbs_df["hg19"].to_list():
        print(dar)
        chr = dar.split(":")[0].split("chr")[1]
        start = dar.split(":")[1].split("-")[0]
        stop = dar.split(":")[1].split("-")[1]
        # check if overlaps any genos
        new_row = pd.DataFrame(genos.loc[(genos["CHROM"] == str(chr)) & (genos["POS"] >= int(start)) & (genos["POS"] <= int(stop))])
        df = pd.concat([df, new_row], axis = 0)
    #df = pd.DataFrame(df)
    return df
