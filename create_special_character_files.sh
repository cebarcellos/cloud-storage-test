#!/bin/bash

function create_file() {
	
	hex=$(printf "%.2X\n" $1)
	file_name="file_`echo -e "\x${hex}"`_.txt"
	echo "chaves" > "$file_name"
	echo "file $file_name created"
}

for ((i=32; i<=46; i++)) ; do
	create_file $i
done

for ((i=58; i<=64; i++)) ; do
	create_file $i
done

for ((i=91; i<=96; i++)) ; do
	create_file $i
done

for ((i=123; i<=126; i++)) ; do
	create_file $i
done

