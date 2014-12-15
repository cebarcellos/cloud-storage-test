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
VM1_LINE="line 5 edited by $VM1_IP"
VM2_LINE="line 5 edited by $VM2_IP"
FILE_TMP=`mktemp` || exit 1
FILE_SYNC=file-merge-test.txt
trap "rm -f $FILE_TMP" 0 1 2 3 15

# Create a simple text file with 10 lines
> $FILE_TMP
for ((i=1; i<=10; i++))
do
	echo "line $i" >> $FILE_TMP
done

# Copy the new file to both VMs
scp -q $FILE_TMP $VM1_IP:"$SYNC_DIR/$FILE_SYNC"
scp -q $FILE_TMP $VM2_IP:"$SYNC_DIR/$FILE_SYNC"

# Edit it from inside of VM1. Edit line 5.
ssh ${VM1_IP} "sed -i \"5s/.*/$VM1_LINE/\" $SYNC_DIR/$FILE_SYNC
		exit"
# Edit it from inside of VM2. Edit line 5.
ssh ${VM2_IP} "sed -i \"5s/.*/$VM2_LINE/\" $SYNC_DIR/$FILE_SYNC
		exit"

exit 0

