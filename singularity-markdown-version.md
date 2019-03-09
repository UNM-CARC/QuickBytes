# Docker and Singularity

## Introduction

Have you ever installed software on your own system to process data, but then find it is not so easy to setup the same environment on a CARC cluster when you want to process larger data sets? CARC staff will work with you to get your software running, but occasionally we run across fundamental incompatibilities. Docker allows us to circumvent those incompatibilities.

Docker and Singularity are free tools that allow you to run software with dependencies on its environment that are difficult to satisfy natively on the CARC clusters. For example, your software might depend on a particular flavor of linux that differs from the one installed on the cluster you want to use. Perhaps your software needs to make global changes to the operating system that are incompatible with the needs of the center or other users. Docker allows us to deploy software with these requirements.

In this guide you will learn how to setup your software to run in a docker container, and how to convert the container to singularity and run it at CARC. The R software package party.

>In the example below commands to enter are given in <code><font color="Green">Green</font></code> and the resulting output is given in <code><font color="Navy">Navy</font></code>.

## What is Docker?

Docker allows you to setup a virtual environment for your program that you can configure however you like. You can choose the underlying operating system (so long as it is linux based), install any packages you need, and make any other changes the root user could make. The custom OS environment is stored in a docker image file that can be loaded by any docker installation. Docker has online repositories with many pre-built images available to download.

When loaded, a docker image provides a container that allows the software to have complete control of its environment without effecting the host operating system.

If you have used a virtual machine (such as virtualbox, or vmware) the description of docker images will sound familiar. The main difference is that docker just containerizes the environment but still uses the host operating system's kernel. This means there is very little performance impact.

## What is Singularity?

Singularity is able to convert and run docker images into a secure form suitable for multiuser machines such as the CARC clusters.

## Installing Docker

Docker runs on Microsoft Windows, Apple OS X, and Linux. All the systems at CARC are linux based so you will need to create and configure a linux based docker container. OS X and Linux will allow you to do this. Windows 10 can as well but you need to install the Windows Subsystem for Linux and a linux distribution.

Docker can be downloaded from www.docker.com.

## Running Docker

To start docker under Windows or OS X just launch the program like you would any other. To start the docker daemon under linux enter:

`sudo systemctl start docker`

## Creating a Docker Image

### Pulling an existing base docker image

For this example we are going to use an existing docker image that has the CentOS linux distribution preconfigured. We could just as easily use Ubuntu by replacing "centos" with "ubuntu" below.

```bash
docker pull centos
Using default tag: latest Trying to pull
repository docker.io/library/centos ...
latest: Pulling from docker.io/library/centos
a02a4930cb5d: Pull complete
Digest:sha256:184e5f35598e333bfa7de10d8fb1cebb5ee4df5bc0f970bf2b1e7c7345136426
Status: Downloaded newer image for docker.io/centos:latest
```

We can now issue a command that runs inside the docker container and returns output. Below we run the `ls -la` command to get a file listing inside the container.

```
docker run centos ls
anaconda-post.log
bin
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
```

### Customizing the docker image

Now we can install the program we need inside the docker container and any dependencies it needs. It is convenient to do this interactively inside the container. Configuring the container in interactive mode allows us to do everything we need to do before saving the changes to a docker image. If we issued commands one-by-one with run we would lose the state of the container after each command.

```
docker run -it centos

[root@a264d0f7b8c9 /]#
```

The long string after `@` is the name of the container we are running in. Notice it is not the same name as the docker image.

In a new terminal we can list the running docker containers and see that our container is running.

```
docker container list
CONTAINER ID  IMAGE   COMMAND      CREATED             STATUS  		PORTS  NAMES
a264d0f7b8c9  centos  "/bin/bash"  About a minute ago  Up About a minute  striking_mahavira
```

### Example: Installing the "party" R package

As an example, we will install party. Party is an R package for recursive partitioning. It produces regression trees for machine learning. But you can install whatever tools you wish. This is the beauty of docker, it gives you control over your environment.

```
[root@a264d0f7b8c9 /]# yum update 
[root@a264d0f7b8c9 /]# yum -y install epel-release 
[root@a264d0f7b8c9 /]# yum install R
```

Once R has finished installing:

```
[root@a264d0f7b8c9 /]# R

R version 3.5.0 (2018-04-23) -- "Joy in Playing"
Copyright (C) 2018 The R Foundation for Statistical Computing
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

>install.packages("party",deps=YES)
```

## Commit customised container to image file

Once party has finished installing, our Docker container is ready. Now we need to commit those changes to a docker image file so we can load the image that has R and party installed for future use.

Exit R:

```
[root@a264d0f7b8c9 /]# > quit()
```

Exit the docker container:

In general:

```
[root@a264d0f7b8c9 /]# exit
$ sudo docker commit
```

For our example:

```
[root@a264d0f7b8c9 /]# exit
$ sudo docker commit a264d0f7b8c9 r_party
```

Now we have a docker image saved.

## Running Commands using the Docker Image

Now that we have a docker image we can run it on our own machines as before with:

```
docker run r_party ls
```

But now we can also execute R commands such as: 

```
docker run r_party Rscript
```

For our party example we can write the following R script and save it to a file called test_party.R:

```
library("party")
set.seed(290875)
### honest (i.e., out-of-bag) cross-classification of
### true vs. predicted classes
data("mammoexp", package = "TH.data")
table(mammoexp$ME, predict(cforest(ME ~ ., data = mammoexp,
control = cforest_unbiased(ntree = 50)),
OOB = TRUE))
### fit forest to censored response
if (require("TH.data") && require("survival")) {
data("GBSG2", package = "TH.data")
bst <- cforest(Surv(time, cens) ~ ., data = GBSG2,
control = cforest_unbiased(ntree = 50))
### estimate conditional Kaplan-Meier curves
treeresponse(bst, newdata = GBSG2[1:2,], OOB = TRUE)
party:::prettytree(bst@ensemble[[1]], names(bst@data@get("input")))
```

And run it using the docker image with:

```
$ docker run -v < path to test_party.R folder > :/mnt r_party Rscript /mnt/test_party.R
```

# Singularity

## Converting Docker Images to Singularty Images

Once we are happy with the docker image we created we will convert it to a singularity image so we can use it on the CARC clusters.

We do the conversion by using a docker image provided to us that contains the necessary tools:

```
$ docker pull singularityware/docker2singularity
$ docker run -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/output --privileged -t --rm singularityware/docker2singularity r_party
```

This will produce a singularity image in the /tmp directory that we can upload to a CARC cluster using our favorite file transfer program.

## Running a Singularity Image at CARC

First login to a CARC cluster head node.

Next we will load the singularity module:

```
$ module load singularity-2.4.1-intel-17.0.4-sjwoqj4 $
```

The syntax for executing Singularity images are similar to those we used for docker:

```
$ singularity exec r_party.simg Rscript test_party.R
```

## Mapping Directories

```
$ singularity -B $PBS_O_WORKDIR:/mnt exec r_party.simg Rscript test_party.R
```
The Above command maps the directory that that PBS script was submitted from, `$PBS_O_WORKDIR`, to the `/mnt` location within the `r_party.simg` singularity image and then executes the `test_party.R` script. 

