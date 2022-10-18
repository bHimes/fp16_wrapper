#!/bin/bash

if [ ! $1 ] ; then
    echo "Input number of threads for cleanup and then compression by bzip2"
    exit 1
fi

n_threads=$1

ls *_fp16.mrc | while read a; do b=$(basename $a _fp16.mrc) ; rm -f $b.mrc ; done

ls *.mrc | parallel -j${n_threads} bzip2 -9 {}


