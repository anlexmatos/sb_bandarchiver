# sb_bandarchiver
Sparse Bundle Band Archiver - Bash shell script to group band files into archives of configurable size

This script is designed to facilitate uploading a Sparse Bundle disk image to Google Drive (or any browser-based interface for cloud storage) from an external drive, when the boot partition is too small to cache the entire image while uploading.

Sparse Bundles are made up of 8MiB segments called bands. Each band is numbered in hexadecimal. The script will group these bands into archives of configurable size (default: 10 GiB) in order to make drag-and-drop uploading of cacheable segments feasible. The archives are placed in the grandparent directory (i.e. outside of the sparse bundle).

Currently all options are hardcoded and no command line arguments are read.

To use:  
First edit $ARCHIVE_SIZE to match your preference. Value must be in GiB.  
Edit $FINAL_BAND to match the last band in the sparse bundle (in hexadecimal order, NOT the sort order shown by the Finder, or the other sort order shown by ls…)  
Change your working directory to the "band" directory inside the .sparsebundle package.  
Then run the group_bands shell script. Archives will be placed outside the sparse bundle.

Ex:  
    $   cd /path/to/image.sparsebundle/bands  
    $   /path/to/group_bands.sh
