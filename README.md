# Final-Project
GC Content Analysis to Detect Pathogenicity of E. coli

Project Question: Can pathogenic genes acquired through horizontal gene transfer be identified in E. coli using GC content patterns? 


Approach: Using NCBI GenBank and Ensembl, we will gather E. coli genomic sequences from three environments: human gut, clinical sample, and contaminated water. We will compute GC content for whole genomes and use a 500 base pair sliding window to identify and compare GC-rich/poor regions. 


STEP 2
How SRR/ERR were obtained:

- Used: https://www.ncbi.nlm.nih.gov/sra
- In the search bar, entered the organism and strain we were interested in (e.g., E. coli K-12 MG1655).
- Selected 30 samples.
- Clicked "Send to," then selected "File."
- Changed the format to "Accession List."
- Downloaded the list.
- Added the SRR/ERR to the repository.


STEP 3
Data Retrieval: sra-toolkit, rclone
Preprocessing: FastQC, Trimmomatic
GC Content Calculation: fastx-toolkit, bedtools
Visualization: python/3.8.6, matplotlib
Gene Annotation: GeneMark-ES, prokka
Pathogenicity Assessment: CheckM
Comparative Analysis: bedtools

- all in HPC
