#!/bin/bash

# Create 10k files at a time until 1 million.
# The file names are "file_0000001.txt .. file_1000000.txt" and the content is its name.

cd $1

num_of_1st_file=1
num_of_last_file=20000
new_dir=0001000

echo -e "\nCreating files"

num_of_files_created=0
for file_num in $(seq -f "%07g" $num_of_1st_file $num_of_last_file)
do
	file_name=file_${file_num}.txt

	if [ $(($num_of_files_created % 1000)) == 0 ] ; then
		echo -e -n "$file_name\r"
		new_dir=$(($num_of_files_created + 1000))
		new_dir=`printf "%07d" $new_dir`
		mkdir -p $new_dir
	fi

	echo -n $file_name > $new_dir/$file_name
	num_of_files_created=$((num_of_files_created + 1))
done
echo $num_of_files_created files created.
date

echo -e "\nChecking integrity"

num_of_files_checked=0
for file_num in $(seq -f "%07g" $num_of_1st_file $num_of_last_file)
do
	file_name=file_${file_num}.txt

	if [ $(($num_of_files_checked % 1000)) == 0 ] ; then
		echo -e -n "$file_name\r"
		new_dir=$(($num_of_files_checked + 1000))
		new_dir=`printf "%07d" $new_dir`
	fi

	file_content=`cat $new_dir/$file_name`

	if [ "$file_name" != "$file_content" ] ; then
		echo ! Error creating file ${file_name}.
	fi
	num_of_files_checked=$((num_of_files_checked + 1))
done
echo Done

