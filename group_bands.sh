#!/bin/bash

########		BEGIN INITIALIZATION		   ########
						
####	Initialize variables	####
				
WORKSPACE=$(echo ~/.sb_bandarchiver)				# Set workspace directory
ARCHIVE_SIZE=10							# Archive size in GiB
files_per_archive=$(expr $(expr $ARCHIVE_SIZE \* 1024) / 8)	# Calculate archive filecount

####	Initialize workspace	####

if [ -e $WORKSPACE ]						
   then rm $WORKSPACE/counted; rm $WORKSPACE/queues/*; fi	# Wipe workspace dir if it exists

if [ ! -e $WORKSPACE ]						
   then	mkdir $WORKSPACE; mkdir $WORKSPACE/queues;		# Otherwise, create it
	echo 'Created workspace at ~/.sb_bandarchiver/';
fi 

###	TO-DO: User specified band directory (currently the present working directory)	 ###
###	TO-DO: Find final band automatically	 					 ###

FINAL_BAND=0x9ff;

########		END INITIALIZATION		 ########
					



####	Create list of all existent bands, in hexadecimal order    ####

found_count=0;
for ((i=0; i<=$FINAL_BAND; i+=1)); do		# Counting up to (name of last band), a hex number

	k=$(printf "%x\n" $i);			# "Print i into k" in hexadecimal form.
						# Essentially: Decimal Integer -> Hex String
						# This is necessary because bash always stores
						# and operates on numbers in decimal, even when 
						# they are specified in hexadecimal,

	if [ -e $k ]				# Check if the hex in k corresponds to a band
	then
		echo $k >> $WORKSPACE/counted	# If so, add to the file list: 'counted'
		let "found_count += 1";
	fi
done

echo "$found_count bands found in total.";



####	Split the list into lists with $files_per_archive lines each 	####
####	These will serve as "archive queues"	 			####
####	Files are named queue[aaa…zzz]					####

echo "… Creating archive queues …";
split -a 3 -l $files_per_archive $WORKSPACE/counted $WORKSPACE/queues/queue;
echo "$(ls $WORKSPACE/queues | wc -l) queue files created.";



####	Pass each queue to tar for archiving	####
####	Archives are named "archive[1…2…3]"	####
####	Archives are placed outside disk image	####
##	TO-DO: user provided output directory	  ##
##	TO-DO: halt if "queue-only mode"	  ##

suffix=1;
for queue in $WORKSPACE/queues/*; do
	echo "… Creating archive #$suffix …";
	tar -cvf ../../archive$suffix  --files-from=$queue;
	let "suffix += 1"
done
