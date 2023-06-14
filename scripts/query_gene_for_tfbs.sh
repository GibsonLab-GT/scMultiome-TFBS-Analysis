#!/usr/bin/bash

# This script takes a gene of interest (must be a DEG overlapping a DAR)
# and identifies which DETF's could potentially be interacting with that gene
#
# To Run:
# ./query_gene_for_tfbs.sh -d <dars_degs> -t <tf list> -o <output dir>

while getopts "d:t:o:" option
do
        case $option in
                d) dars_degs=$OPTARG;;
                t) detfs_list=$OPTARG;;
                o) output_dir=$OPTARG;;
        esac
done

jaspar="./JASPAR2020/All_TF_Profiles.txt"
Rscript="/storage/home/mfisher42/bin/R-4.2.2/bin/Rscript"

# 1.) Subset PWM from JASPAR for DETFs of interest

tfs_list="$(awk '{if (NR > 1) {print $1}}' $detfs_list | sort | uniq)"

for detf in $tfs_list
do	
	echo $detf
	# Get motif ID for each TF; sometimes a TF will have more than one
	motif_ids="$(awk -v g=$detf '{if ($2==g) {print $1}}' $jaspar)"
	# account for TFs with no pwm in JASPAR
	if [ -z "$motif_ids" ]
	then
		echo "No motifs for $detf"
	else
		for motif in $motif_ids
		do
			#echo $motif
			# get TF motif ID; sometimes a TF will have more than one
			row="$(awk -v m=$motif '{if ($1==m) {print NR}}' $jaspar)"
			pwm="$(awk -v r=$row 'NR==r, NR==r+4' $jaspar)" # print range of lines for pwm
			echo -e "$pwm" >> $output_dir/pwms_subset.txt
		done
	fi
done

# 2.) Run TFBSTools for all DARs

mkdir $output_dir/TFBS_Hits
$Rscript ./scripts/run_TFBSTools.R $output_dir/pwms_subset.txt $output_dir/fasta_files $output_dir/TFBS_Hits/

# 3.) Generate a "Master" summary table

# For each DEG and DAR pair, get TFBS info
echo -e "DEG\tDEG_AvgLog2FC\tDAR\tDAR_AvgLog2FC\tDETF\tDETF_AvgLog2FC\tMotif_ID\tStrand\tsiteSeq" > $output_dir/TFBS_Hits/Master_Summary.txt

len="$(wc -l $dars_degs | awk '{print $1}')"

line=2
while [ $line -le $len ]
do
	# DEG info:
	deg="$(awk -v l=$line '{if (NR==l) {print $1}}' $dars_degs)"
	deg_avglog2fc="$(awk -v l=$line '{if (NR==l) {print $3}}' $dars_degs)"
	# DAR info
	dar="$(awk -v l=$line '{if (NR==l) {print $4}}' $dars_degs)"
	dar_avglog2fc="$(awk -v l=$line '{if (NR==l) {print $6}}' $dars_degs)"
	# Get TFBS Hits info 
	tfbs_file="$output_dir/TFBS_Hits/"$dar"_TFBS_Hits.txt"

	m="$(wc -l $tfbs_file | awk '{print $1}')"
	m1="$(echo $(($m / 2)))"
	j=2
	while [ $j -lt $m1 ]
	do
		lineID="$(awk '{if (NR == '$j') {print $1}}' $tfbs_file)"
		# get everything on one line
		awk -v d=$lineID '{if ($1 == d) {print}}' $tfbs_file | awk '{if (NR == 1) {print}}' > $output_dir/TFBS_Hits/temp1.txt
		awk -v d=$lineID '{if ($1 == d) {print}}' $tfbs_file | awk '{if (NR == 2) {print}}' | cut -d " " -f 2- > $output_dir/TFBS_Hits/temp2.txt
		paste -d"\t" $output_dir/TFBS_Hits/temp1.txt $output_dir/TFBS_Hits/temp2.txt > $output_dir/TFBS_Hits/temp3.txt

		profile="$(awk '{print $10}' $output_dir/TFBS_Hits/temp3.txt)"
		tf="$(awk '{print $11}' $output_dir/TFBS_Hits/temp3.txt)"
		relscore="$(awk '{print $8}' $output_dir/TFBS_Hits/temp3.txt)"
		strand="$(awk '{print $9}' $output_dir/TFBS_Hits/temp3.txt)"
		seq="$(awk '{print $13}' $output_dir/TFBS_Hits/temp3.txt)"
		# get TF avglog2fc
		tf_avglog2fc="$(awk -v t=$tf '{if ($1 == t) {print $2}}' $detfs_list)"

		# write to output file
		echo -e "$deg\t$deg_avglog2fc\t$dar\t$dar_avglog2fc\t$tf\t$tf_avglog2fc\t$profile\t$strand\t$seq" >> $output_dir/TFBS_Hits/Master_Summary.txt

		j=$[$j+1]

	done
	rm $output_dir/TFBS_Hits/temp*txt

	# next line
	line=$(( $line +1 ))
done





								
