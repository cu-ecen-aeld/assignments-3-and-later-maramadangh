#!/bin/sh

filesDir=$1
searchstr=$2
directorynotfound=2
X=$(find $1 -type f | wc -l)
matchingfiles=$(grep -rl $searchstr $filesDir)
if [ $2 ]
then
	Y=$(grep -rn $searchstr $matchingfiles | wc -l )
	if [ $? -eq $directorynotfound ]
	then
		echo "Directory not found"
		exit 1
	else
		#echo ""
		echo "The number of files are" $X "and the number of matching lines are" $Y
		exit 0
	fi
else
	echo "Nedded Paramters are not specified"
	exit 1
fi
