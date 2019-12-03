# This is a pointless little script to use as an example of sequential and parallel versions of the same code

# Load the libraries you want like the usual
library(TreeSim)
library(phangorn)

# read in command line arguments and set vairables
args<-commandArgs(trailingOnly=T)
lamb_var<-as.numeric(args[1])
mu_var<-as.numeric(args[2])
num_taxa<-as.numeric(args[3])

print(lamb_var)
print(mu_var)
print(num_taxa)
# create prefix string for output
out_dir<-getwd()
out_pre<-paste("treesims", num_taxa, lamb_var, mu_var, sep="_")

# Simulate a bunch of trees cuz we can and it takes a while
sim_trees<-sim.bd.taxa(num_taxa, 10000, lambda=lamb_var, mu=mu_var, complete=F)

# cool, a bunch of trees and stuff, lets make a species tree and plot it

species_tree<-speciesTree(sim_trees)
pdf(file=paste(out_dir,"/",out_pre, ".pdf", sep=""))
plot(species_tree)
dev.off()

# neato, lets compare the distances of all the gene trees to the species tree
tree_distances<-lapply(sim_trees, treedist, tree2=species_tree)

# Cool dude, lets calculate the mean and median of one of those things I guess

branch_distances<-lapply(tree_distances, getElement, name="branch.score.difference")
mean_distance<-mean(unlist(branch_distances))
median_distance<-median(unlist(branch_distances))

write(paste("for", num_taxa,"taxa, the mean distance for lambda", lamb_var, "and mu", mu_var, "is", mean_distance, sep=" "), file=paste(out_dir,"/", "distances.txt", sep=""), append=T)
write(paste("for", num_taxa, "taxa, the median distance for lambda", lamb_var, "and mu", mu_var, "is", median_distance, sep=" "), file=paste(out_dir,"/", "distances.txt", sep=""), append=T)
# Cool. All meaningless but whatever
