#!/usr/bin/env python3
"""
wordcount.py — Simple Spark word count example.
Compatible with Spark 3.5+ and Python 3.9+.

Usage:
    spark-submit --master <master_url> wordcount.py <input_file>
"""

import sys
from operator import add
from pyspark.sql import SparkSession


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input_file>", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]

    spark = (
        SparkSession.builder
        .appName("WordCount")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")

    lines = spark.read.text(input_path).rdd.map(lambda r: r[0])
    words = lines.flatMap(lambda line: line.split())
    counts = words.map(lambda word: (word, 1)).reduceByKey(add)

    output = counts.collect()
    for word, count in sorted(output, key=lambda x: -x[1])[:20]:
        print(f"{word}: {count}")

    spark.stop()


if __name__ == "__main__":
    main()
