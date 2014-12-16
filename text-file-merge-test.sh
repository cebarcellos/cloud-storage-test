#!/bin/bash

cat <<-EOF
################################################################################
# Some tips:                                                                   #
#                                                                              #
# Use 'ssh-copy-id user@hostname.example.com' to copy public key of both VMs,  #
# thus the file editing will be faster and you won't be asked for the password.#
#                                                                              #
# If sync path has spaces, double-quote the entire path and precede spaces     #
# with '\'                                                                     #
################################################################################

EOF

if [ $# -ne 3 ] ; then
	echo "Usage: $(basename $0) <VM#1 IP> <VM#2 IP> <sync path>"
	echo ""
	exit 1
fi

VM1_IP=$1
VM2_IP=$2
SYNC_DIR=$3
FILE_TMP=`mktemp` || exit 1
FILE_EDIT_CONFLICT=file-edit-conflict-test.txt
FILE_RM_CONFLICT=file-remove-conflict-test.txt
FILE_PARALLEL_EDIT=file-parallel-edit-test.txt
trap "rm -f $FILE_TMP" 0 1 2 3 15

# Create a simple text file with 10 lines
> $FILE_TMP
for ((i=1; i<=10; i++))
do
	echo "line $i" >> $FILE_TMP
done

# Copy the new file to both VMs
scp -q $FILE_TMP $VM1_IP:"$SYNC_DIR/$FILE_EDIT_CONFLICT"
scp -q $FILE_TMP $VM1_IP:"$SYNC_DIR/$FILE_RM_CONFLICT"
scp -q $FILE_TMP $VM1_IP:"$SYNC_DIR/$FILE_PARALLEL_EDIT"

# Wait until both VMs are synced
echo Waiting for VMs to be synced
files_synced=0
file_idx=0
sleep 3
while [ $files_synced != 3 ]
do
	file_idx=$(($file_idx + 1))
	if [ $file_idx = 0 ] ; then
		file=$SYNC_DIR/$FILE_EDIT_CONFLICT
	elif [ $file_idx = 1 ] ; then
		file=$SYNC_DIR/$FILE_RM_CONFLICT
	else
		file=$SYNC_DIR/$FILE_PARALLEL_EDIT
		file_idx=0
	fi

	if ssh ${VM2_IP} stat $file \> /dev/null 2\>\&1 ; then
		files_synced=$(($files_synced + 1))
		echo "$files_synced file(s) synced on VM $VM2_IP"
	fi
	sleep 1
done

# Conflicting edition
vm1_line="line 5 edited by $VM1_IP"
vm2_line="line 5 edited by $VM2_IP"
# Edit it from inside of VM1. Edit line 5.
ssh ${VM1_IP} "sed -i \"5s/.*/$vm1_line/\" $SYNC_DIR/$FILE_EDIT_CONFLICT
		exit" &
# Edit it from inside of VM2. Edit line 5.
ssh ${VM2_IP} "sed -i \"5s/.*/$vm2_line/\" $SYNC_DIR/$FILE_EDIT_CONFLICT
		exit" &
wait

# Conflicting remove
vm1_line="line 5 edited by $VM1_IP"
# Edit it from inside of VM1. Edit line 5.
ssh ${VM1_IP} "sed -i \"5s/.*/$vm1_line/\" $SYNC_DIR/$FILE_RM_CONFLICT
		exit" &
# Edit it from inside of VM2. Edit line 5.
ssh ${VM2_IP} "rm $SYNC_DIR/$FILE_RM_CONFLICT
		exit" &
wait

# Parallel edition w/o conflict
vm1_line="line 4 edited by $VM1_IP"
vm2_line="line 5 edited by $VM2_IP"
# Edit it from inside of VM1. Edit line 4.
ssh ${VM1_IP} "sed -i \"4s/.*/$vm1_line/\" $SYNC_DIR/$FILE_PARALLEL_EDIT
		exit" &
# Edit it from inside of VM2. Edit line 5.
ssh ${VM2_IP} "sed -i \"5s/.*/$vm2_line/\" $SYNC_DIR/$FILE_PARALLEL_EDIT
		exit" &
wait

exit 0

