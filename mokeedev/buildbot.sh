#!/bin/bash

# BuildBot script for MoKee Unofficial Developer builds
# Severely modified by:
# daavvis
# Find me on XDA Developers
# Originally written by:
# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# So long as you keep our names and URL in it.
# Lots of thanks go out to TeamBAMF

#-------------------ROMS To Be Built------------------#
# Instructions and examples below:
# Add lines for devices and uncoment as needed for building multiple/single
# devices follow examples below

LUNCHCMD[0]="m7vzw"			# lunch command used for ROM


LUNCHCMD[1]="p3110"


#LUNCHCMD[2]="p3100"


#LUNCHCMD[3]="m7spr"


#---------------------Build Settings------------------#

# select "y" or "n"... Or fill in the blanks...

# Your build source code directory path. In the example below the build source code directory path is in the "home" folder. If your source code directory is on an external HDD it should look like: //media/your PC username/the name of your storage device/path/to/your/source/code/folder

SAUCE=~/mkkk

# Should the finished ROMS be moved out of the output folder?
# For instance External storage, dropbox, or other cloud storage folder?

MOVE=y

# Please fill in below the folder they should be moved to.
# The "//" means root. if you are moving to an external HDD you should start with //media/your PC username/name of the storage device An example is below.
# If you are using an external storage device as seen in the example below, be sure to mount it via your file manager (open the drive in a file manager window) or thought the command prompt before you build, or the script will not find your drive.
# If the storage location is on the same drive as your build folder, use a "~/" to begin. It should look like this usually: ~/your storage folder... assuming your storage folder is in your "home" directory.

STORAGE=//media/daavvis/storage/1foronlyme/4.4.2

# Sync repositories before build

SYNC=n

# Number for the -j parameter (choose a smaller number for slower internet conection... default is usually 4... this only controls how many threads are running during repo sync)

J=16

# Do you Want to use ccache?

CCACHE=y

# What folder would you like to use for ccache? Typicaly ~/.ccache

CCSTORAGE=~/.ccache

# REMOVE BUILD PROP (recomended for every build, otherwise the date of the build may not be changed, as well as other variables)

BP=y

# run mka installclean first (quick clean build)
QCLEAN=y

# Run make clean first (Slow clean build. Will delete entire contents of out folder...)

CLEAN=n

# Do you want to make an ota Package?
OTA=y

# leave alone
OTABDIR=$SAUCE/mokee/FULL/UNOFFICIAL/${LUNCHCMD[$VAL]}
ROM=UNOFFICIAL
DATE=`eval date +%y``eval date +%m``eval date +%d`
TIMEST=$(date +%Y_%m_%d)
#----------------------FTP Settings--------------------#

# Copy to FTP Storage Folder?

FTPSTR=y

# FTP Storage folders

# FTP upload ROM folder

FTPR=//media/daavvis/storage/uploadfolder/full

# FTP upload OTA folder

FTPOTA=//media/daavvis/storage/uploadfolder/ota

# Set "FTP=y" if you want to enable FTP uploading

FTP=y

# FTP server settings...

FTPHOST=mokeedev.com				# ftp hostname (should not change)
FTPUSER=mokeedev user name			# ftp username 
FTPPASS=mokeedev password			# ftp password

#---------------------Build Bot Code-------------------#
# Very much not a good idea to change this unless you know what you are doing....
# get time of startup
res1=$(date +%s.%N)

echo ""
echo "Moving to source directory..."
cd $SAUCE
echo ""
echo ""
echo "done!"
echo ""
echo ""



		if [ $SYNC = "y" ]; then
			echo ""
			echo "Running repo sync..."
			echo ""
			repo sync -j$J
			echo ""
			echo "done!"
			echo ""
		fi

		if [ $CLEAN = "y" ]; then
			echo ""
			echo "Running make clean..."
			echo ""
			make clean
			echo ""
			echo "done!"
			echo ""
		fi

		if [ $CCACHE = "y" ]; then
			echo ""
			echo "using CCACHE..."
			echo ""
			export USE_CCACHE=1
			export CCACHE_DIR=$CCSTORAGE
		fi



for VAL in "${!LUNCHCMD[@]}"
do

echo ""
echo ""
echo ""
echo "Starting build..."
echo ""
echo ""
echo ""
. build/envsetup.sh
croot
lunch mk_${LUNCHCMD[$VAL]}-userdebug



		if [ $BP = "y" ]; then
		echo ""
		echo "Removing build.prop..."
		echo ""
		rm $SAUCE/out/target/product/${LUNCHCMD[$VAL]}/system/build.prop
		echo ""
		echo "done!"
		echo ""
		fi

		
		
		if [ $QCLEAN = "y" ]; then
		echo ""
		echo "Running make install clean..."
		echo ""
		mka installclean
		echo ""
		echo "done!"
		echo ""
		fi

# start compilation
mka bacon
echo ""
echo ""
echo ""
echo "done!"
echo ""
echo ""
echo ""

