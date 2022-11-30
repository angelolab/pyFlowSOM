# Example script to run FlowSOM in R

# Download FlowSOM from github (if need be, install devtools with install.packages("devtools"))
devtools::install_version('igraph', version='1.3.2', repos='https://cran.rstudio.org/')
#devtools::install_github("SofieVG/FlowSOM", build_vignettes=FALSE)
devtools::install_github("y2kbugger/FlowSOM", build_vignettes=FALSE)

# Load FlowSOM package
library(FlowSOM)

# FlowSOM is stocahstic, set seed here
set.seed(2022)

# Read in table (rows are observations (either pixels of cells), columns are channels (proteins))
dat = read.csv("example_som_input.csv")

# Cluster using FlowSOM
som_out = SOM(data=as.matrix(dat), rlen=10, xdim=10, ydim=10, map=FALSE)

# Can use this function to inspect the output of SOM
str(som_out)

# Extract SOM nodes (what we want from the output), example output nodes in example_node_output.csv
# SOM is stochastic so your output may be different
nodes = som_out$codes
write.csv(nodes, "example_node_output.csv", row.names=FALSE)

mapping_out = FlowSOM:::MapDataToCodes(as.matrix(nodes), as.matrix(dat))

# From this output, we can extract the cluster for each observation
# Using example_node_output.csv, you should be able to get the same clusters
clusters = mapping_out[,1]
dat$cluster = clusters
write.csv(dat, "example_clusters_output.csv", row.names=FALSE)


## Make heatmap of outputs to assess clustering
clust_mean = aggregate(. ~ cluster, dat, mean)
clust_mean$cluster = NULL
clust_mean = scale(clust_mean)

# If need be, install pheatmap using install.packages("pheatmap")
library(pheatmap)
pdf("example_heatmap.pdf")
pheatmap(clust_mean, breaks=seq(-3,3,length.out=99))
dev.off()

