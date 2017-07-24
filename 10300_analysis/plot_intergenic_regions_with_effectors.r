#!/home/armita/prog/R/R-3.2.2/bin/Rscript

# R script for analysing a file of abundance of kmers.
# The input file should be a single column of abundance values.
# This script will produce a histogram of kmer abundance, a distribution plot
# and generate summary statistics.

#get config options
library(optparse)
library(scales)
library(RColorBrewer)
library(ggplot2)
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
r <- rf(32)


opt_list = list(
    make_option("--inp", type="character", help="tab seperated file containing 5' and 3' intergenic lengths"),
    make_option("--out", type="character", help="output gene density plot in pdf format")
)
opt = parse_args(OptionParser(option_list=opt_list))
f = opt$inp
o = opt$out

f1 = "analysis/intergenic_regions/P.cactorum/10300/10300_intergenic_regions.txt"
f2 = "analysis/intergenic_regions/P.cactorum/10300/10300_RxLR_intergenic_regions.txt"
f3 = "analysis/intergenic_regions/P.cactorum/10300/10300_CRN_intergenic_regions.txt"
o1 = "analysis/intergenic_regions/P.cactorum/10300/10300_intergenic_density.pdf"
o2 = "analysis/intergenic_regions/P.cactorum/10300/10300_RxLR_intergenic_density.pdf"
o3 = "analysis/intergenic_regions/P.cactorum/10300/10300_CRN_intergenic_density.pdf"

# options(download.file.method = "wget")
# install.packages("ggplot2")
library(ggplot2)

  df1 <- read.delim(file=f1, header=F, sep="\t")
  colnames(df1) <- c("ID", "five_IG", "three_IG")
  density_plot <- ggplot(df1, aes(df1$five_IG, df1$three_IG)) +
      stat_bin2d(bins = 100) +
      scale_y_continuous(trans='log2', limits=c(10,40826)) +
      scale_x_continuous(trans='log2', limits=c(10,40826)) +
      xlab("5' IG length") +
      ylab("3' IG length") +
      scale_fill_gradientn(colours=r)
  ggsave(o1, density_plot, dpi=300, height=10, width=12)

  df2 <- read.delim(file=f2, header=F, sep="\t")
  colnames(df2) <- c("ID", "five_IG", "three_IG")
  density_plot <- ggplot(df2, aes(df2$five_IG, df2$three_IG)) +
      stat_bin2d(bins = 100) +
      scale_y_continuous(trans='log2', limits=c(10,40826)) +
      scale_x_continuous(trans='log2', limits=c(10,40826)) +
      xlab("5' IG length") +
      ylab("3' IG length") +
      scale_fill_gradientn(colours=c("black", "black"))
  ggsave(o2, density_plot, dpi=300, height=10, width=12)

  df3 <- read.delim(file=f3, header=F, sep="\t")
  colnames(df3) <- c("ID", "five_IG", "three_IG")
  density_plot <- ggplot(df3, aes(df3$five_IG, df3$three_IG)) +
      stat_bin2d(bins = 100) +
      scale_y_continuous(trans='log2', limits=c(10,40826)) +
      scale_x_continuous(trans='log2', limits=c(10,40826)) +
      xlab("5' IG length") +
      ylab("3' IG length") +
      scale_fill_gradientn(colours=c("red", "red"))


df1 <- read.delim(file=f1, header=F, sep="\t")
colnames(df1) <- c("ID", "five_IG", "three_IG")
density_plot <- ggplot(df1, aes(df1$five_IG, df1$three_IG)) +
    stat_bin2d(bins = 100) +
    scale_y_continuous(trans='log2', limits=c(10,40826)) +
    scale_x_continuous(trans='log2', limits=c(10,40826)) +
    xlab("5' IG length") +
    ylab("3' IG length") +
    scale_fill_gradientn(colours=r)
ggsave(o1, density_plot, dpi=300, height=10, width=12)
df2 <- read.delim(file=f2, header=F, sep="\t")
colnames(df2) <- c("ID", "five_IG", "three_IG")
density_plot2 <-  density_plot + scale_fill_gradientn(colours=c("grey", "grey")) +
    geom_point(data = df2, aes(df2$five_IG, df2$three_IG), colour = "red")
ggsave(o2, density_plot2, dpi=300, height=10, width=12)

df3 <- read.delim(file=f3, header=F, sep="\t")
colnames(df3) <- c("ID", "five_IG", "three_IG")
density_plot3 <-  density_plot + scale_fill_gradientn(colours=c("grey", "grey")) +
    geom_point(data = df3, aes(df3$five_IG, df3$three_IG), colour = "red")
