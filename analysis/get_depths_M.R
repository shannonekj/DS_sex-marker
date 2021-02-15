# get depths from a depth files (output of `samtools depth -b bedfile -f bamfile 

###  PREP  ###
# packages
library(tidyverse)
# setup directory
setwd("/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_M_reference")
getwd()
# read in data
fdat <- read.table(file="F.depth", header = FALSE)
head(fdat)
mdat <- read.table(file="M.depth", header = FALSE)
head(mdat)

# create locus name
fdat <- fdat %>% unite(locus, V1, V2)
mdat <- mdat %>% unite(locus, V1, V2)


###  GET STATS  ###
# get number of individuals that have any coverage at locus
fdat <- fdat %>% mutate(n_ind_F=rowSums(.[2:25]!=0))
mdat <- mdat %>% mutate(n_ind_M=rowSums(.[2:25]!=0))

# get total coverage at locusu
fdat <- fdat %>% mutate(total_cov_F = rowSums(select(., starts_with("V"))))
mdat <- mdat %>% mutate(total_cov_M = rowSums(select(., starts_with("V"))))

# get mean coverage of individuals that have coverage at that locus
fdat <- transform(fdat, mean_cov_F = total_cov_F / n_ind_F)
mdat <- transform(mdat, mean_cov_M = total_cov_M / n_ind_M)
## base R example
#fdat$mean_cov_F <- fdat$total_cov_F / fdat$n_ind_F
#mdat$mean_cov_M <- mdat$total_cov_M / mdat$n_ind_M

# get rid of NaN's
fdat <- fdat %>% mutate_at(vars(mean_cov_F), ~replace(., is.nan(.), 0))
mdat <- mdat %>% mutate_at(vars(mean_cov_M), ~replace(., is.nan(.), 0))
## base R example
#fdat4$mean_cov[is.nan(fdat4$mean_cov)]<-0
#mdat4$mean_cov[is.nan(mdat4$mean_cov)]<-0


###  COMBINE M & F  ###
f_min <- fdat %>% select(locus, n_ind_F, mean_cov_F)
m_min <- mdat %>% select(locus, n_ind_M, mean_cov_M)
depths <- left_join(f_min, m_min, by = "locus")
depths$diff_cov <- abs(depths$mean_cov_F - depths$mean_cov_M)


###  WRITE FILE  ###
write_tsv(depths, "sex_depths.tsv")

