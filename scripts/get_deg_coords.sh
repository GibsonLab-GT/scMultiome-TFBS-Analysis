#/usr/bin/bash

# 03-01-2023
# This script obtains the gene coordiantes for a list of DEGs
# from genecode and outputs a table containing a window 
# around the gene body to use for TFBS analysis
# The window for this analysis is: TSS-500kb and TES+100kb

# to run without wrapper script:
# ./get_deg_coords.sh -g <gene_list> -a <gencode annotations> -o <output dir>

while getopts "g:a:o:" option
do
        case $option in
                g) gene_list=$OPTARG;;
                a) annotations=$OPTARG;;
                o) output=$OPTARG;;
        esac
done

genes="$(awk '{if (NR>1) {print $1}}' $gene_list | sort | uniq)"

echo -e "Gene\tDEG_avgLog2FC\tCHR\tTSS\tTES\tStart\tStop" > $output/genelist_coords.txt

for gene in $genes
do
	echo "Getting coordinates for $gene"
	# get chr, tss, tes
	chr="$(awk '{if ($3=="gene") {print}}' $annotations | sed 's/"//g' | sed 's/;//g' | awk -v g=$gene '{if ($14==g) {print $1}}')"
	# check if gene in file by length of chr
	length="$(echo $chr | wc -c)"
	if [ $length -gt 2 ]
	then
		tss="$(awk '{if ($3=="gene") {print}}' $annotations | sed 's/"//g' | sed 's/;//g' | awk -v g=$gene '{if ($14==g) {print $4}}')"
		tes="$(awk '{if ($3=="gene") {print}}' $annotations | sed 's/"//g' | sed 's/;//g' | awk -v g=$gene '{if ($14==g) {print $5}}')"
		# compute window around gene body
		start="$(echo "$(($tss-500000))")"
		stop="$(echo "$(($tes+100000))")"
	else
		echo "$gene not in annotations file"
	fi
	# get avgLog2FC value
	avglog2fc="$(awk -v g=$gene '{if ($1==g) {print $2}}' $gene_list)" 
	echo -e "$gene\t$avglog2fc\t$chr\t$tss\t$tes\t$start\t$stop" >> $output/genelist_coords.txt
done


