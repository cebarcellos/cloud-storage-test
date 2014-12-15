#!/bin/bash

file=$1
size=$2

dd if=/dev/urandom of=$file bs=$size count=1