ggsave(o3, density_plot3, dpi=300, height=10, width=12)


#Perform significance testing of the distribution of RxLR proteins in distribution

df1$total_IG = df1$five_IG + df1$three_IG

# RxLR permutation test

# 5-prime IG

obs_rxlr <- df2
obs_rxlr$treatment <- rep("rxlr",nrow(obs_rxlr))
obs_non_rxlr <- df1[! df1$ID %in% df2$ID, ]
obs_non_rxlr$treatment <- rep("non",nrow(obs_non_rxlr))
obs_df <- rbind(obs_non_rxlr, obs_rxlr)
obs_df$treatment <- as.factor(obs_df$treatment)
obs_diff <- mean(obs_rxlr$five_IG) - mean(obs_non_rxlr$five_IG)

l <- vector()
i <- 1
while(i < 10000) {
    pred_rxlr <- df1[sample(nrow(df1), nrow(df2)), ]
    pred_rxlr$treatment <- rep("rxlr",nrow(pred_rxlr))
    pred_non <- df1[! df1$ID %in% pred_rxlr, ]
    pred_non$treatment <- rep("non",nrow(pred_non))
    pred_df <- rbind(pred_non, pred_rxlr)
    pred_df$treatment <- as.factor(pred_df$treatment)
    pred_diff <- mean(pred_rxlr$five_IG) - mean(pred_non$five_IG)
    l[[i]] <- pred_diff
    i <- i + 1
}

preds <- data.frame(matrix(unlist(l), byrow=T))
colnames(preds) <- c("rxlr")
preds$rxlr <- as.vector(preds$rxlr)
preds$rxlr <- round(preds$rxlr)
rxlr_hist <- ggplot(preds, aes(preds$rxlr)) +
  xlab("Mean difference in intergenic distance in resampled genes") +
  ylab("Frequency") +
  geom_histogram(binwidth = 25) +
  scale_y_continuous(expand=c(0,0)) +
  scale_x_continuous(breaks=seq(-800,(obs_diff + 100),100), expand=c(0,0)) +
  geom_vline(xintercept = obs_diff)
hist_out = "analysis/intergenic_regions/P.cactorum/10300/10300_RxLR_intergenic_density_five_hist.pdf"
ggsave(hist_out, rxlr_hist, dpi=300, height=8, width=12)

rxlr_5_sig = sum(l > obs_diff)
rxlr_5_sig
# [1] 0

# 3-prime IG

obs_rxlr <- df2
obs_rxlr$treatment <- rep("rxlr",nrow(obs_rxlr))
obs_non_rxlr <- df1[! df1$ID %in% df2$ID, ]
obs_non_rxlr$treatment <- rep("non",nrow(obs_non_rxlr))
obs_df <- rbind(obs_non_rxlr, obs_rxlr)
obs_df$treatment <- as.factor(obs_df$treatment)
obs_diff <- mean(obs_rxlr$three_IG) - mean(obs_non_rxlr$three_IG)

l <- vector()
i <- 1
while(i < 10000) {
    pred_rxlr <- df1[sample(nrow(df1), nrow(df2)), ]
    pred_rxlr$treatment <- rep("rxlr",nrow(pred_rxlr))
    pred_non <- df1[! df1$ID %in% pred_rxlr, ]
    pred_non$treatment <- rep("non",nrow(pred_non))
    pred_df <- rbind(pred_non, pred_rxlr)
    pred_df$treatment <- as.factor(pred_df$treatment)
    pred_diff <- mean(pred_rxlr$three_IG) - mean(pred_non$three_IG)
    l[[i]] <- pred_diff
    i <- i + 1
}

preds <- data.frame(matrix(unlist(l), byrow=T))
colnames(preds) <- c("rxlr")
preds$rxlr <- as.vector(preds$rxlr)
preds$rxlr <- round(preds$rxlr)
rxlr_hist <- ggplot(preds, aes(preds$rxlr)) +
  xlab("Mean difference in intergenic distance in resampled genes") +
  ylab("Frequency") +
  geom_histogram(binwidth = 25) +
  scale_y_continuous(expand=c(0,0)) +
  scale_x_continuous(breaks=seq(-800,(obs_diff + 100),100), expand=c(0,0)) +
  geom_vline(xintercept = obs_diff)
