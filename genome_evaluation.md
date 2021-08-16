# Reference genome evaluation with QUAST and BUSCO #

Whether you're using an already assembled reference genome from a database like [NCBI](https://www.ncbi.nlm.nih.gov/genome/) or evaluating one you've assembled for completeness, it's important to check the contiguity and completeness of your reference before using it. Here we'll discuss tools for assessing these metrics: [QUAST](http://bioinf.spbau.ru/quast) (Quality Assessment Tool for Genome Assemblies) for contiguity and [BUSCO](https://busco.ezlab.org/) (Benchmarking Universal Single-Copy Orthologs) for completeness. Here we'll go over how to run these two programs on CARC and optionally install them with conda.

## Assessing contiguity with QUAST ##

Although QUAST is fairly easy to run on personal computers, it is much easier to run in the place you already have your reference (which hopefully is CARC!). QUAST is not currently a module on any machine, so we'll install it using conda. First, if conda isn't initialized, you'll need to load a module for miniconda (with this specific module being the one on wheeler). Then, you'll make a new environment with QUAST. Unfortunately, as of writing this QuickByte, QUAST has dependency issues with other programs, and can't be in the same environment as BUSCO:

	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	conda create --name quast-env --channel bioconda quast

Now for actually running QUAST! This is simple enough, but there are a few key options to know about (you can read them all [here](http://quast.sourceforge.net/docs/manual.html)). First, if you are working with an assembly over 100 Mbp, you should use the --large option to improve accuracy and speed. It automatically applies some relevant flags, too (e.g. sets the minimum evaluated contig size to 3000). Second, you'll want to use the --threads option to use the built in parallelization. This simplest version would look like:

	quast /path/to/focal_reference.fa -o /path/to/quast_output --large --threads 8

Here are two other options that may be of interest. One option for scaffolded genomes it "--split scaffolds", where it will add a second output directory evaluating contigs instead of scaffolds in your reference. Also, if you'd like to compare to a better, preexisting reference genome (needed for some functions like putative missassemblies), use the -r flag to specify the path to a different reference. One final option that is more computationally intensive is gene finding with --glimmer, which uses [GlimmerHMM](https://ccb.jhu.edu/software/glimmerhmm/) to identify possible protein coding genes. Note that the options using GeneMark (e.g. --gene-finding) are not availible on the bioconda distribution of this software. This advanced version would look like:

	quast /path/to/focal_reference.fa -o /path/to/quast_output -r /path/to/high_qual_refernece --large --glimmer --split-scaffolds --threads 8

We'll run QUAST with a submission script, here using PBS variables. This is also made for Wheeler, being run on one core. We will store the output in a subdirectory in the submission directory. This examples runs the basic stats above on a scaffolded reference genome used [in a different QuickByte](https://github.com/UNM-CARC/QuickBytes/blob/master/GATK_QuickByte.md) borrowed from [a great paper about conservation genomics](https://academic.oup.com/gbe/article/11/7/2023/5499175).

	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	source activate quast-env
	
	# sample command using a reference genome
	quast /projects/shared/tutorials/quickbytes/GATK/sagegrouse_reference.fa -o $PBS_O_WORKDIR/quast_output --large --threads 8

There are a few ways to assess the output in the output directory, with the most convenient being report.txt. A sample report for running the above command is below. Major points of interest include the total length, [N50 and L50](https://en.wikipedia.org/wiki/N50,_L50,_and_related_statistics), total length in scaffolds of given sizes (e.g. >= 50000 bp), and number of contigs (counting scaffolds as contigs) of given lengths. You can also transfer a report PDF (report.pdf) to a desktop to view it some nice figures illustrating important info like cumulative reference size for given numbers of contigs.

	All statistics are based on contigs of size >= 3000 bp, unless otherwise noted (e.g., "# contigs (>= 0 bp)" and "Total length (>= 0 bp)" include all contigs).

	Assembly                    sagegrouse_reference
	# contigs (>= 0 bp)         985
	# contigs (>= 1000 bp)      985
	# contigs (>= 5000 bp)      983
	# contigs (>= 10000 bp)     967
	# contigs (>= 25000 bp)     698
	# contigs (>= 50000 bp)     527
	Total length (>= 0 bp)      1000043310
	Total length (>= 1000 bp)   1000043310
	Total length (>= 5000 bp)   1000035416
	Total length (>= 10000 bp)  999906513
	Total length (>= 25000 bp)  995198919
	Total length (>= 50000 bp)  989315597
	# contigs                   985
	Largest contig              19076553
	Total length                1000043310
	GC (%)                      41.52
	N50                         3849570
	N75                         2122777
	L50                         81
	L75                         165
	# N's per 100 kbp           0.43

## Assessing completeness with BUSCO ##

The next step will be to assess how complete our genome is by seeing how many single-copy orthologs are detected. This is important, because obviously if our genome is missing important portions, those regions won't be detected in analyses. For this, we will use BUSCO. As it stands, there are some issues installing BUSCO with conda (new versions fail to solve), and it doesn't work well as a spack module, so I'll provide a conda .yml for you. First, copy the file from our shared tutorial directory like "cp /projects/shared/tutorials/quickbytes/busco-env.yml ~/path/to/directory" or exapand this bit and manually copy its contents:

<details>
	<summary> Text for the .yml file </summary>
	
	name: busco-env
	channels:
	  - bioconda
	  - ursky
	  - conda-forge
	  - defaults
	dependencies:
	  - _libgcc_mutex=0.1=conda_forge
	  - _openmp_mutex=4.5=1_gnu
	  - _r-mutex=1.0.1=anacondar_1
	  - augustus=3.4.0=pl5262hb677c0c_1
	  - bamtools=2.5.1=h9a82719_9
	  - binutils_impl_linux-64=2.35.1=h193b22a_2
	  - binutils_linux-64=2.35=h67ddf6f_30
	  - biopython=1.79=py39h3811e60_0
	  - blast=2.11.0=pl5262h3289130_1
	  - boost=1.74.0=py39h5472131_3
	  - boost-cpp=1.74.0=h312852a_4
	  - busco=5.1.3=pyhdfd78af_0
	  - bwidget=1.9.14=ha770c72_0
	  - bzip2=1.0.8=h7f98852_4
	  - c-ares=1.17.1=h7f98852_1
	  - ca-certificates=2021.5.30=ha878542_0
	  - cairo=1.16.0=h6cf1ce9_1008
	  - cdbtools=0.99=h9a82719_6
	  - certifi=2021.5.30=py39hf3d152e_0
	  - curl=7.77.0=hea6ffbf_0
	  - diamond=2.0.9=hdcc8f71_0
	  - findutils=4.6.0=h14c3975_1000
	  - font-ttf-dejavu-sans-mono=2.37=hab24e00_0
	  - font-ttf-inconsolata=3.000=h77eed37_0
	  - font-ttf-source-code-pro=2.038=h77eed37_0
	  - font-ttf-ubuntu=0.83=hab24e00_0
	  - fontconfig=2.13.1=hba837de_1005
	  - fonts-conda-ecosystem=1=0
	  - fonts-conda-forge=1=0
	  - freetype=2.10.4=h0708190_1
	  - fribidi=1.0.10=h36c2ea0_0
	  - gcc_impl_linux-64=9.3.0=h70c0ae5_19
	  - gcc_linux-64=9.3.0=hf25ea35_30
	  - gettext=0.19.8.1=h0b5b191_1005
	  - gfortran_impl_linux-64=9.3.0=hc4a2995_19
	  - gfortran_linux-64=9.3.0=hdc58fab_30
	  - gmp=6.2.1=h58526e2_0
	  - graphite2=1.3.13=h58526e2_1001
	  - gsl=2.6=he838d99_2
	  - gxx_impl_linux-64=9.3.0=hd87eabc_19
	  - gxx_linux-64=9.3.0=h3fbe746_30
	  - harfbuzz=2.8.1=h83ec7ef_0
	  - hmmer=3.1b2=3
	  - htslib=1.12=h9093b5e_1
	  - icu=68.1=h58526e2_0
	  - jbig=2.1=h7f98852_2003
	  - jpeg=9d=h36c2ea0_0
	  - kernel-headers_linux-64=2.6.32=h77966d4_13
	  - krb5=1.19.1=hcc1bbae_0
	  - ld_impl_linux-64=2.35.1=hea4e1c9_2
	  - lerc=2.2.1=h9c3ff4c_0
	  - libblas=3.9.0=9_openblas
	  - libcblas=3.9.0=9_openblas
	  - libcurl=7.77.0=h2574ce0_0
	  - libdeflate=1.7=h7f98852_5
	  - libedit=3.1.20191231=he28a2e2_2
	  - libev=4.33=h516909a_1
	  - libffi=3.3=h58526e2_2
	  - libgcc=7.2.0=h69d50b8_2
	  - libgcc-devel_linux-64=9.3.0=h7864c58_19
	  - libgcc-ng=9.3.0=h2828fa1_19
	  - libgfortran-ng=9.3.0=hff62375_19
	  - libgfortran5=9.3.0=hff62375_19
	  - libglib=2.68.3=h3e27bee_0
	  - libgomp=9.3.0=h2828fa1_19
	  - libiconv=1.16=h516909a_0
	  - libidn2=2.3.1=h7f98852_0
	  - liblapack=3.9.0=9_openblas
	  - libnghttp2=1.43.0=h812cca2_0
	  - libopenblas=0.3.15=pthreads_h8fe5266_1
	  - libpng=1.6.37=h21135ba_2
	  - libssh2=1.9.0=ha56f1ee_6
	  - libstdcxx-devel_linux-64=9.3.0=hb016644_19
	  - libstdcxx-ng=9.3.0=h6de172a_19
	  - libtiff=4.3.0=hf544144_1
	  - libunistring=0.9.10=h14c3975_0
	  - libuuid=2.32.1=h7f98852_1000
	  - libwebp-base=1.2.0=h7f98852_2
	  - libxcb=1.13=h7f98852_1003
	  - libxml2=2.9.12=h72842e0_0
	  - links=1.8.7=pl5262h7d875b9_2
	  - lp_solve=5.5.2.5=h14c3975_1001
	  - lz4-c=1.9.3=h9c3ff4c_0
	  - make=4.3=hd18ef5c_1
	  - metis=5.1.0=h58526e2_1006
	  - mpfr=4.0.2=he80fd80_1
	  - mysql-connector-c=6.1.11=h6eb9d5d_1007
	  - ncurses=6.2=h58526e2_4
	  - numpy=1.20.3=py39hdbf815f_1
	  - openssl=1.1.1k=h7f98852_0
	  - pango=1.48.5=hb8ff022_0
	  - pcre=8.45=h9c3ff4c_0
	  - pcre2=10.36=h032f7d1_1
	  - perl=5.26.2=h36c2ea0_1008
	  - perl-apache-test=1.40=pl526_1
	  - perl-app-cpanminus=1.7044=pl526_1
	  - perl-archive-tar=2.32=pl526_0
	  - perl-base=2.23=pl526_1
	  - perl-carp=1.38=pl526_3
	  - perl-class-load=0.25=pl526_0
	  - perl-class-load-xs=0.10=pl526h6bb024c_2
	  - perl-class-method-modifiers=2.12=pl526_0
	  - perl-constant=1.33=pl526_1
	  - perl-cpan-meta=2.150010=pl526_0
	  - perl-cpan-meta-requirements=2.140=pl526_0
	  - perl-cpan-meta-yaml=0.018=pl526_0
	  - perl-data-dumper=2.173=pl526_0
	  - perl-data-optlist=0.110=pl526_2
	  - perl-dbi=1.642=pl526_0
	  - perl-devel-globaldestruction=0.14=pl526_0
	  - perl-devel-overloadinfo=0.005=pl526_0
	  - perl-devel-stacktrace=2.04=pl526_0
	  - perl-dist-checkconflicts=0.11=pl526_2
	  - perl-encode=2.88=pl526_1
	  - perl-encode-locale=1.05=pl526_6
	  - perl-eval-closure=0.14=pl526h6bb024c_4
	  - perl-exporter=5.72=pl526_1
	  - perl-exporter-tiny=1.002001=pl526_0
	  - perl-extutils-cbuilder=0.280230=pl526_1
	  - perl-extutils-makemaker=7.36=pl526_1
	  - perl-extutils-manifest=1.72=pl526_0
	  - perl-extutils-parsexs=3.35=pl526_0
	  - perl-file-listing=6.04=pl526_1
	  - perl-file-path=2.16=pl526_0
	  - perl-file-temp=0.2304=pl526_2
	  - perl-file-which=1.23=pl526_0
	  - perl-getopt-long=2.50=pl526_1
	  - perl-ipc-cmd=1.02=pl526_0
	  - perl-json-pp=4.04=pl526_0
	  - perl-locale-maketext-simple=0.21=pl526_2
	  - perl-module-build=0.4224=pl526_3
	  - perl-module-corelist=5.20190524=pl526_0
	  - perl-module-implementation=0.09=pl526_2
	  - perl-module-load=0.32=pl526_1
	  - perl-module-load-conditional=0.68=pl526_2
	  - perl-module-metadata=1.000036=pl526_0
	  - perl-module-runtime=0.016=pl526_1
	  - perl-module-runtime-conflicts=0.003=pl526_0
	  - perl-moo=2.003004=pl526_0
	  - perl-moose=2.2011=pl526hf484d3e_1
	  - perl-mro-compat=0.13=pl526_0
	  - perl-package-deprecationmanager=0.17=pl526_0
	  - perl-package-stash=0.38=pl526hf484d3e_1
	  - perl-package-stash-xs=0.28=pl526hf484d3e_1
	  - perl-parallel-forkmanager=2.02=pl526_0
	  - perl-params-check=0.38=pl526_1
	  - perl-params-util=1.07=pl526h6bb024c_4
	  - perl-parent=0.236=pl526_1
	  - perl-pathtools=3.75=pl526h14c3975_1
	  - perl-perl-ostype=1.010=pl526_1
	  - perl-role-tiny=2.000008=pl526_0
	  - perl-scalar-list-utils=1.52=pl526h516909a_0
	  - perl-storable=3.15=pl526h14c3975_0
	  - perl-sub-exporter=0.987=pl526_2
	  - perl-sub-exporter-progressive=0.001013=pl526_0
	  - perl-sub-identify=0.14=pl526h14c3975_0
	  - perl-sub-install=0.928=pl526_2
	  - perl-sub-name=0.21=pl526_1
	  - perl-sub-quote=2.006003=pl526_1
	  - perl-text-abbrev=1.02=pl526_0
	  - perl-text-parsewords=3.30=pl526_0
	  - perl-try-tiny=0.30=pl526_1
	  - perl-version=0.9924=pl526_0
	  - perl-xsloader=0.24=pl526_0
	  - perl-yaml=1.29=pl526_0
	  - pip=21.1.2=pyhd8ed1ab_0
	  - pixman=0.40.0=h36c2ea0_0
	  - pthread-stubs=0.4=h36c2ea0_1001
	  - python=3.9.5=h49503c6_0_cpython
	  - python_abi=3.9=1_cp39
	  - pytz=2021.1=pyhd8ed1ab_0
	  - r-assertthat=0.2.1=r40hc72bb7e_2
	  - r-backports=1.2.1=r40hcfec24a_0
	  - r-base=4.0.5=h9e01966_1
	  - r-brio=1.1.2=r40hcfec24a_0
	  - r-callr=3.7.0=r40hc72bb7e_0
	  - r-cli=2.5.0=r40hc72bb7e_0
	  - r-colorspace=2.0_1=r40hcfec24a_0
	  - r-crayon=1.4.1=r40hc72bb7e_0
	  - r-desc=1.3.0=r40hc72bb7e_0
	  - r-diffobj=0.3.4=r40hcfec24a_0
	  - r-digest=0.6.27=r40h03ef668_0
	  - r-ellipsis=0.3.2=r40hcfec24a_0
	  - r-evaluate=0.14=r40hc72bb7e_2
	  - r-fansi=0.5.0=r40hcfec24a_0
	  - r-farver=2.1.0=r40h03ef668_0
	  - r-ggplot2=3.3.4=r40hc72bb7e_0
	  - r-glue=1.4.2=r40hcfec24a_0
	  - r-gtable=0.3.0=r40hc72bb7e_3
	  - r-isoband=0.2.4=r40h03ef668_0
	  - r-jsonlite=1.7.2=r40hcfec24a_0
	  - r-labeling=0.4.2=r40hc72bb7e_0
	  - r-lattice=0.20_44=r40hcfec24a_0
	  - r-lifecycle=1.0.0=r40hc72bb7e_0
	  - r-magrittr=2.0.1=r40hcfec24a_1
	  - r-mass=7.3_54=r40hcfec24a_0
	  - r-matrix=1.3_4=r40he454529_0
	  - r-mgcv=1.8_36=r40he454529_0
	  - r-munsell=0.5.0=r40hc72bb7e_1003
	  - r-nlme=3.1_152=r40h859d828_0
	  - r-pillar=1.6.1=r40hc72bb7e_0
	  - r-pkgconfig=2.0.3=r40hc72bb7e_1
	  - r-pkgload=1.2.1=r40h03ef668_0
	  - r-praise=1.0.0=r40hc72bb7e_1004
	  - r-processx=3.5.2=r40hcfec24a_0
	  - r-ps=1.6.0=r40hcfec24a_0
	  - r-r6=2.5.0=r40hc72bb7e_0
	  - r-rcolorbrewer=1.1_2=r40h785f33e_1003
	  - r-rcpp=1.0.6=r40h03ef668_0
	  - r-rematch2=2.1.2=r40hc72bb7e_1
	  - r-rlang=0.4.11=r40hcfec24a_0
	  - r-rprojroot=2.0.2=r40hc72bb7e_0
	  - r-rstudioapi=0.13=r40hc72bb7e_0
	  - r-scales=1.1.1=r40hc72bb7e_0
	  - r-testthat=3.0.3=r40h03ef668_0
	  - r-tibble=3.1.2=r40hcfec24a_0
	  - r-utf8=1.2.1=r40hcfec24a_0
	  - r-vctrs=0.3.8=r40hcfec24a_1
	  - r-viridislite=0.4.0=r40hc72bb7e_0
	  - r-waldo=0.2.5=r40hc72bb7e_0
	  - r-withr=2.4.2=r40hc72bb7e_0
	  - readline=8.1=h46c0cb4_0
	  - sed=4.8=he412f7d_0
	  - sepp=4.4.0=py39_0
	  - setuptools=49.6.0=py39hf3d152e_3
	  - sqlite=3.35.5=h74cdb3f_0
	  - suitesparse=5.10.1=hd8046ac_0
	  - sysroot_linux-64=2.12=h77966d4_13
	  - tbb=2020.2=h4bd325d_4
	  - tigmint=1.2.3=py39h39abbe0_0
	  - tk=8.6.10=h21135ba_1
	  - tktable=2.10=hb7b940f_3
	  - tzdata=2021a=he74cb21_0
	  - ucsc-fatotwobit=377=h0b8a92a_4
	  - ucsc-twobitinfo=377=h0b8a92a_2
	  - wheel=0.36.2=pyhd3deb0d_0
	  - xorg-kbproto=1.0.7=h7f98852_1002
	  - xorg-libice=1.0.10=h7f98852_0
	  - xorg-libsm=1.2.3=hd9c2040_1000
	  - xorg-libx11=1.7.2=h7f98852_0
	  - xorg-libxau=1.0.9=h7f98852_0
	  - xorg-libxdmcp=1.1.3=h7f98852_0
	  - xorg-libxext=1.3.4=h7f98852_1
	  - xorg-libxrender=0.9.10=h7f98852_1003
	  - xorg-libxt=1.2.1=h7f98852_2
	  - xorg-renderproto=0.11.1=h7f98852_1002
	  - xorg-xextproto=7.3.0=h7f98852_1002
	  - xorg-xproto=7.0.31=h7f98852_1007
	  - xz=5.2.5=h516909a_1
	  - zlib=1.2.11=h516909a_1010
	  - zstd=1.5.0=ha95c52a_0
	prefix: ~/.conda/envs/busco-env
</details>

You then install it like this:

	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	# commented command is how this was made
	# conda create --name busco-env --channel bioconda --channel conda-forge busco=5.1.3
	conda env create -f busco-env.yml

Then, you'll need to find which dataset of genes you want to use. To do this, either activate the conda environment (if you have it) or load the module and run "busco --list-datasets". You'll see an output like this, with a taxonomic hierarchy. You should choose the one most representative of your dataset. We'll do an example for our Sage Grouse genome again. First, we'll scroll down to eurkaryotes (eukaryota_odb10), then animals (metazoa_odb10), and then vertrabrates (vertabrata_odb10) below. The smallest group for us to use is the set for all birds, which is "aves_odb10". You can see it used in our sample command below.

	- vertebrata_odb10
             - actinopterygii_odb10
                 - cyprinodontiformes_odb10
             - tetrapoda_odb10
                 - mammalia_odb10
                     - eutheria_odb10
                         - euarchontoglires_odb10
                             - glires_odb10
                             - primates_odb10
                         - laurasiatheria_odb10
                             - carnivora_odb10
                             - cetartiodactyla_odb10
                 - sauropsida_odb10
                     - aves_odb10
                         - passeriformes_odb10

Then you'll run BUSCO, which has a manual with full info on options [here](https://busco.ezlab.org/busco_userguide.html). It has the odd quick of requiring modifying a config file to have its output anywhere but the current directory, so we'll just have everything in the submission directory (note that if you already have that directory made, you need the --force or -f flag to overwrite it). The first two flags after our input genome (-i) and output directory (-o) are the number of cores to use (--cpus) and the mode. Because we are evaluating a reference genome, we'll use "--mode genome". Finally, we have the lineage dataset (-l), which is the "aves_odb10" from above.

	cd $PBS_O_WORKDIR
	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	source activate busco-test
	
	busco -i /projects/shared/tutorials/quickbytes/GATK/sagegrouse_reference.fa -o busco_test --cpu 8 --mode genome -l aves_odb10
	
The output from this is pretty straightforward, in the short summary file in the output directory (something like "short_summary.specific.aves_odb10.busco_test.txt"). An example of what to expect from the above command is below:

        C:95.1%[S:94.4%,D:0.7%],F:1.0%,M:3.9%,n:10844
        10319   Complete BUSCOs (C)
        10242   Complete and single-copy BUSCOs (S)
        77      Complete and duplicated BUSCOs (D)
        113     Fragmented BUSCOs (F)
        412     Missing BUSCOs (M)
        10844   Total BUSCO groups searched

Note that we have 95.1% complete BUSCOs, which is greater than the ideal 95%! Don't worry if yours is a bit lower. Other things to note, some of these complete BUSCOs are single-copy and even more are fragmented, so only 3.9% are fully missing.

## Citations ##

Gurevich, A., Saveliev, V., Vyahhi, N., & Tesler, G. (2013). QUAST: Quality assessment tool for genome assemblies. Bioinformatics, 29(8), 1072–1075. https://doi.org/10.1093/bioinformatics/btt086

Simão, F. A., Waterhouse, R. M., Ioannidis, P., Kriventseva, E. V., & Zdobnov, E. M. (2015). BUSCO: Assessing genome assembly and annotation completeness with single-copy orthologs. Bioinformatics, 31(19), 3210–3212. https://doi.org/10.1093/bioinformatics/btv351

