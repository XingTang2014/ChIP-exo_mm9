date
echo "The working directory is: `pwd`"
export project_dir=`pwd`
 
echo
echo "# set path for tools"
source software.conf
cat software.conf | grep -vP "^#"| sed 's/^export //;s/=/\t/' | while read tool path
do
	echo "$tool=$path"
done

echo
echo "# unzip fastq files"
cat samples.conf | grep -vP "^#" | while read sample fastq
do
	echo $fastq
	extension="${fastq##*.}"
	if [ "$extension" == "gz" ]; then gzip -df $fastq; fi
	if [ "$extension" == "bz2" ]; then bzip2 -df $fastq; fi
done
sed "s/\.gz$//;s/\.bz2$//" samples.conf > samples.new.conf

echo
echo "# run fastqc to check the quality of each fastq file"
source bin/01-fastQC.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_factQC $fastq $sample"
	run_factQC $fastq $sample 
done

echo 
echo "# download mm9.fa and build index for bowtie2"
cd mm9; bash make_mm9.sh; cd ../

echo
echo "# run bowtie2 to align reads onto the genome"
source bin/10-bowtie.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_bowtie2 $fastq $sample"
	run_bowtie2 $fastq $sample 
done

echo
echo "# run macs2 to predict binding events"
source bin/20-MACS2.keepDup.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_macs2_keepDup ${sample} $sample.bam"
	run_macs2_keepDup ${sample} bowtie2/results/$sample.bam 
done

echo
echo "# run GEM to predict binding events"
source bin/21-GEM.keepDup.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_gem_keepDup $sample" 
	run_gem_keepDup $sample 
done

echo
echo "# filter GEM predicted events by intersecting with macs2 predicted events"
source bin/22-intersect_GEM_MACS2.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_intersect_GEM_MACS2 $sample" 
	run_intersect_GEM_MACS2 $sample 
done

echo 
echo "# run cisgenome to get the nearest gene of each predicted binding event"
source bin/30-annoPeak.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_annoPeak $sample" 
	run_annoPeak $sample 
done

echo
echo "# run HOMER to get enriched motif and plot reads coverage over predicted binding events"
source bin/31-Homer.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_homer $sample" 
	run_homer $sample 
done

echo
echo "# sort and index the bam files to be visualized by IGV"
source bin/32-vis.sh
cat samples.new.conf | grep -vP "^#" | while read sample fastq
do
	echo "run_vis $sample" 
	run_vis $sample 
done


