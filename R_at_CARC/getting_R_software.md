# Running R on HPC systems (well, on CARC systems)

## Getting R in the first place

There are three options for accessing R at Carc and I will run through both approaches since there are pros and cons to each.
### Option 1
The first option is to activate an installed R module. When logged in to a CARC system you can use the `module avail` command to see which R versions are available. If you have a CARC account open a terminal and log in to follow along. 

```
yourusername@wheeler-sn$ module avail r-
```

which will print out the following (although I have truncated the output):

```
----------------------- /opt/spack/share/spack/modules/linux-centos7-x86_64 ------------------------
   ...
   r-3.4.1-gcc-4.8.5-python2-gzeg24m
   r-3.4.1-gcc-4.8.5-python2-zpkgqap
   r-3.4.1-intel-17.0.4-mkl-python2-67zsm3b
   r-3.4.1-intel-17.0.4-mkl-python2-gygkoab
   r-3.4.2-intel-18.0.2-python2-xsxuxwx
   r-3.4.3-gcc-4.8.5-python2-gk66fni
   r-3.4.3-gcc-4.8.5-python2-qv6gwz6
   r-3.4.3-gcc-6.1.0-python2-lyqiytq
   r-3.4.3-gcc-7.3.0-python2-zhxbajj
   r-3.4.3-intel-18.0.1-python2-3l4dkgz
   r-3.4.3-intel-18.0.1-python2-lr24ix6
   r-3.4.3-intel-18.0.2-python2-q3covk7
   r-3.5.0-gcc-4.8.5-python2-khqxja7
   r-3.5.0-gcc-7.3.0-python2-rvq3qk5
   r-3.5.0-intel-18.0.2-python2-mkl-r6lx6yy
   r-3.5.3-gcc-7.3.0-python2-ziiolp5
   r-3.6.0-gcc-4.8.5-python2-i4uimtp
   r-3.6.0-gcc-7.3.0-python2-7akol5t
   ...
Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```

These are all of the currently available R modules installed on Wheeler. In order to activate a R software module you use the `module load` command. For example:

```
yourusername@wheeler-sn$ module load r-3.6.0-gcc-7.3.0-python2-7akol5t
yourusername@wheeler-sn$ R

R version 3.6.0 (2019-04-26) -- "Planting of a Tree"
Copyright (C) 2019 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> 
```

Will load R-3.6.0 that has been compiled with GCC-7.3.0. Normally you will be running R jobs in batch mode as oppposed to interactively, which means you will have the `module load` command in your PBS script, but we will get to that later. 

### Option 2
The second option is to create a custom local Anaconda environment with the version of R that would like to run. In order to do this you need to first load an Anaconda software module and then create a new environment according to your specifications. For example, the following commands will create an Anaconda environment with R-3.4.3:

