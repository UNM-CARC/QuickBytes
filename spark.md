## Spark

Apache Spark is a parallel/distributed computing environment designed for processing large, complex data sets. Compared to other large-scale parallel programming environments (e.g. MPI), it’s generally easier to program, especially for data-centric workloads. You basically write a Java, Scala, or Python program that coordinates parallel data processing by a large number of worker processes. In addition, Spark has extensions analyzing streaming data sets (Spark Streaming) and using machine learning techniques for analyzing data (Spark ML), making it ideal for many modern data-oriented research questions.
In this tutorial, we discuss how to run Spark on the UNM CARC cluster systems, using a Python-oriented example of analyzing Chicago crime data drawn from an excellent series of Spark Python examples provided by datascienceplus.com. Once you understand the basic Spark model, the main complications for running these examples on CARC are starting your personal Spark instance on which to run and then using that. The remainder of this page discusses on these issues, and shows how to set up a full-featured Spark environment on CARC systems using anaconda to run some of the examples from the tutorial linked above.

All of the files from this tutorial are available at http://lobogit.unm.edu/carc/tutorials/spark.

## The Basic Spark Model
Spark is what is referred to as a Single-Program-Multiple-Data (SPMD) parallel programming model. You write a single Spark program in the language of your choice that runs on a single master node (we’ll be using Python in this example), and that master orchestrates multiple parallel workers, each of which work on a subset of the overall data. Key to this is understanding and managing which (and how much) data resides on the master and which data is split across the workers in what Spark refers to as Resilient Distributed Datasets (RDDs). Note that while RDDs are the main abstraction Spark uses under the covers to manage distributed data, you will more likely use and manipulate Spark DataFrames, a higher-level version of RDDs akin to a large distributed table or spreadsheet.

The first thing to understand is that RDDs and DataFrames are spread among the parallel nodes and workers and they don’t change. Instead, you create a sequence of transformations that Spark executes when necessary to generate new DataFrames and RDDs from existing data (e.g. files) and RDDs/DataFrames, and you execute actions on RDDs to extract data from the workers back to your master program. It is important to remember that transformations are run in parallel across the Spark cluster, while actions generate data housed only on the master! As a result, actions that generate large amounts of data can cause your program to run out of memory, and activities that work on the results of actions do not happen in parallel!

## The Canonical Simple Example: Word count in Python
```# Create my Spark connection in Python
spark = SparkSession.builder.appName("WordCount").getOrCreate()
# Create an RDD from a text file
lines = spark.read.text(sys.argv[1]).rdd.map(lambda r: r[0])
# Generate a new RDD (via the map transformations run in parallel on workers) that splits the lines into words
words = lines.flatMap(lambda x: x.split(' '))
# And then another transformation that counts up the number of times each word appears
counts = words.map(lambda x: (x, 1)).reduceByKey(add)
# Execute an action that puts the resulting list of counts in an array of (word,count) pairs in the master program
output = counts.collect()
# Run (serially on the master only, since this isn’t Spark operations!) code to generate output.
for (word, count) in output:
        print("%s: %i" % (word, count))
```
## Running Spark at CARC
When you read Spark tutorials, you’ll see that it is generally run on dedicated per-user spark clusters, with the “spark-submit” script or “pyspark” commands used to talk to your cluster. You can do the same thing at CARC, but you’ll need to do a few things first:

Have a CARC project/account, for which you can find directions on the CARC website:
Log into a CARC shared cluster (we’ll be using wheeler.carc.unm.edu) using ssh or a similar tool (XXX This should link to our documentation on how to do that)

Use the PBS queueing system to request a set of nodes for your use (XXX This should link to our PBS information)
Run pbs-spark-submit on those nodes to start your personal spark instance (see below)

Talk to the spark workers using pyspark or spark-submit

Basically, pbs-submit-spark starts your personal Spark cluster (and optionally one job) using batch queueing information from PBS queueing system, and after that’s done you can use pyspark to talk to interactively or submit-spark to submit new Spark jobs to it. pbs-spark-submit is available at http://lobogit.unm.edu/carc/tutorials/spark/pbs-spark-submit.

## Simple CARC Spark Examples
1. Create an interactive 4-node cluster on Wheeler for 1 hour

