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

    ./Rscript ./circos_plotter.R adjacency_matrix.txt

## Intermediate Files & Directories ##

### 1.) genelist_coords.txt:
Gene coordinates for DEGs from gene_list.txt obtained from gencode.v41.annotation.gtf

    Gene: gene name
    DEG_avgLog2FC: avg_Log2FC from previous differential testing
    CHR: chromosome location
    TSS: transcription start site
    TES: transcription end site
    Start: start of cis-regulatory region (TSS-500kb), used for defining cis-regulatry window
    Stop: stop of cis-regulatory region (TES+100kb), used for defining cis-regulatry window

### 2.) dars_degs.txt:
Paired differentially accessible regions (DARs) with differentially expressed genes (DEGs) based on cis-regulatory windows.

    DEG: gene name
    DEG_AvgLog2FC_Sign: 1.0 for positive value, -1.0 for negative value
    DEG_avgLog2FC: avg_Log2FC from previous differential testing
    DAR: differentially accessible region coordinates
    DAR_AvgLog2FC_Sign: 1.0 for positive value, -1.0 for negative value
    DAR_AvgLog2FC: avg_Log2FC from previous differential testing

### 3.) fasta_files:
Directory containing fasta files obtained from hg38 for each DAR.

### 4.) pwms_subset.txt:
List of positional weight matricies for each transcription factor of interest, obtained from JASPAR2020.

Example:

    >MA0112.1	ESR1
    
    A  [1      1      7      2      0      0      0      6      1      2      3      1      1      5      0      0      2      3 ]

    C  [5      5      1      0      0      0      7      0      7      5      2      1      0      1      8      9      4      4 ]

    G  [1      1      1      7      9      0      2      2      1      1      4      1      8      3      0      0      0      1 ]

    T  [2      2      0      0      0      9      0      1      0      1      0      6      0      0      1      0      3      1 ]

### 5.) TFBS_Hits:
Directory containing:

i.) all TFBS hits: output from TFBSTools scanning all TF's in each DAR. Each DAR result has it's own file with potential TF binding sites. Named like **chr1:999925-1000425_TFBS_Hits.txt**

ii.) **Master_Summary.txt:** summary output for TF binding site predictions in DARs. Each Row is a unique TF and DAR pairing.

    DEG: target gene name
    DEG_AvgLog2FC: avg_Log2FC from previous differential testing
    DAR: differentially accessible region coordinates
    DAR_AvgLog2FC: avg_Log2FC from previous differential testing
    DETF: differentially expressed TF with potential binding site in DAR
    DETF_AvgLog2FC: avg_Log2FC expression for differentially expressed TF
    Motif_ID: motif ID used to detect potential binding site of TF in DAR
    Strand: DNA strand (+/-)
    siteSeq: the sequence of the potential binding site

    


    

    
