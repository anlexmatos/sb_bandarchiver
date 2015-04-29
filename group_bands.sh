#!/bin/bash

# This script is designed to facilitate uploading a Sparse Bundle disk image to Google Drive (or any
# browser-based interface for cloud storage) from an external drive, when the boot partition is too
# small to cache the entire image while uploading.
# 
# Sparse Bundles are made up of 8MiB segments called bands. Each band is numbered in hexadecimal. The
# script will group these bands into archives of configurable size (default: 10 GiB) in order to make
# drag-and-drop uploading of cacheable segments feasible. The archives are placed in the grandparent
# directory (i.e. outside of the sparse bundle).


											
####	  0a. Initialize Variables	####    

##	 TO-DO: Read arguments for user's specified: 	       ##
##	 	    Band directory (currently PWD)	       ##
##	 	    Archive size			       ##
##		    Final band (optional)		       ##
##	 TO-DO: Find final band automatically (optional)       ##		 
          					   	        	        	
WORKSPACE=$(echo ~/.sb_bandarchiver)				  # Set workspace directory.

ARCHIVE_SIZE=10							  # Archive size in GiB.
files_per_archive=$(expr $(expr $ARCHIVE_SIZE \* 1024) / 8)	  # Rough calculation assumes all
							  	  # files are 8MiB; a handful aren't.

FINAL_BAND=0x9ff	# Though this value is specified here in hex (e.g. filename 9ff as "0x9ff"),
			# bash will convert this to decimal (e.g. 2560) before storing.



####	  0b. Initialize Workspace	####

if [ -e $WORKSPACE ]						
   then rm $WORKSPACE/counted; rm $WORKSPACE/queues/*; fi	   # Wipe workspace dir if it exists.

if [ ! -e $WORKSPACE ]						
   then	mkdir $WORKSPACE; mkdir $WORKSPACE/queues;		   # Otherwise, create it.
	echo 'Created workspace at ~/.sb_bandarchiver/'; fi



####	  1. List All Bands in Hexadecimal Order      ####

found_count=0
for ((i=0; i<=$FINAL_BAND; i+=1)); do		    # Counting up to (name of last band, as a decimal)

	k=$(printf "%x\n" $i);			    # "Print i into k" in hexadecimal form.
						    # Essentially: Decimal Integer -> Hex String.
						    # This is necessary because bash always stores
						    # and operates on numbers in decimal, even when 
						    # they are originally specified in hexadecimal,

	if [ -e $k ]				    # Check if the hex in k corresponds to a band.
	then
		echo $k >> $WORKSPACE/counted;	    # If so, add to the file list: 'counted'.
		let "found_count += 1";		    # "That's One, One Band, Ah Ah Ah…!"	
	fi
done

echo "$found_count bands found in total."



#### 	  2. Split List Into Queues with $files_per_archive Lines (Files)  Each	     ####

echo "… Creating archive queues …"						# Files in workspace:
split -a 3 -l $files_per_archive $WORKSPACE/counted $WORKSPACE/queues/queue_	#     queue_[aaa…zzz]
echo "$(ls $WORKSPACE/queues | wc -l) queue files created."			



####	  3. Pass Queues to Tar for Archiving	   ####

##	TO-DO: Check arguments for "queue-only mode". If so:	   			      ##
##	       - Copy queue files to user-specified directory	   			      ##
##	       - Halt script, do not run tar			   			      ##
##	TO-DO: !! Allow user-specified archive location.				      ##
##		  - Important; image's parent drive might have insufficient free space	      ##

suffix=1
for queue in $WORKSPACE/queues/*; do
	echo "… Creating archive_$suffix …";			    # File names: archive_[1…2…3…]
	tar -cvf ../../archive_$suffix  --files-from=$queue;	    # placed outside sparse bundle.
	let "suffix += 1"
done
