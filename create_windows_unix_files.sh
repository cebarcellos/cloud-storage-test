#!/bin/bash

for ((i=1; i<10; i++))
do
	echo "line $i LF terminated" >> text_unix_format.txt
done

for ((i=1; i<10; i++))
do
	echo -e -n "line $i CRLF terminated\r\n" >> text_windows_format.txt
done

