#!/bin/sh


if [ $2 ]
then
	diname=$(dirname $1)
	mkdir -p "$diname"
	echo $2 >| $1
	if [ $? != '0' ]
	then
		exit 1
	else
		exit 0
	fi
else
	exit 1
fi
