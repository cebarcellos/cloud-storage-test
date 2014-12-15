#!/bin/bash

# Create 10k files at a time until 1 million.
# The file names are "file_0000001.txt .. file_1000000.txt" and the content is its name.

cd $1

echo ""
num_of_files_created=0
num_of_1st_file=100001
num_of_last_file=200000

for file_num in $(seq -f "%07g" $num_of_1st_file $num_of_last_file)
do
	file_name=file_${file_num}.txt
	echo -n $file_name > $file_name

	num_of_files_created=$((num_of_files_created + 1))
	if [ $(($num_of_files_created % 1000)) == 0 ] ; then
		echo -e -n "$file_name\r"
	fi
done
echo $num_of_files_created files created.
date

# Check integrity
for file_num in $(seq -f "%07g" $num_of_1st_file $num_of_last_file)
do
	file_name=file_${file_num}.txt
	file_content=`cat $file_name`

	if [ "$file_name" != "$file_content" ] ; then
		echo ! Error creating file ${file_name}.
	fi
done
