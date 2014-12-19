#!/bin/bash

# Create 10k files at a time until 1 million.
# The file names are "file_0000001.txt .. file_1000000.txt" and the content is its name.

#cd $1

VM1_IP=$1
VM2_IP=$2
SYNC_DIR="$3"
num_of_1st_file=1
num_of_last_file=200000
num_files_per_dir=1000

function create_range_of_files {
	first=$1
	last=$2

	new_dir=`printf "%07d" $first`_`printf "%07d" $last`
	ssh $VM1_IP bash -c "'
		mkdir -p $SYNC_DIR/$new_dir
		cd $SYNC_DIR/$new_dir

		for file_num in \$(seq -f "%07g" $first $last) ; do
			file_name=file_\${file_num}.txt
			echo -n \$file_name > \$file_name
		done
	'"
}

# Check how much time is needed to sync on another host
# fazer um desenho ?
function check_files_sync {
	first=$1
	last=$2

	new_dir=`printf "%07d" $first`_`printf "%07d" $last`
	ssh $VM2_IP bash -c "'
		mkdir -p $SYNC_DIR/$new_dir
		cd $SYNC_DIR/$new_dir

		for file_num in \$(seq -f "%07g" $first $last) ; do
			file_name=file_\${file_num}.txt

			while ! stat \$file_name > /dev/null 2>&1 ; do
				sleep 0.5
			done
			echo -e -n \$file_num \"\r\"
		done
	'"
}

# Ask for SSH public key before the first connection
#ssh-copy-id $VM1_IP
#ssh-copy-id $VM2_IP

echo -e "\nCreating files"
echo -e "0000000\t\t`date`"
STARTTIME=$(date +%s)

for ((i=$num_of_1st_file; i<=$num_of_last_file; i=$(($i + $num_files_per_dir))))
do
	first_file=$i
	last_file=$(($i + $num_files_per_dir - 1))

	create_range_of_files $first_file $last_file

	check_files_sync $first_file $last_file

	ENDTIME=$(date +%s)
	printf "%07d\t\t" $last_file
	echo $(($ENDTIME - $STARTTIME))
done
echo $num_of_last_file files created.

exit 0

echo -e "\nChecking integrity"

num_of_files_checked=0
for file_num in $(seq -f "%07g" $num_of_1st_file $num_of_last_file)
do
	file_name=file_${file_num}.txt

	if [ $(($num_of_files_checked % $num_files_per_dir)) == 0 ] ; then
		echo -e -n "$file_name\r"
		new_dir=$(($num_of_files_checked + $num_files_per_dir))
		new_dir=`printf "%07d" $new_dir`
	fi

	file_content=`cat $new_dir/$file_name`

	if [ "$file_name" != "$file_content" ] ; then
		echo ! Error creating file ${file_name}.
	fi
	num_of_files_checked=$((num_of_files_checked + 1))
done
echo Done