```
yourusername@wheeler-sn$ module load anaconda3
yourusername@wheeler-sn$ conda create --yes --name my_r_env r=3.4.3
Solving environment: done

## Package Plan ##

environment location: /users/yourusername/.conda/envs/my_r_env

added / updated specs: 
- r=3.4.3


The following packages will be downloaded:

package                    |            build
---------------------------|-----------------
gfortran_linux-64-7.3.0    |       h553295d_8         148 KB
r-cluster-2.0.6            |   r343h4829c52_0         519 KB
r-lattice-0.20_35          |   r343h086d26f_0         713 KB
r-base-3.4.3               |       h9bb98a2_5        38.3 MB
r-recommended-3.4.3        |           r343_0           3 KB
r-3.4.3                    |           r343_0           3 KB
r-mgcv-1.8_22              |   r343h086d26f_0         2.4 MB
r-matrix-1.2_12            |   r343h086d26f_0         2.5 MB
r-kernsmooth-2.23_15       |   r343h4829c52_4         101 KB
r-class-7.3_14             |   r343h086d26f_4          93 KB
r-nlme-3.1_131             |   r343h4829c52_0         2.2 MB
r-foreign-0.8_69           |   r343h086d26f_0         256 KB
r-survival-2.41_3          |   r343h086d26f_0         5.1 MB
gcc_linux-64-7.3.0         |       h553295d_8         149 KB
r-spatial-7.3_11           |   r343h086d26f_4         140 KB
gcc_impl_linux-64-7.3.0    |       habb00fd_1        73.2 MB
gxx_impl_linux-64-7.3.0    |       hdf63c60_1        18.7 MB
gxx_linux-64-7.3.0         |       h553295d_8         148 KB
r-boot-1.3_20              |   r343h889e2dd_0         625 KB
binutils_linux-64-2.31.1   |       h6176602_8         148 KB
r-mass-7.3_48              |   r343h086d26f_0         1.1 MB
bzip2-1.0.8                |       h7b6447c_0         105 KB
ca-certificates-2019.5.15  |                1         134 KB
r-codetools-0.2_15         |   r343h889e2dd_0          49 KB
r-rpart-4.1_11             |   r343h086d26f_0         899 KB
r-nnet-7.3_12              |   r343h086d26f_0         118 KB
libxml2-2.9.9              |       hea5a465_1         2.0 MB
------------------------------------------------------------
                                       Total:       149.8 MB

The following NEW packages will be INSTALLED:

_libgcc_mutex:          0.1-main               
_r-mutex:               1.0.0-anacondar_1      
binutils_impl_linux-64: 2.31.1-h6176602_1      
binutils_linux-64:      2.31.1-h6176602_8      
bwidget:                1.9.11-1               
bzip2:                  1.0.8-h7b6447c_0       
ca-certificates:        2019.5.15-1            
cairo:                  1.14.12-h8948797_3     
curl:                   7.65.2-hbc83047_0      
fontconfig:             2.13.0-h9420a91_0      
freetype:               2.9.1-h8a8886c_1       
fribidi:                1.0.5-h7b6447c_0       
gcc_impl_linux-64:      7.3.0-habb00fd_1       
gcc_linux-64:           7.3.0-h553295d_8       
gfortran_impl_linux-64: 7.3.0-hdf63c60_1       
gfortran_linux-64:      7.3.0-h553295d_8       
glib:                   2.56.2-hd408876_0      
graphite2:              1.3.13-h23475e2_0      
gxx_impl_linux-64:      7.3.0-hdf63c60_1       
gxx_linux-64:           7.3.0-h553295d_8       
harfbuzz:               1.8.8-hffaf4a1_0       
icu:                    58.2-h9c2bf20_1        
jpeg:                   9b-h024ee3a_2          
krb5:                   1.16.1-h173b8e3_7      
libcurl:                7.65.2-h20c2e04_0      
libedit:                3.1.20181209-hc058e9b_0
libffi:                 3.2.1-hd88cf55_4       
libgcc-ng:              9.1.0-hdf63c60_0       
libgfortran-ng:         7.3.0-hdf63c60_0       
libpng:                 1.6.37-hbc83047_0      
libssh2:                1.8.2-h1ba5d50_0       
libstdcxx-ng:           9.1.0-hdf63c60_0       
libtiff:                4.0.10-h2733197_2      
libuuid:                1.0.3-h1bed415_2       
libxcb:                 1.13-h1bed415_1        
libxml2:                2.9.9-hea5a465_1       
ncurses:                6.1-he6710b0_1         
openssl:                1.1.1c-h7b6447c_1      
pango:                  1.42.4-h049681c_0      
pcre:                   8.43-he6710b0_0        
pixman:                 0.38.0-h7b6447c_0      
r:                      3.4.3-r343_0           
r-base:                 3.4.3-h9bb98a2_5       
r-boot:                 1.3_20-r343h889e2dd_0  
r-class:                7.3_14-r343h086d26f_4  
r-cluster:              2.0.6-r343h4829c52_0   
r-codetools:            0.2_15-r343h889e2dd_0  
r-foreign:              0.8_69-r343h086d26f_0  
r-kernsmooth:           2.23_15-r343h4829c52_4 
r-lattice:              0.20_35-r343h086d26f_0 
r-mass:                 7.3_48-r343h086d26f_0  
r-matrix:               1.2_12-r343h086d26f_0  
r-mgcv:                 1.8_22-r343h086d26f_0  
r-nlme:                 3.1_131-r343h4829c52_0 
r-nnet:                 7.3_12-r343h086d26f_0  
r-recommended:          3.4.3-r343_0           
r-rpart:                4.1_11-r343h086d26f_0  
r-spatial:              7.3_11-r343h086d26f_4  
r-survival:             2.41_3-r343h086d26f_0  
readline:               7.0-h7b6447c_5         
tk:                     8.6.8-hbc83047_0       
tktable:                2.10-h14c3975_0        
xz:                     5.2.4-h14c3975_4       
zlib:                   1.2.11-h7b6447c_3      
zstd:                   1.3.7-h0b5b093_0       


Downloading and Extracting Packages
gfortran_linux-64-7. |  148 KB | ########################################################### | 100% 
r-cluster-2.0.6      |  519 KB | ########################################################### | 100% 
r-lattice-0.20_35    |  713 KB | ########################################################### | 100% 
r-base-3.4.3         | 38.3 MB | ########################################################### | 100% 
r-recommended-3.4.3  |    3 KB | ########################################################### | 100% 
r-3.4.3              |    3 KB | ########################################################### | 100% 
r-mgcv-1.8_22        |  2.4 MB | ########################################################### | 100% 
r-matrix-1.2_12      |  2.5 MB | ########################################################### | 100% 
r-kernsmooth-2.23_15 |  101 KB | ########################################################### | 100% 
r-class-7.3_14       |   93 KB | ########################################################### | 100% 
r-nlme-3.1_131       |  2.2 MB | ########################################################### | 100% 
r-foreign-0.8_69     |  256 KB | ########################################################### | 100% 
r-survival-2.41_3    |  5.1 MB | ########################################################### | 100% 
gcc_linux-64-7.3.0   |  149 KB | ########################################################### | 100% 
r-spatial-7.3_11     |  140 KB | ########################################################### | 100% 
gcc_impl_linux-64-7. | 73.2 MB | ########################################################### | 100% 
gxx_impl_linux-64-7. | 18.7 MB | ########################################################### | 100% 
gxx_linux-64-7.3.0   |  148 KB | ########################################################### | 100% 
r-boot-1.3_20        |  625 KB | ########################################################### | 100% 
binutils_linux-64-2. |  148 KB | ########################################################### | 100% 
r-mass-7.3_48        |  1.1 MB | ########################################################### | 100% 
bzip2-1.0.8          |  105 KB | ########################################################### | 100% 
ca-certificates-2019 |  134 KB | ########################################################### | 100% 
r-codetools-0.2_15   |   49 KB | ########################################################### | 100% 
r-rpart-4.1_11       |  899 KB | ########################################################### | 100% 
r-nnet-7.3_12        |  118 KB | ########################################################### | 100% 
libxml2-2.9.9        |  2.0 MB | ########################################################### | 100% 
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use:
# > source activate my_r_env
#
# To deactivate an active environment, use:
# > source deactivate
#
```
Then to use your newly created R environment you need to 1) make sure you have the Anaconda software module loaded, and 2), activate your conda envioronment.

```
yourusername@wheeler-sn$ module load anaconda3
yourusername@wheeler-sn$ source activate my_r_env
yourusername@wheeler-sn$ R

R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
Copyright (C) 2017 The R Foundation for Statistical Computing
Platform: x86_64-conda_cos6-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> 
```
### Option 3

The third option is to user JupyterHub. To do so direct your browser to https://wheeler.alliance.unm.edu:8000 and log in with your CARC credentials. Click on the "New" drop down menu and select "R". Now you have a R session running on Wheeler through JupyterHub. 