```bridges@wheeler-sn[519]> ls big.txt  conf/  pbs-spark-submit*  small.txt
bridges@wheeler-sn[520]> cd
bridges@wheeler-sn[521]> qsub -I -l nodes=4:ppn=8 -l walltime=01:00:00
qsub: waiting for job 14319.wheeler-sn.alliance.unm.edu to start
qsub: job 14319.wheeler-sn.alliance.unm.edu ready
Job 14319.wheeler-sn.alliance.unm.edu running on nodes:
wheeler240 wheeler235 wheeler234 wheeler233
Wheeler Portable Batch System Prologue
Job Id: 14319.wheeler-sn.alliance.unm.edu
Username: bridges
Job 14319.wheeler-sn.alliance.unm.edu running on nodes:
wheeler240 wheeler235 wheeler234 wheeler233
prologue running on host: wheeler240
```

2. Start the Spark cluster on your wheeler nodes

```bridges@wheeler240[500]> cd /wheeler/scratch/bridges/spark
bridges@wheeler240[501]> module load spark-2.1.0-gcc-4.8.5-lifnga6
bridges@wheeler240[502]> export SPARK_HOME=$SPARK_DIR
bridges@wheeler240[503]> ./pbs-spark-submit
SPARK_MASTER_HOST=wheeler240
SPARK_MASTER_PORT=7077
bridges@wheeler240[504]> pyspark --master spark://wheeler240:7077
```

 3. Run Spark interactively

```>>> rddread = sc.textFile("small.txt")
>>> rddread.takeSample(False, 10, 2)
[u'a savage place as holy and enchanted ', u'huge fragments vaulted like rebounding hail ', u'   floated midway on the waves ', u'and all should cry beware beware ', u'and from this chasm with ceaseless turmoil seething ', u'enfolding sunny spots of greenery ', u'as if this earth in fast thick pants were breathing ', u'and drunk the milk of paradise', u'five miles meandering with a mazy motion ', u'where blossomed many an incensebearing tree ']
>>> exit()
bridges@wheeler240[505]> exit
qsub: job 14319.wheeler-sn.alliance.unm.edu completed
```
4. Spark jobs can be run in batch as well – The following PBS batch script would run the simple wordcount example from above, using the Wheeler scratch file system to store the data while it is being processed:

```# wordcount.pbs
#PBS -N wordcount
#PBS -l nodes=2:ppn=8
#PBS -l walltime=00:05:00
SCRATCHDIR=/wheeler/scratch/$USER/spark
module load spark-2.1.0-gcc-4.8.5-lifnga6
export SPARK_HOME=$SPARK_DIR
cd $PBS_O_WORKDIR
cp wordcount.py $SCRATCHDIR
cp big.txt $SCRATCHDIR
cp -r conf $SCRATCHDIR
cd $SCRATCHDIR
$PBS_O_WORKDIR/pbs-spark-submit wordcount.py       
$SCRATCHDIR/big.txt > wordcount.log
cp wordcount.log $PBS_O_WORKDIR
```
## A More Involved Example
To make the most of Spark, most programmers will want to do two things: use the DataFrames API and construct a more full-features Python programming environment in which to work and analyze data. While RDDs are the core Spark abstraction, the DataFrame API (available since Spark 2.0) is much more programmer friendly. In particular, DataFrames have columns and column operations, can import CSV and JSON data files, while still being distributed across the memory of all of the nodes in your Spark cluster. 16 Wheeler nodes can, for example, handle a 200GB table! Similarly, setting up a full-featured programming environment by using Anaconda will allow you to analyze and visualize your data much more effectively.

## Setting up a Full Python/Spark environment using Anaconda
As mentioned above and on other CARC web pages, we suggest that users use Anaconda to manage their python environments. This applies to Python+Spark as well with one exception – you want to get spark (and pyspark) from the Spark package so that it matches the version of Spark on your system instead of from Anaconda. To create this environment, simply run the following two commands:

