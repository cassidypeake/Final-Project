# Final-Project
GC Content Analysis to Detect Pathogenicity of E. coli

Project Question: Can pathogenic genes acquired through horizontal gene transfer be identified in E. coli using GC content patterns? 


Approach: Using NCBI GenBank and Ensembl, we will gather E. coli genomic sequences from three environments: human gut, clinical sample, and contaminated water. We will compute GC content for whole genomes and use a 500 base pair sliding window to identify and compare GC-rich/poor regions. 


STEP 2
How SRR/ERR were obtained:

- Used: https://www.ncbi.nlm.nih.gov/sra
- In the search bar, entered the organism and strain we were interested in (e.g., E. coli K-12 MG1655).
- Selected 10 samples.
- Clicked "Send to," then selected "File."
- Changed the format to "Accession List."
- Downloaded the list.
- Added the SRR/ERR to the repository.

STEP 3 (all in HPC)
- Data Retrieval: sra-toolkit, rclone
- Preprocessing: FastQC, Trimmomatic
- GC Content Calculation: biopython (had to download)
- Visualization: python/3.8.6, matplotlib


## Assuming that your fastq files are all in a single folder called `fastq_files`
- Download reference genome for assemblies
```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/865/GCF_000008865.2_ASM886v2/GCF_000008865.2_ASM886v2_genomic.fna.gz
gunzip GCF_000008865.2_ASM886v2_genomic.fna.gz
mv GCF_000008865.2_ASM886v2_genomic.fna ecoli_ref.fasta
```
- Create script to assemble genomes into single fasta files
```
vi assembly.slurm
```
- type I to edit and paste:
```
#!/bin/bash
#SBATCH --job-name=bowtie_gc
#SBATCH --output=bowtie_gc_%A_%a.out
#SBATCH --error=bowtie_gc_%A_%a.err
#SBATCH --array=0-29
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rmgarbar@svsu.edu

module load bowtie2
module load samtools
module load bcftools
module load bedtools

# Directories
mkdir -p bam_outputs consensus_fastas gc_windows

# Reference genome (FASTA)
REF="ecoli_ref.fasta"
REF_PREFIX="ecoli_ref"

# FASTQ folder
FASTQ_DIR="fastq_files"

# Build Bowtie2 index once (in array task 0)
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
  if [ ! -e "${REF_PREFIX}.1.bt2" ]; then
    echo "Building Bowtie2 index..."
    bowtie2-build "$REF" "$REF_PREFIX"
  else
    echo "Index already exists, skipping."
  fi
  # Let other tasks wait
  sleep 60
fi

# Sample selection
SAMPLES=($(ls ${FASTQ_DIR}/*_1.fastq | sed 's|.*/||' | sed 's/_1.fastq//' | sort))
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
FQ1="${FASTQ_DIR}/${SAMPLE}_1.fastq"
FQ2="${FASTQ_DIR}/${SAMPLE}_2.fastq"

echo "Processing $SAMPLE"

# Step 1: Align with Bowtie2
bowtie2 -x "$REF_PREFIX" -1 "$FQ1" -2 "$FQ2" -p $SLURM_CPUS_PER_TASK | \
  samtools view -@ $SLURM_CPUS_PER_TASK -bS - | \
  samtools sort -@ $SLURM_CPUS_PER_TASK -o "bam_outputs/${SAMPLE}.sorted.bam"

samtools index "bam_outputs/${SAMPLE}.sorted.bam"

# Step 2: Variant calling
bcftools mpileup -Ou -f "$REF" "bam_outputs/${SAMPLE}.sorted.bam" | \
  bcftools call -mv -Oz -o "gc_windows/${SAMPLE}.vcf.gz"
bcftools index "gc_windows/${SAMPLE}.vcf.gz"

# Step 3: Generate consensus FASTA
bcftools consensus -f "$REF" "gc_windows/${SAMPLE}.vcf.gz" > "consensus_fastas/${SAMPLE}.fasta"

# Step 4: GC content in 500 bp windows
samtools faidx "consensus_fastas/${SAMPLE}.fasta"
bedtools makewindows -g "consensus_fastas/${SAMPLE}.fasta.fai" -w 500 > "gc_windows/${SAMPLE}_windows.bed"
bedtools nuc -fi "consensus_fastas/${SAMPLE}.fasta" -bed "gc_windows/${SAMPLE}_windows.bed" > "gc_windows/${SAMPLE}_gc.tsv"

echo "✅ Finished $SAMPLE"
```
- All e.coli genomes are in folder consensus_fastas
- All GC counts are in folder gc_windows

