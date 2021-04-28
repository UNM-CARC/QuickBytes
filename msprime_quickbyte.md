# Running Population Genetic Simulations with MSPrime #

Many microevolutionary questions invoke population genetic processes to explain them, from population genetic summary statistics to selection on specific loci of interest. In turn, population genetic simulations are becoming increasingly important to publish in major journals to validate that empirical result are consistent with the processes authors say the findings represent. There are many programs used for these simulations, that fall into two general categories: forward (slow, simulate all individuals in the populations) and backward (fast, work from a number of samples backward to simulate genealogies). Prominent examples of these two are [SLiM](https://messerlab.org/slim/) and [msprime](https://msprime.readthedocs.io/en/stable/) respectively.

Here, we'll give a basic introduction to msprime, give a simple example of two diverging populations, and show how to parallelize replicates on CARC. The example is one I used to establish how F<sub>ST</sub>, [an estimate of population divergence](https://onlinelibrary.wiley.com/doi/10.1111/j.1558-5646.1984.tb05657.x), changes over time based on population size. In particular, I used this to test if observed values of F<sub>ST</sub> between islands connected during the Pleistocene became panmictic at those times, or if there was still reduced gene flow between given islands (with the system being one worked on in the past in papers like [Smith & Filardi 2007](https://academic.oup.com/auk/article/124/2/479/5562749)).

This QuickByte describes msprime 1.0, which is a major update from the widely used earlier versions.

## How msprime Works ##

[The paper describing msprime](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004842) has been cited hundreds of time, but represents an extension of [the simulation program ms](https://academic.oup.com/bioinformatics/article/18/2/337/225783), which has been cited a couple thousand times. The goal of this extension is to scale simulations up to the large sample sizes of individuals and loci used in modern day genomic studies. Msprime's fast speed and ease of analysis is achieved by by adding novel ways of keeping track of geneologies being analyzed through sparse trees and coalescence records, collectively refer to ass tree sequences.

## How to run msprime ##

Msprime is a python package, with reccomended download via conda. We reccomend you use miniconda for this, as we've had some bugs with installing this through anaconda in the past. We'll make an environment with it and a couple other important modules:

	conda create -n msp1-env -c conda-forge msprime scikit-allel numpy

Then we'll activate the environment with "conda activate", but note that it needs to be "source activate" in a script:

	conda activate msp1-env

In a script or in python command line, we'll import msprime as msp for convenience:

	import msprime as msp

The simulations themselves, at a base level, are very simple. All that's needed is a sample size of individuals "tracked" backwards. Note that these are assumed diploid unless ploidy is specified:

	trees = msp.sim_ancestry(samples=10)
	
Mutations can be added using sim_mutations, ideally changing the default mutation rate (here to the per-year songbird mutation rate):

	mutations = msp.sim_mutations(trees, rate=2.3e-9)

This is just one locus, but we gain a lot more information by adding sequence length and recombination rates.

	trees = msp.sim_ancestry(samples=10, recombination_rate=1e-8, sequence_length=1e6)

Unlike the older versions of msprime, outside of pre-made demographic scenarios, you need to add things like populations and merge events to a demography object. Migration rates are also set there. First, we'll initialize the demography and add two populations:

	demo = msp.Demography()
	demo.add_population(name="pop1", initial_size=10000)
	demo.add_population(name="pop2", initial_size=20000)
	
Next, we'll set up an ancestral population and add a population split time (the size is equal to the size before a bottleneck we implement below):

	demo.add_population(name="anc_pop12", initial_size=50000)
	demo.add_population_split(time=5700, derived=["pop1","pop2"], ancestral="anc_pop12")
	
Finally, we'll add symmetric migration (i.e. gene flow) between the two focal populations:

	demo.set_symmetric_migration_rate(['pop1', 'pop2'], 0.001)

We can have the migration rate change over time too, here we increase the migration rate during the period between the split time (5700 generations ago) and 4000 generations go:

	demo.add_symmetric_migration_rate_change(4000, ['pop1', 'pop2'], 0.01)
	
The final common demographic event is population size change, which we'll set to have a bottleneck three quarters of the way through the simulation. That is, we set the population size of population 1 to be three times the present population 2500 years:
	
	size_increase = msp.PopulationParametersChange(time=2500, initial_size=30000, population_id=0)

Bringing this all together, our simulation will look like:

	trees = msp.sim_ancestry(samples={"pop1":10, "pop2":10},
                         demography=demo,
                         recombination_rate=1e-8,
                         length=1e7)
			 
And we'll add mutations like this, using a yearly rate of 2.3e-9 and a generation time of 2.55 years (same as the case study):

	mutations = msp.sim_mutations(trees, rate=5.9e-9)

## Running MSPrime replicates on CARC ##

It is best practice to run many replicates of any simulation you run to assess the robustness of any estimates you make. You can use [GNU Parallel (specifically env_parallel)](https://github.com/UNM-CARC/QuickBytes/blob/master/GNU%20Parallel.md) to run these simulations, and can add these replicates directly to an output file. The following examples your python simulation script takes population size (popsize) and population divergence time (divtime) and have an output file like "$popsize_$divtime.out" that the script writes to. First we'll run 30 replicates. Note that the "echo {}" just to deal with the parallel iterator, so GNU parallel doesn't append it to the end of our python call by default.

	env_parallel --sshloginfile $PBS_NODEFILE \
		'echo {}; /path/to/python msprime_script.py --popsize 2000 --divtime 10000 \
		--output ./outputs/1000_10000.out' ::: {1..30}

You could also use GNU parallel to iterate over multiple parameter combinations, here we test multiple population sizes (2000, 3000, and 5000) and divergence times (1000, 5000, and 10000 generations). We'll assume the script has replicates coded into it.

	env_parallel --sshloginfile $PBS_NODEFILE \
		'/path/to/python msprime_script.py --popsize {1} --divtime {2} \
		--output ./outputs/{1}_{2}' ::: 2000 3000 5000 ::: 1000 5000 10000

## Case study: Divergence between connected islands ##

Here we look at three islands interconnected at glacial maxima, modeled after Choiseul, Isabel, and Guadalcanal of the Solomon Islands. These islands are arranged from west to east, with Guadalcanal arguably not being fully connected to the rest. Our goal is to assess [F<sub>ST</sub>](https://onlinelibrary.wiley.com/doi/10.1111/j.1558-5646.1984.tb05657.x) between islands, for which which will use the scikit-allel package. Empirically, we find that F<sub>ST</sub> between Isabel and Choiseul is much higher than between Guadalcanal and Isabel, consistent with the slight break between those two islands. However, F<sub>ST</sub> increases faster after divergence with lower population size, so we want to know what density of birds on Guadalcanal would be required to produce this result given knowledge that a density of 25 birds/km<sup>2</sup> produced the empirical F<sub>ST</sub> between Isabel and Choiseul. We will test 5 densities for Guadalcanal (5, 10, 15, 20, 25, and 30), each with 30 replicates, holding the population density on Isabel as a constant 25 birds/km<sup>2</sup>.

First, we have to write our python script. We'll use the argparse module to hand our arguments. Note that we'll set Isabel as the first population and Guadalcanal as the second (in a more complete version we can take island names as input and have a function to determine their sizes). It will output the population size of the first (Isabel) and second (Guadalcanal) island along with the F<sub>ST</sub>.

	import os, sys, msprime as msp, numpy as np, allel, re, argparse
	
	def main():
		# set up argparse
		parse = argparse.ArgumentParser(description = "Get simulation parameters")
		# two population densities for generality
		parse.add_argument("-d1", "--density1", type=float, help="Density of first population")
		parse.add_argument("-d2", "--density2", type=float, help="Density of second population")
		parse.add_argument("-o", "--output", type=str, help="Path to output file")
		args = parse.parse_args()
		
		# assign argparse values to variables
		dens1, dens2, outfile = args.density1, args.density2, args.output
		
		# calculate population sizes, with Isabel and Guadalcanal being 2999 and 5302 km<sup>2</sup> respectively
		size1 = dens1 * 2999
		size2 = dens2 * 5302
		
		# set up number of samples and demography
		samples = 30
		demography = msp.Demography()
		demography.add_population(name="pop1", initial_size=size1)
		demography.add_population(name="pop2", initial_size=size2)
		demography.add_population(name="anc_pop12", initial_size=size1+size2)
		demography.add_population_split(time=5700, derived=["pop1","pop2"], ancestral="anc_pop12")
		
		# run simulation for 10 megabases
		trees = msp.sim_ancestry(samples={"pop1":samples, "pop2":samples},
			demography=demography,
			recombination_rate=1e-8,
			sequence_length=1e7)
		
		# add mutations with a common estimate of mutation rate in birds
		mutations = msp.sim_mutations(trees, rate=5.9e-9)
		
		# get haplotypes from simulation
    		haplotypes = np.array(mutations.genotype_matrix())
    		genotypes = allel.HaplotypeArray(haplotypes).to_genotypes(ploidy=2)

   		# calculate fst, assumes even sample size
    		fst = allel.stats.fst.average_weir_cockerham_fst(genotypes,[list(range(0,samples)),list(range(samples,samples*2))],10)[0]
		
		# write output to file
		output = open(outfile, "a")
    		output.write(str(int(size1))+"\t"+str(int(size2))+"\t"+str(fst)+"\n")
    		output.close()
	
	if __name__ == '__main__':
		main()
	
Now that we have our scripted simulation, we'll write a PBS script to run it in parallel! We assumes you have a directory in your working directory called "output" and named your script "island_msp_twopop.py". We'll name files based on the denisty on Guadalcanal. We don't have it written in the script, but if you already have something in "output", this just appends to those files (i.e. "rm output\/*" beforehand). Note that this script excludes the header.
	
	# prepare GNU parallel
	module load parallel-20170322-gcc-4.8.5-2ycpx7e
	source $(which env_parallel.bash)

	# load our environment
	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	source activate msp1-env
		
	# make a shortcut for our working directory, where we assume all scripts are located.	
	dir=$PBS_O_WORKDIR
		
	env_parallel --sshloginfile $PBS_NODEFILE \
		'echo {2}; python $dir/island_msp_twopop.py -d1 25 -d2 {1} -o $dir/output/density_{1}.out' \
		::: 3 4 5 10 15 20 25 30 ::: {1..30}
		
For interpretting these results, the empirical F<sub>ST</sub> value between Guadalcanal and Isabel is 0.077, and the best density match was 4 birds/km<sup>2</sup> (F<sub>ST</sub>=0.79). That means that to get the observed F<sub>ST</sub>, Guadalcanal would have to have 16% of the population density inferred on the other islands. Genetic diversity doesn't support this, suggesting that the gap between them formed an excess of population structure compared to the other islands!

## Citation ##

Below are citations for msprime and GNU parallel. Remember to cite programs you run whenever possible!

Kelleher, J., Etheridge, A. M., & McVean, G. (2016). Efficient Coalescent Simulation and Genealogical Analysis for Large Sample Sizes. PLoS Computational Biology, 12(5), 1004842. https://doi.org/10.1371/journal.pcbi.1004842

Tange, O. (2018). GNU Parallel 2018 [Computer software]. https://doi.org/10.5281/zenodo.1146014.