cd $SAUCE
	
		if  [ $OTA = "y" ]; then
			echo ""
			echo "Copying ROM to OTA build Dir..."
			echo ""
			mkdir -p $OTABDIR
			cp $SAUCE/out/target/product/${LUNCHCMD[$VAL]}/*$ROM*".zip" $OTABDIR/
			echo ""
			echo "Done."
			echo ""
			echo "Creating OTA.zip"
			echo ""
				cd $SAUCE
				. build/envsetup.sh
				export MK_OTA_INPUT=$SAUCE/mokee/FULL
				export MK_OTA_EXTRA=$SAUCE/mokee/OTA
					ota_all UNOFFICIAL ${LUNCHCMD[$VAL]}
			echo ""
			echo "Done."
			echo ""
			echo "cleaning up for next time"
			echo ""
			echo ""
				FILECOUNT=`ls | wc -l`;
				if [ $FILECOUNT > 2 ]
				then
    				cd $STORAGE/${LUNCHCMD[$VAL]} && rm -f $(ls -tr | head -n 1)
			echo ""
    			echo "Removed oldest Rom, Ready For Next Build..."
			echo ""
        			fi
			echo ""
			echo "Done."
			echo ""
		fi

	if [ $FTPSTR = "y" ]; then
		echo ""
		echo "Copying ROM to FTP Storage Directory..."
			mkdir -p $FTPR/${LUNCHCMD[$VAL]}/$DATE
			cp $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*$ROM*".zip" $FTPR/${LUNCHCMD[$VAL]}/$DATE/
		echo ""
		echo "Done."
		echo ""
		echo "Copying MD5SUM to FTP Storage Directory"
		echo ""
			mkdir -p $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"
			cp $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*".md5sum" $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"/
		echo "Done."
		echo ""
		echo "Copying OTA to FTP Storage Directory..."
		echo ""
			mkdir -p $FTPOTA/${LUNCHCMD[$VAL]}/$DATE
			cp $SAUCE"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"OTA"*".zip" $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/
		echo "Done."
		echo ""
		echo -n "Moving OTA md5 to FTP Storage Directory..."
		echo ""
			mkdir -p $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"
			cp $SAUCE/"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/*".md5sum" $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"/
	fi
		echo "Done."
		echo ""

	if [ $MOVE = "y" ]; then
		echo ""
		echo "Moving ROM to Storage Directory..."
			mkdir -p $STORAGE/${LUNCHCMD[$VAL]}/
			mv $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*$ROM*".zip" $STORAGE/${LUNCHCMD[$VAL]}/
		echo ""
		echo "Done."
		echo ""
		echo "Moving MD5SUM to Storage Directory"
		echo ""
			mkdir -p $STORAGE/${LUNCHCMD[$VAL]}/"md5"
			mv $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*".md5sum" $STORAGE/${LUNCHCMD[$VAL]}/"md5"/
		echo "Done."
		echo ""
		echo "Moving OTA Storage Directory..."
		echo ""
			mkdir -p $STORAGE/${LUNCHCMD[$VAL]}/"OTA"
			mv $SAUCE/"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/${LUNCHCMD[$VAL]}/"OTA"*".zip" $STORAGE/${LUNCHCMD[$VAL]}/"OTA"/
		echo "Done."
		echo ""
		echo "Moving OTA md5 to FTP Storage Directory..."
		echo ""
			mkdir -p $STORAGE/${LUNCHCMD[$VAL]}/"OTA"/"md5"
			mv $SAUCE/"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/${LUNCHCMD[$VAL]}/"md5"/*".md5sum" $STORAGE/${LUNCHCMD[$VAL]}/"OTA"/"md5"/
		echo ""
		echo "Cleaning up..."
			rm -rf /"out"/"target"/"OTA"
		echo ""
	fi
		echo "Done."
		echo ""

#------------------------------------------------------------FTP UPLOAD START----------------
	if  [ $FTP = "y" ]; then
		echo ""
		echo "Uploading ROM..."
				echo ""
		if [ $FTPSTR = "y" ] && [ $MOVE = "y" ]; then 
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				
				echo ""
				echo "Uploading ROM md5..."
				echo ""
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
				echo ""
				echo "Uploading OTA..."
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				echo "Uploading OTA md5..."
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."

		elif [ $FTPSTR ="y" ] && [ $MOVE = "n" ]; then 
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				
				echo ""
				echo "Uploading ROM md5..."
				echo ""
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
				echo ""
				echo "Uploading OTA..."
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				echo "Uploading OTA md5..."
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."

		elif [ $MOVE = "y" ] && [ $FTPSTR ="n" ]; then
					curl -v -T $STORAGE/${LUNCHCMD[$VAL]}/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				
				echo ""
				echo "Uploading ROM md5..."
				echo ""
					curl -v -T $STORAGE/${LUNCHCMD[$VAL]}/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
				echo ""
				echo "Uploading OTA..."
				echo ""
					curl -v -T $STORAGE/${LUNCHCMD[$VAL]}/"OTA"/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				echo "Uploading OTA md5..."
				echo ""
					curl -v -T curl -v -T $STORAGE/${LUNCHCMD[$VAL]}/"OTA"/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
		else
					curl -v -T $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				
				echo ""
				echo "Uploading ROM md5..."
				echo ""
					curl -v -T $SAUCE/"out"/"target"/"product"/${LUNCHCMD[$VAL]}/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
				echo ""
				echo "Uploading OTA..."
				echo ""
					curl -v -T $SAUCE/"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				echo "Uploading OTA md5..."
				echo ""
					curl -v -T $SAUCE/"mokee"/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
		fi

	fi
cd $SAUCE
	echo ""
	echo ""
	echo "Cleaning up..."
		rm -rf /"out"/"target"/"OTA"
	echo ""
	echo ""
	echo ""
	echo "ALL DONE..."
	echo ""
	echo ""
	echo ""
# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
done
