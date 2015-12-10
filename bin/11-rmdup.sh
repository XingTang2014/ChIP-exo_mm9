project_dir=projects/ChIP-exo
cd ~/$project_dir

function run_dedup {
sample=$1

samtools sort bowtie2/results/$sample.bam bowtie2/results/$sample.sort
java -jar ~/Downloads/picard-tools-1.117/MarkDuplicates.jar \
	INPUT=bowtie2/results/$sample.sort.bam OUTPUT=bowtie2/results/$sample.dedup.bam \
	 REMOVE_DUPLICATES=TRUE METRICS_FILE=temp
samtools index bowtie2/results/$sample.dedup.bam

}
