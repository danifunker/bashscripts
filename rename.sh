#!/bin/bash
#for each folder...
#indexname="TxtGoesHere"
indexname=$1
# test [ - delimiter=$3
filnum=0
for folder in [0-9][0-9].*; do
	cd "$folder"
	#for each file
	for f in [0-9][0-9].*.mp4; do
		#do the rename
		mv "$f" "$indexname$delimiter$(printf "%03d\n" $filnum)-$f"
		#export filnum
		#increase the counter, note the filenum needs to be exported first because it is in a subshell
		filnum=$(($filnum + 1))
	done
	cd ..
done
