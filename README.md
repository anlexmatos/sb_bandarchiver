# sb_bandarchiver
Sparse Bundle Band Archiver - Group band files into archives of configurable size

I created this in order to upload a large (>100gb) sparse bundle disk image to Google Drive from an external hard drive while dealing with minimal free space on the boot drive. Archiving the 8MB bands into ~10gb chunks allows simple partial uploads to Google Drive that do not attempt to devour your drive space with an enormous upload cache…

Currently all options are hardcoded and no command line arguments are read.

To use:  
First edit $ARCHIVE_SIZE to match your preference. Value must be in GiB.  
Edit $FINAL_BAND to match the last band in yoru sparse bundle (in hexadecimal order, NOT the sort order shown by the Finder, or the other sort order shown by ls…)  
Change your working directory to the "band" folder inside a .sparsebundle package.  
Then run the group_bands shell script. Archives will be placed outside the sparse bundle.

Ex:  
    $   cd /path/to/image.sparsebundle/bands  
    $   ~/group_bands.sh