hist_out = "analysis/intergenic_regions/P.cactorum/10300/10300_RxLR_intergenic_density_three_hist.pdf"
ggsave(hist_out, rxlr_hist, dpi=300, height=8, width=12)

rxlr_3_sig = sum(l > obs_diff)
rxlr_3_sig
# [1] 0


# CRN perutation test

# five-prime

obs_crn <- df3
obs_crn$treatment <- rep("crn",nrow(obs_crn))
obs_non_crn <- df1[! df1$ID %in% df3$ID, ]
obs_non_crn$treatment <- rep("non",nrow(obs_non_crn))
obs_df <- rbind(obs_non_crn, obs_crn)
obs_df$treatment <- as.factor(obs_df$treatment)
obs_diff <- mean(obs_crn$five_IG) - mean(obs_non_crn$five_IG)



l <- vector()
i <- 1
while(i < 10000) {
    pred_crn <- df1[sample(nrow(df1), nrow(df3)), ]
    pred_crn$treatment <- rep("crn",nrow(pred_crn))
    pred_non <- df1[! df1$ID %in% pred_crn, ]
    pred_non$treatment <- rep("non",nrow(pred_non))
    pred_df <- rbind(pred_non, pred_crn)
    pred_df$treatment <- as.factor(pred_df$treatment)
    pred_diff <- mean(pred_crn$five_IG) - mean(pred_non$five_IG)
    l[[i]] <- pred_diff
    i <- i + 1
}
preds <- data.frame(matrix(unlist(l), byrow=T))
colnames(preds) <- c("crn")
preds$crn <- as.vector(preds$crn)
preds$crn <- round(preds$crn)

crn_hist <- ggplot(preds, aes(preds$crn)) +
  xlab("Mean difference in intergenic distance in resampled genes") +
  ylab("Frequency") +
  geom_histogram(binwidth = 25) +
  scale_y_continuous(expand=c(0,0)) +
  scale_x_continuous(breaks=seq(-1000,(max(preds$crn) + 100),100), expand=c(0,0)) +
  geom_vline(xintercept = obs_diff)
hist_out = "analysis/intergenic_regions/P.cactorum/10300/10300_CRN_intergenic_density_five_hist.pdf"
ggsave(hist_out, crn_hist, dpi=300, height=8, width=12)

crn_5_sig = sum(l > obs_diff)
crn_5_sig
# [1] 6566

# Three-prime

obs_crn <- df3
obs_crn$treatment <- rep("crn",nrow(obs_crn))
obs_crn$total_IG = obs_crn$five_IG + obs_crn$three_IG
obs_non_crn <- df1[! df1$ID %in% df3$ID, ]
obs_non_crn$treatment <- rep("non",nrow(obs_non_crn))
obs_df <- rbind(obs_non_crn, obs_crn)
obs_df$treatment <- as.factor(obs_df$treatment)
obs_diff <- mean(obs_crn$three_IG) - mean(obs_non_crn$three_IG)



l <- vector()
i <- 1
while(i < 10000) {
    pred_crn <- df1[sample(nrow(df1), nrow(df3)), ]
    pred_crn$treatment <- rep("crn",nrow(pred_crn))
    pred_non <- df1[! df1$ID %in% pred_crn, ]
    pred_non$treatment <- rep("non",nrow(pred_non))
    pred_df <- rbind(pred_non, pred_crn)
    pred_df$treatment <- as.factor(pred_df$treatment)
    pred_diff <- mean(pred_crn$three_IG) - mean(pred_non$three_IG)
    l[[i]] <- pred_diff
    i <- i + 1
}
preds <- data.frame(matrix(unlist(l), byrow=T))
colnames(preds) <- c("crn")
preds$crn <- as.vector(preds$crn)
preds$crn <- round(preds$crn)

crn_hist <- ggplot(preds, aes(preds$crn)) +
  xlab("Mean difference in intergenic distance in resampled genes") +
  ylab("Frequency") +
  geom_histogram(binwidth = 25) +
  scale_y_continuous(expand=c(0,0)) +
  scale_x_continuous(breaks=seq(-1000,(max(preds$crn) + 100),100), expand=c(0,0)) +
  geom_vline(xintercept = obs_diff)
hist_out = "analysis/intergenic_regions/P.cactorum/10300/10300_CRN_intergenic_density_three_hist.pdf"
ggsave(hist_out, crn_hist, dpi=300, height=8, width=12)

crn_3_sig = sum(l > obs_diff)
crn_3_sig
# [1] 148

q()
