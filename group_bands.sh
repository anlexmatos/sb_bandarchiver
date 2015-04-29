#!/bin/bash

########		BEGIN INITIALIZATION		   ########
						
####	Initialize Variables	####
				
WORKSPACE=$(echo ~/.sb_bandarchiver)				# Set workspace directory.
ARCHIVE_SIZE=10							# Archive size in GiB.
files_per_archive=$(expr $(expr $ARCHIVE_SIZE \* 1024) / 8)	# Rough calculation assumes all
								# files are 8MB; a handful aren't.

####	Initialize Workspace	####

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
					



####	List of All Bands in Hexadecimal Order    ####

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



####	Split List into Lists, with $files_per_archive Lines Each 	####

echo "… Creating archive queues …";						# File names:
split -a 3 -l $files_per_archive $WORKSPACE/counted $WORKSPACE/queues/queue;	#   queue[aaa…zzz]
echo "$(ls $WORKSPACE/queues | wc -l) queue files created.";			# in workspace dir



####	Pass Queues to Tar for Archiving	####
##	TO-DO: user provided output directory	  ##
##	TO-DO: halt if "queue-only mode"	  ##

suffix=1;
for queue in $WORKSPACE/queues/*; do
	echo "… Creating archive #$suffix …";			# File names: archive[1…2…3…]
	tar -cvf ../../archive$suffix  --files-from=$queue;	# Placed outside sparse bundle
	let "suffix += 1"
done
