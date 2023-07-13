#!/opt/anaconda3/bin/Rscript

library(devtools)
library(IRanges)
library(TFBSTools)
library(seqinr)
library(Biostrings)

# This script takes in:
# 1.) a subsetted PWM file for DETFs from JASPAR
# 2.) fasta files of sequences for DARs if interest
# And identifies if any DARs have a potential TFBS

# To Run:
# Rscript ./run_TFBSTools.R <pwm file> <path to fasta files dir> <output dir>

args = commandArgs(trailingOnly=TRUE)

print(args)

# Read in PWM
jaspar2020 <- readJASPARMatrix(args[1])
jasp_pwm <- toPWM(jaspar2020, type= "prob", pseudocounts = 0.8)

# Get Fasta Files
#fasta_files <- args[2]
setwd(args[2])
fl=list.files(pattern = c("chr", ".fa"))

print(fl)

# Get output dir
output_dir <- args[3]

# For each fasta file, search seq
for (i in 1:length(fl)){
        seqsfa <- readDNAStringSet(fl[i])
        # query search
        siteset <- searchSeq(jasp_pwm, seqsfa, strand = "*", min.score = "80%")
        # designate output for TFBS
        DAR <- substr(fl[i], 1, nchar(fl[i])-6)
        fileHits <- paste(output_dir, DAR, "_TFBS_Hits.txt", sep = "")
        sink(fileHits);print(as(siteset, "data.frame"));sink()
        # desginate output for p-values
        #filePvals <- paste(output_dir, DAR, "_TFBS_Pvalues.txt", sep = "")
        #sink(filePvals);print(pvalues(siteset, type="sampling"));sink()
}







