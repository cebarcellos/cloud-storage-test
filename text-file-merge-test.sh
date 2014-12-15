#!/bin/bash

cat <<-EOF
Use 'ssh-copy-id user@hostname.example.com' to copy public key of both VMs, thus
the file editing will be faster and you won't be asked for the password.
EOF

if [ $# -ne 3 ] ; then
	echo "Usage: $(basename $0) <VM#1 IP> <VM#2 IP> <sync dir>"
	echo ""
	exit 1
fi

VM1_IP=$1
VM2_IP=$2
SYNC_DIR=$3
VM1_LINE="line 5 edited by $VM1_IP"
VM2_LINE="line 5 edited by $VM2_IP"
FILE=file-merge-test.txt

# Create a simple text file with 10 lines
> $FILE
for ((i=1; i<=10; i++))
do
	echo "line $i" >> $FILE
done

# Copy the new file to both VMs
scp -q $FILE $VM1_IP:$SYNC_DIR
scp -q $FILE $VM2_IP:$SYNC_DIR

# Edit it from inside of VM1. Edit line 5.
ssh ${VM1_IP} "sed -i \"5s/.*/$VM1_LINE/\" $SYNC_DIR/$FILE
		exit"
# Edit it from inside of VM2. Edit line 5.
ssh ${VM2_IP} "sed -i \"5s/.*/$VM2_LINE/\" $SYNC_DIR/$FILE
		exit"

exit 0

