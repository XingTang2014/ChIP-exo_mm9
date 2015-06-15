function run_macs2_keepDup {
out_prefix=$1
IP_bam_file=$2

out_dir=MACS2/results/$out_prefix
mkdir -p $out_dir

cd $out_dir
${macs2} callpeak -t $project_dir/$IP_bam_file -f BAM -g mm -n $out_prefix --keep-dup all
cd $project_dir
}

 






