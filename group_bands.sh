#!/bin/bash

####	Initialize variables	####

WORKSPACE=$(echo ~/.sb_bandarchiver)				#Set workspace directory
FINAL_BAND=2560;						#Hardcoded final band
ARCHIVE_SIZE=10							#Archive size in GiB
files_per_archive=$(expr $(expr $ARCHIVE_SIZE \* 1024) / 8)	#Calculate archive filecount


####	Initialize workspace	####

if [ -e $WORKSPACE ]
then
	rm $WORKSPACE/counted; rm $WORKSPACE/queues/*
fi
if [ ! -e $WORKSPACE ]
then
	mkdir $WORKSPACE;
	mkdir $WORKSPACE/queues
fi


####	TO-DO: Find final band automatically	####
####						####



####	Create list of all extant bands, in hexadecimal order	####

for ((i=0; i<=$FINAL_BAND; i+=1)); do
	k=$(printf "%x\n" $i);
	if [ -e $k ]
	then
		echo $k >> $WORKSPACE/counted
	fi
done



####	Split list into lists with $files_per_archive lines each 	####
####	These will serve as "archive queues"	 			####

split -a 3 -l $files_per_archive $WORKSPACE/counted $WORKSPACE/queues/queue;



####	Pass each queue to tar for archiving	####
####	Archives are named "archive[1…2…3]"	####

suffix=1;
for queue in $WORKSPACE/queues/*; do
	tar -cvf archive$suffix  --files-from=$queue;
	let "suffix += 1"
done
