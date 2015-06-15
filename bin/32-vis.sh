function run_vis {
prefix=$1
bam_file=bowtie2/results/${prefix}.bam

if [ ! -e bam2igv ]; then mkdir bam2igv; fi

#sort and index the bam file
${samtools} sort ${bam_file} bam2igv/${prefix}.sorted
${samtools} index bam2igv/${prefix}.sorted.bam
}