## Create metadata file is you dont have it already
```
vi sources.tsv
```
- Type I to edit and paste:
```
Sample	Source
DRR033878	Clinical
DRR033877	Clinical
DRR033876	Clinical
DRR033875	Clinical
DRR033874	Clinical
DRR033873	Clinical
DRR033872	Clinical
DRR033871	Clinical
DRR033870	Clinical
DRR033869	Clinical
SRR13693699	Gut
SRR13693733	Gut
SRR13693732	Gut
SRR13693731	Gut
SRR13693730	Gut
SRR13693729	Gut
SRR13693703	Gut
SRR13693702	Gut
SRR13693701	Gut
SRR13693700	Gut
SRR10131017	Water
SRR10419063	Water
SRR10419114	Water
SRR10419386	Water
SRR10451708	Water
SRR10420100	Water
SRR10451711	Water
SRR10451712	Water
SRR10451718	Water
SRR10451709	Water
```
- Exit vi editor
- Create new scrip to merge all GC counts
```
vi merge_gc_with_sources.sh
```
- type I to edit and paste:
```
#!/bin/bash

# Read sample→source mapping into an associative array
declare -A SOURCE
while IFS=$'\t' read -r sample source; do
  SOURCE[$sample]=$source
done < <(tail -n +2 sources.tsv)

# Write header
echo "Sample,Source,Contig,Start,End,GC_Content" > gc_merged.csv

# Loop through files and add source info
for f in gc_windows/*_gc.tsv; do
  sample=$(basename "$f" _gc.tsv)
  src=${SOURCE[$sample]}
  awk -v s="$sample" -v src="$src" 'NR > 1 { print s","src","$1","$2","$3","$5 }' "$f" >> gc_merged.csv
done
```
- run script
```
bash merge_gc_with_sources.sh
```
- Push  gc_merged.csv file

## Visualization in RStudio
- Create new project
- Create new directory
- Place gc_merged.csv in current directory
- File new scrip
- Paste script:
```R
# Auto-install required packages if missing
required_packages <- c("dplyr", "ggplot2")
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages)

# Load libraries
library(dplyr)
library(ggplot2)

# Read GC data
df <- read.csv("gc_merged.csv")
df$GC_percent <- df$GC_Content * 100

# Flag outliers using z-score method
df <- df %>%
  group_by(Sample) %>%
  mutate(zscore = (GC_percent - mean(GC_percent)) / sd(GC_percent),
         is_outlier = abs(zscore) > 2)

# Plot GC content with outliers in red
ggplot(df, aes(x = Start, y = GC_percent, group = Sample)) +
  geom_line(aes(color = Source), alpha = 0.5) +
  geom_point(data = filter(df, is_outlier), color = "red", size = 0.7) +
  facet_wrap(~ Sample, scales = "free_x") +
  labs(x = "Genome Position", y = "GC Content (%)", color = "Source") +
  theme_minimal()

```

# Lets look for outliers in R. We are gonna use the z-score
- Z-score interpretation:
```
Z-score	Interpretation
0	Exactly average (same as the mean)
±0.5	Slightly above or below average
±1	1 SD from the mean (about 68% of data falls within ±1 SD)
±2	Farther out, but still normal (95% of data falls within ±2 SD)
±3 or more	Unusual/extreme (only 0.3% of data beyond ±3 SD)
```
This is the code to build an outliers plot with z-score greater than 3, we will call them "Atypical GC content".

```
library(dplyr)
library(ggplot2)

# Read and prepare data
df <- read.csv("gc_merged.csv")
df$GC_percent <- df$GC_Content * 100

# Identify outliers per sample using Z-score
df <- df %>%
  group_by(Sample) %>%
  mutate(z = scale(GC_percent),
         is_outlier = abs(z) > 3)

# Summarize proportion of outliers per sample
summary_df <- df %>%
  group_by(Sample, Source) %>%
  summarise(
    total_windows = n(),
    outlier_windows = sum(is_outlier),
    prop_outlier = outlier_windows / total_windows
  )

# boxplot
ggplot(summary_df, aes(x = Source, y = prop_outlier, fill = Source)) +
  geom_boxplot(width = 0.5, alpha = 0.7, outlier.shape = NA) +
  geom_jitter(aes(color = Source), width = 0.15, size = 2.5, alpha = 0.8) +
  labs(
    title = "Proportion of Atypical GC Windows by Sample Source",
    x = "Sample Source",
    y = "Proportion of GC Outliers [abs(z) > 3]"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")
```
- Note that the number in this line must be changed to modify the z-score: is_outlier = abs(z) > 3)
- If a different z-score is used, the title of the x axis should be changed as well: y = "Proportion of GC Outliers [abs(z) > 3]

