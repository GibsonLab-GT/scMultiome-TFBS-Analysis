# scMultiome-TFBS-Analysis 

## Working Example

This is a working example to see how differentially expressed transcription factors may be regulating each other.


Clone this repository, then enter it and download the gencode.v41.annotation.gtf.gz file:

    cd scMultiome-TFBS-Analysis 
    wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz
    gunzip gencode.v41.annotation.gtf.gz
    
**Step 1:** Run the automated pipeline on the example data:

    ./Run_TBFS_Analysis_wrapper.sh -g example/gene_list.txt -t example/detfs_list.txt -d example/dars_list.csv -o $PWD/example/Results/

**Step 2:** Generate adjacency matrix for plot:

    python ./create_adj_matrix.py -g example/gene_list.txt -d example/detfs_list.txt -t example/Results/TFBS_Hits/Master_Summary.txt -p $PWD/example/Results/TFBS_Hits -o $PWD/example/Results/

**Step 3:** Generate circos plot:

    Rscript ./circos_plotter.R $PWD/example/Results/adjacency_matrix.txt

The working example should produce the plot below. The broken inner circle indicates a starting point of a TF to target gene relationship. For example, the TF PRDM1 has blue line starting from the inner broken circle that connects to KLF2, suggesting that PRDM1 has a TF binding site in a DAR within the cis-regulatory window for KLF2. The colors indicate the avgLog2FC from a differential comparison (ie. the DEG avgLog2FC), so red genes indicate genes which have a positive avgLog2FC and blue indicate genes with a negative avgLog2FC. 

<p align="center">
    <img src="https://github.com/GibsonLab-GT/scMultiome-TFBS-Analysis/blob/main/circos_plot.jpg" width = 600 height = 600>
</p>


    

    
