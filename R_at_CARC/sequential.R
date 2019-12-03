# This is a pointless little script to use as an example of sequential and parallel versions of the same code

# Load the libraries you want like the usual
library(TreeSim)
library(phangorn)

# Simulate a bunch of trees cuz we can and it takes a while
sim_trees<-sim.bd.taxa(20, 10000, lambda=2, mu=0.5, complete=F)

# cool, a bunch of trees and stuff, lets make a species tree and plot it

species_tree<-speciesTree(sim_trees)
pdf("~/wheeler-scratch/R-workshop/all_the_species_trees.pdf")
plot(species_tree)
dev.off()

# neato, lets compare the distances of all the gene trees to the species tree
tree_distances<-lapply(sim_trees, treedist, tree2=species_tree)

# Cool dude, lets calculate the mean and median of one of those things I guess

branch_distances<-lapply(tree_distances, getElement, name="branch.score.difference")
mean_distance<-mean(unlist(branch_distances))
median_distance<-median(unlist(branch_distances))
print("mean is")
print(mean_distance)
print("median is")
print(median_distance)

# Cool. All meaningless but whatever
