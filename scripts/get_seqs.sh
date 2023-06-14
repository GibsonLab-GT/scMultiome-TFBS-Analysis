#!/usr/bin/bash

# Get hg38 ref seqs for each DAR
# Take in dars_degs.txt output
#
# How to run:
# ./get_seqs.sh -d <dars_degs.txt> -o <output dir>


while getopts "d:o:" option
do
        case $option in
                d) dars_degs=$OPTARG;;
                o) output=$OPTARG;;
        esac
done

mkdir $output/fasta_files
dars_list="$(awk '{if (NR > 1) {print $4}}' $dars_degs | sort | uniq)"

for dar in $dars_list
do
	chr=${dar%:*}
	region=${dar#*:}
	start=${region%-*}
	stop=${region#*-}
	echo $chr $start $stop
	# get sequence as fasta file
	wget -P $output/fasta_files http://togows.org/api/ucsc/hg38/$chr:$start-$stop.fasta
done
