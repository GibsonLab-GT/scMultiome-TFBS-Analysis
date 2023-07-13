# scMultiome-TFBS-Analysis 

## Working Example


Clone this repository, then enter it and download the gencode.v41.annotation.gtf.gz file:

    cd scMultiome-TFBS-Analysis 
    wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz
    gunzip gencode.v41.annotation.gtf.gz
    
**Step 1:** Run the automated pipeline on the example data:

    ./Run_TBFS_Analysis_wrapper.sh -g example/gene_list.txt -t example/detfs_list.txt -d example/dars_list.csv -o $PWD/example/Results/

**Step 2:** Generate adjacency matrix for plot:

    python ./create_adj_matrix.py -g example/gene_list.txt -d example/detfs_list.txt -t example/Results/TFBS_Hits/Master_Summary.txt -p $PWD/example/Results/TFBS_Hits -o $PWD/example/Results/

**Step 3:** Generate circos plot:

