# Final-Project
GC Content Analysis to Detect Pathogenicity of E. coli

Project Question: Can pathogenic genes acquired through horizontal gene transfer be identified in E. coli using GC content patterns? 


Approach: Using NCBI GenBank and Ensembl, we will gather E. coli genomic sequences from three environments: human gut, clinical sample, and contaminated water. We will compute GC content for whole genomes and use a 500 base pair sliding window to identify and compare GC-rich/poor regions. 

How SRR/ERR were obtained:

- Used: https://www.ncbi.nlm.nih.gov/sra
- In the search bar, entered the organism and strain we were interested in (e.g., E. coli K-12 MG1655).
- Selected 30 samples.
- Clicked "Send to," then selected "File."
- Changed the format to "Accession List."
- Downloaded the list.
- Added the SRR/ERR to the repository.


1. Data Retrieval:
NCBI GenBank: https://www.ncbi.nlm.nih.gov/genbank/
Ensembl: https://www.ensembl.org/
NCBI E-utilities (Entrez Direct): https://www.ncbi.nlm.nih.gov/books/NBK179288/
NCBI Genome Downloader: https://github.com/kblin/ncbi-genome-download

2. Data Processing & Analysis:
Biopython: https://biopython.org/
Pandas: https://pandas.pydata.org/
NumPy: https://numpy.org/

3. Visualization:
Matplotlib: https://matplotlib.org/
Seaborn: https://seaborn.pydata.org/
Jupyter Notebook: https://jupyter.org/

4. Version Control & Reproducibility:
GitHub: https://github.com/
