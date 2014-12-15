#!/bin/bash

cd $1

# Test the basic file permissions
for who in user group other ; do
	for permission in "read" write execute ; do
		file_name=file_${permission}_only_${who}

		if [ "$who" = "user" ] ; then
			group=u
		elif [ "$who" = "group" ] ; then
			group=g
		else
			group=o
		fi
		if [ "$permission" = "read" ] ; then
			mode=r
		elif [ "$permission" = "write" ] ; then
			mode=w
		else
			mode=x
		fi

		touch $file_name
		chmod 000 $file_name
		chmod $group=$mode $file_name
	done
done

# Test the basic directory permissions
for who in user group other ; do
	for permission in "read" write execute ; do
		dir_name=dir_${permission}_only_${who}

		if [ "$who" = "user" ] ; then
			group=u
		elif [ "$who" = "group" ] ; then
			group=g
		else
			group=o
		fi
		if [ "$permission" = "read" ] ; then
			mode=r
		elif [ "$permission" = "write" ] ; then
			mode=w
		else
			mode=x
		fi

		mkdir $dir_name
		chmod 000 $dir_name
		chmod $group=$mode $dir_name
	done
done
