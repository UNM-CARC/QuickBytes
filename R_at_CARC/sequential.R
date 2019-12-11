# This is a script to use as an example of sequential and parallel versions of the same code

# Load the libraries
library(TreeSim)
library(phangorn)

# Simulate a bunch of trees
sim_trees<-sim.bd.taxa(20, 10000, lambda=2, mu=0.5, complete=F)

# make a species tree and plot it

species_tree<-speciesTree(sim_trees)
pdf("~/wheeler-scratch/R-workshop/all_the_species_trees.pdf")
plot(species_tree)
dev.off()

# compare the distances of all the gene trees to the species tree
tree_distances<-lapply(sim_trees, treedist, tree2=species_tree)

# calculate the mean and median

branch_distances<-lapply(tree_distances, getElement, name="branch.score.difference")
mean_distance<-mean(unlist(branch_distances))
median_distance<-median(unlist(branch_distances))
print("mean is")
print(mean_distance)
print("median is")
print(median_distance)


