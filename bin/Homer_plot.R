options(stringsAsFactors=FALSE)
library("reshape2")
library("ggplot2")
pdf("Homer_plots.pdf", width=8, height=5)

# Plot tag distribution
tagDistri <- read.table("tagDistri.details.xls", header=TRUE, sep="\t")
colnames(tagDistri) <- c("Distances_to_summit", "tags", "tags_pos", "tags_neg" )
tagDistri[["tags"]] <- tagDistri[["tags_pos"]] + tagDistri[["tags_neg"]]

get_mode <- function(d){
  temp1 <- subset(d, Distances_to_summit < 0)
  temp2 <- subset(d, Distances_to_summit >= 0)
  c( temp1[which.max(temp1[,"value"]), "Distances_to_summit"], temp2[which.max(temp2[,"value"]), "Distances_to_summit"] )
} 

df <- melt(tagDistri[,c("Distances_to_summit", "tags", "tags_pos", "tags_neg")], id.vars="Distances_to_summit")
df[["value"]] <- as.numeric(df[["value"]]) 
df[["Distances_to_summit"]] <- as.numeric(df[["Distances_to_summit"]])  
ggplot(df, aes(Distances_to_summit, value)) + geom_line(aes(group=variable, color=variable)) + 
  scale_color_manual(values=c("yellow", "blue", "red")) +
  labs(title="Tag Distribution Around Peak Summit", x="Distances to Peak Summit (bp)", y="Tags Per bp Per Peak") +
  geom_vline(xintercept=get_mode(df), color="black") + 
  scale_x_continuous(breaks=setdiff(c(seq(min(df[["Distances_to_summit"]]), max(df[["Distances_to_summit"]]), by=50), get_mode(df)), 0) )
  
dev.off()