```wheeler-sn> module load anaconda3-4.4.0-gcc-4.8.5-ubgzkkv
wheeler-sn> conda create –n spark python=27 numpy scipy pandas matplotlib
```
![SparkLogo](https://github.com/UNM-CARC/QuickBytes/blob/master/apache_spark_logo.jpeg) 

Once this is done, we just activate that environment and can add new things to it as needed after we launch our Spark cluster, to interactively look at a lot of data. First, we bring up Spark with this customized environment:

```wheeler-sn> qsub –I –l nodes=1:ppn=8 -l walltime=01:00:00
wheeler263> module load anaconda3-4.4.0-gcc-4.8.5-ubgzkkv
wheeler263> source activate spark
(spark) wheeler263> module load spark spark-2.1.0-gcc-4.8.5-lifnga6
(spark) wheeler263> export SPARK_HOME=$(SPARK_DIR)
(spark) wheeler263> ./pbs-spark-submit
(spark) wheeler263> pyspark –-master spark://wheeler263:7077
```

Once we have this running, we can simply load and analyze our data, first converting it into Spark Parquet format so that we can load and save it more quickly later:

```>>> crimes_schema = ... # available in source code files
>>> format = "MM/dd/yyyy hh:mm:ss a"
>>> crimes = spark.read.format("csv").options(header = 'true',dateFormat = format,timestampFormat = format).load("crimes.csv", schema = crimes_schema)
>>> count = crimes.count()
>>> print("Imported CSV with {} crime records.".format(count))
Imported CSV with 6614877 crime records

>>> crimes.write.parquet("crimes.parquet")
```

 From there, you can basically think of the resulting DataFrame as a SQL database or Excel sheet, turning the full power of Python and SQL loose on it, including computings averages, sorting or grouping it, adding columns, and doing proper SQL operations on it (selects, joins, pivots, etc.). For example, if you wanted to normalize the Latitudes in the table loaded above, you could the the following:

 

```>>> lat_mean = crimes.agg({"Latitude" : "mean"}).collect()[0][0]
>>> print("The mean latitude values is {}".format(lat_mean))
The mean latitude values is 41.8419399743

>>> df = crimes.withColumn("Lat(Norm)",lat_mean - crimes["Latitude"])
>>> df.select(["Latitude", "Lat(Norm)"]).show(3)
+------------+--------------------+
|    Latitude|    Lat(Norm)|
+------------+--------------------+

|41.987319201|-0.14537922670000114|
|41.868473957|-0.02653398270000...|
|41.742667249| 0.09927272529999698|

+------------+--------------------+
```

## Visualization of Data from Python
You can also use Pandas and Matplotlib and everything else on processed data, for example the following code generates a file which graphs Chicago crimes by month:

```import matplotlib as mpl
mpl.use('PDF’) # Live rendering over X11 requires ssh tunneling
import matplotlib.pyplot as plt
import pandas as pd
# And then do things like compute domestic crimes by month
from pyspark.sql.functions import month
monthdf = df.withColumn("Month",month("Date"))
monthCounts = monthdf.select("Month").groupBy("Month").count().collect()
months = [item[0] for item in monthCounts]
count = [item[1] for item in monthCounts]
crimes_per_month = pd.DataFrame({"month":months, "crime_count":
crimes_per_month = crimes_per_month.sort_values(by = "month")
crimes_per_month.plot(figsize = (20,10), kind = "line", x = "month", y = "crime_count", color = "red", linewidth = 8, legend = False)
plt.xlabel("Month", fontsize = 18)
plt.ylabel("Number of Crimes", fontsize = 18)
plt.title("Number of Crimes Per Month", fontsize = 28)
plt.xticks(size = 18)
plt.yticks(size = 18)
plt.savefig("crimes-by-month.pdf")
```
![Crimes](https://github.com/UNM-CARC/QuickBytes/blob/master/spark-image1.jpg) 

Similarly, this code generates a file which charts Chicago crime by location type:

```crime_location  = crimes.groupBy("LocationDescription").count().collect()
location = [item[0] for item in crime_location]
count = [item[1] for item in crime_location]
crime_location = {"location" : location, "count": count}
crime_location = pd.DataFrame(crime_location)
crime_location = crime_location.sort_values(by = "count", ascending  = False)
crime_location = crime_location.iloc[:20]
myplot = crime_location.plot(figsize =(20,20), kind="barh", color="#b35900", width = 0.8, x = "location", y = "count", legend = False)
myplot.invert_yaxis()
plt.xlabel("Number of crimes", fontsize = 28)
plt.ylabel("Crime Location", fontsize = 28)
plt.title("Number of Crimes By Location", fontsize = 36)
plt.xticks(size = 24)
plt.yticks(size = 24)
plt.savefig("crimes-by-location.pdf")
```
![Crimes](https://github.com/UNM-CARC/QuickBytes/blob/master/spark-image2.jpg) 


## More Information
In addition to all of this, there are a wide range of other things you can do with Spark.

Spark Streaming (add link) augments RDDs with Dstreams, data batched into N second chunks with one RDD per batch. Spark can automatically monitor data dumped into files or directories or message queues and fill them into Dstreams. Twitter sentiment analysis is a common use case (e.g. combined with a Kafka queue that Spark Streaming pulls from)
Spark ML (add link) provides a wide range of scalable regression, inference, clustering, and learning algorithms from Spark.
Finally, we’re working on an array of additional improvements on this at CARC in the long term, including making this accessible from Jupyter notebooks, and making it easier to interactively render data to your desktop (as opposed to into files like was done above).  Keep an eye out on the CARC website for additional information as these features develop.
