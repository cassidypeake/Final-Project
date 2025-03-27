#!/bin/bash

# Define SRR samples for each strain
STRAIN_1=("ERR14720522" "ERR14720523" "ERR14720526" "ERR14720527" "ERR14720528" "ERR14720529" "ERR14720530" "ERR14720531" "ERR14720533" "ERR14720536" 
          "ERR14720537" "ERR14720538" "ERR14720539" "ERR14720540" "ERR14720541" "ERR14720543" "SRR32702239" "SRR32702240" "SRR32865946" "SRR32865947" 
          "SRR32865948" "SRR32865949" "SRR32865950" "SRR32865951" "SRR32865952" "SRR32865953" "SRR32865954" "SRR32865955" "SRR32865956" "SRR32865957")

STRAIN_2=("SRR32571435" "SRR32571437" "SRR32571438" "SRR32571439" "SRR32571440" "SRR32571441" "SRR32571442" "SRR32571443" "SRR32571444" "SRR32571445"
          "SRR32571446" "SRR32571447" "SRR32571448" "SRR32571449" "SRR32571450" "SRR32571451" "SRR32571452" "SRR32571453" "SRR32571454" "SRR32571455" 
          "SRR32571456" "SRR32571457" "SRR32571458" "SRR32571459" "SRR32571460" "SRR32571461" "SRR32571462" "SRR32571463" "SRR32571464" "SRR32571465")

STRAIN_3=("ERR14720522" "ERR14720523" "ERR14720527" "ERR14720528" "ERR14720529" "ERR14720530" "ERR14720531" "ERR14720537" "ERR14720541" "SRR32702239"
          "SRR32702240" "SRR32776280" "SRR32776281" "SRR32776282" "SRR32857619" "SRR32857620" "SRR32857621" "SRR32857622" "SRR32865946" "SRR32865947" 
          "SRR32865948" "SRR32865949" "SRR32865950" "SRR32865951" "SRR32865952" "SRR32865953" "SRR32865954" "SRR32865955" "SRR32865956" "SRR32865957")

# Function to download and convert SRA to FASTQ
download_and_convert() {
    STRAIN=("$@")  # Pass the strain samples as an argument
    for SRR_ID in "${STRAIN[@]}"; do
        # Download and convert SRA to FASTQ
        prefetch $SRR_ID && fastq-dump --split-files --gzip $SRR_ID.sra &  # Parallelize with '&'
    done
}

# Function to run FastQC on converted FASTQ files
run_fastqc() {
    STRAIN=("$@")  # Pass the strain samples as an argument
    for SRR_ID in "${STRAIN[@]}"; do
        # Run FastQC on each FASTQ file
        fastqc $SRR_ID*.fastq.gz -o ./fastqc_output/ &  # FastQC output to directory
    done
}

# Run download and conversion for each strain in parallel
download_and_convert "${STRAIN_1[@]}" &
download_and_convert "${STRAIN_2[@]}" &
download_and_convert "${STRAIN_3[@]}" &

# Wait for download and conversion to complete before running FastQC
wait
echo "All downloads and conversions completed."

# Run FastQC for each strain in parallel
run_fastqc "${STRAIN_1[@]}" &
run_fastqc "${STRAIN_2[@]}" &
run_fastqc "${STRAIN_3[@]}" &

# Wait for FastQC to complete
wait
echo "FastQC analysis completed."
