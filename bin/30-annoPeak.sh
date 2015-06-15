
function run_annoPeak {
prefix=$1
bed_file=GEM/results/${prefix}/${prefix}_GEM_events.overlap_MACS2.bed

mkdir -p annoPeak/results/${prefix}
cd annoPeak/results/${prefix}

$cisgenome_bin_dir/file_bed2cod -i $project_dir/$bed_file -o input.cod
$cisgenome_bin_dir/refgene_getnearestgene -d $project_dir/mm9/mm9_refFlat_sorted.txt -dt 1 -s mouse -i input.cod -o ${prefix}.gene -r 1 -up 50000000 -down 30000000
rm input.cod

${R} --slave <<EOF 
options(stringsAsFactors=FALSE)
library("plyr")
library("ggplot2")
library("reshape2")

Title <- "$prefix"
bedfiles <- paste("${prefix}", "gene", sep=".")

# Prepare Gene region
ref <- read.table(paste("$project_dir", "/mm9/refFlat.txt", sep=""), sep="\t", quote="")
colnames(ref) <- paste("V", seq(1, ncol(ref)), sep="")
ref <- subset(ref, V3 %in% c(paste("chr", seq(1,19), sep=""), "chrX", "chrY", "chrM") )
get_gene_region <- function(x){
  gene <- unique(x[,1])
  chr <- unique(x[,3])
  strand <- unique(x[,4])
  start <- min( as.numeric(x[,5]) )
  end <- max( as.numeric(x[,6]) )
  c(gene, chr, start, end, strand)
}
GeneRgion <- ddply(ref, .(V1, V3, V4), get_gene_region )

peak_distribution_table <- matrix(NA, nrow=length(bedfiles), ncol=6)
colnames(peak_distribution_table) <- c("Total","5prime", "Enhancer", "Promoter", "Genebody", "3prime")
rownames(peak_distribution_table) <- bedfiles
for(i in bedfiles){
  data <- scan(file=paste(i), sep="\n", what="character", skip=1)
  is_others <- unlist(lapply(data, function(x){unlist(strsplit(x, "\t"))[6]=="---"}))
  print(paste(sum(is_others), "peaks are not annotated"))
  if( sum(is_others) != 0 ){
        other_ID <- unlist(lapply(data[is_others], function(x){unlist(strsplit(x, "\t"))[1]}))
        print( paste(other_ID, collapse=",") )
  }
  data <- data[!is_others]
  peak_distribution_table[i, "Total"] <- length(data)
    
  is_in_gene <- unlist(lapply(data, function(x){temp <- unlist(strsplit(x, "\t")); summit <- mean(as.numeric(temp[3:4])); gene_region <- subset(GeneRgion, V1==temp[6] ); is_in <- FALSE; for(i in nrow(gene_region)){is_in <- is_in | ( summit >= as.numeric(gene_region[i,3]) & summit <= as.numeric(gene_region[i,4])) }; is_in } ) )
  dist_to_TSS <- unlist(lapply(data, function(x){temp <- unlist(strsplit(x, "\t")); summit <- mean(as.numeric(temp[3:4])); TSS <- as.numeric(temp[10+as.numeric(temp[9]=="-")] ); summit-TSS; } ) )

  gene_length <- unlist(lapply(data, function(x){temp <- unlist(strsplit(x, "\t")); as.numeric(temp[11]) - as.numeric(temp[10]) } ) )
  names(dist_to_TSS) <- unlist(lapply(data, function(x){unlist(strsplit(x, "\t"))[1]}))
  strand <- unlist(lapply(data, function(x){temp<-unlist(strsplit(x, "\t"))[9]; if(temp=="+"){1} else {-1}}))
  dist_to_TSS <- dist_to_TSS * strand
  
  peak_distribution_table[i, "5prime"] <- sum(dist_to_TSS < -50000)
  
  peak_distribution_table[i, "Enhancer"] <- sum(dist_to_TSS >= -50000 & dist_to_TSS < -5000 )
  
  peak_distribution_table[i, "Promoter"] <- sum(dist_to_TSS >= -5000 & dist_to_TSS < 2000 )
  
  peak_distribution_table[i, "Genebody"] <- sum(dist_to_TSS >= 2000 & is_in_gene)
  
  peak_distribution_table[i, "3prime"] <- sum(dist_to_TSS >= 2000 & (!is_in_gene))
  
}
d <- melt(t(peak_distribution_table))
d[["rate"]] <- apply(d, 1, function(x){ temp <- as.numeric(x["value"]) / as.numeric(peak_distribution_table[x["Var2"], "Total"]); paste(round(100*temp, 1), "%", sep="")})

d[["Var1"]] <- factor(d[["Var1"]], levels=c("Total", "5prime", "Enhancer", "Promoter", "Genebody", "3prime"), ordered=TRUE)
d[["Var2"]] <- sub(".bed.gene", "", d[["Var2"]])
jpeg("peakDistribution.jpeg", res=120, height=800, width=1000)
ggplot(d, aes(Var1, value, fill=Var2)) + 
  geom_bar(stat="identity", position = position_dodge(width = .8), width = 0.7) + 
  geom_text(aes(label = value), position = position_dodge(width = .8), vjust = -0.5) +
  geom_text(aes(label = rate), position = position_dodge(width = .8), vjust = -2, colour="red")
dev.off()   

EOF
cd $project_dir
}

