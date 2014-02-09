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

#LUNCHCMD[0]="m7vzw"			# lunch command used for ROM


#LUNCHCMD[1]="p3110"


#LUNCHCMD[2]="p3100"


#LUNCHCMD[3]="m7spr"


#LUNCHCMD[4]="m7att"


#LUNCHCMD[5]="p5110"


#LUNCHCMD[6]="p5100"


#LUNCHCMD[7]="lt01lte"


#LUNCHCMD[8]="edison"


#LUNCHCMD[9]="spyder"


LUNCHCMD[10]="lt013g"


LUNCHCMD[11]="lt01lte"


LUNCHCMD[12]="lt01wifi"


#---------------------Build Settings------------------#

# select "y" or "n"... Or fill in the blanks...



#use ccache

CCACHE=y

#what dir for ccache?

CCSTORAGE=~/.ccache

# should they be moved out of the output folder?
# like a dropbox or other cloud storage folder?
# or any other folder you want?
# also required for FTP upload!!

MOVE=y


# Please fill in below the folder they should be moved to. This is your OTA build folder...
# The "//" means root. if you are moving to an external HDD you should start with //media/your PC username/name of the storage device An example is below.
# If you are using an external storage device as seen in the example below, be sure to mount it via your file manager (open the drive in a file manager window) or thought the command prompt before you build, or the script will not find your drive.
# If the storage location is on the same drive as your build folder, use a "~/" to begin. It should look like this usually: ~/your storage folder... assuming your storage folder is in your "home" directory.
# This is manditory for OTG creation

STORAGE=~/mkkk/mokee/FULL/UNOFFICIAL

# What type of rom are you building (UNOFFICIAL, EXPERIMENTAL, OFFICIAL)? This will ususally be "UNOFFICIAL".

ROM=UNOFFICIAL

# Your build source code directory path. In the example below the build source code directory path is in the "home" folder. If your source code directory is on an external HDD it should look like: //media/your PC username/the name of your storage device/path/to/your/source/code/folder

SAUCE=~/mkkk

# REMOVE BUILD PROP (recomended for every build, otherwise the date of the build may not be changed, as well as other variables)

BP=y

# Number for the -j parameter (choose a smaller number for slower internet conection... default is usually 4... this only controls how many threads are running during repo sync)

J=16

# Sync repositories before build

SYNC=n

# run mka installclean first (quick clean build)
QCLEAN=y

# Run make clean first (Slow clean build. Will delete entire contents of out folder...)

CLEAN=n

# Make OTA Package
OTA=y

# leave alone
DATE=`eval date +%y``eval date +%m``eval date +%d`
TIMEST=$(date +%Y_%m_%d)
#----------------------FTP Settings--------------------#

# Copy to FTP Storage Folder? You do not have to upload, but you must chose this option if you chose FTP=y...

FTPSTR=y

# FTP Storage folders

# FTP upload ROM folder

FTPR=//media/daavvis/storage/uploadfolder/full

# FTP upload OTA folder

FTPOTA=//media/daavvis/storage/uploadfolder/ota

# Set "FTP=y" if you want to enable FTP uploading
# You must have moving to FTP storage folder enabled first

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

		if [ $FTPSTR = "y" ]; then
		echo ""
		echo "Copying ROM to FTP Storage Directory..."
		echo ""
			mkdir -p $FTPR/${LUNCHCMD[$VAL]}/$DATE
			cp $SAUCE/out/target/product/${LUNCHCMD[$VAL]}/*$ROM*".zip" $FTPR/${LUNCHCMD[$VAL]}/$DATE/
		fi
		echo ""
		echo "Done."
		echo ""
				
		if [ $FTPSTR = "y" ]; then
		echo ""
		echo "Moving MD5SUM to FTP Storage Directory"
		echo ""
			mkdir -p $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"
			mv $SAUCE/out/target/product/${LUNCHCMD[$VAL]}/*".md5sum" $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"/
		fi
		echo ""
		echo "Done."
		echo ""

cd $SAUCE
	
		if  [ $MOVE = "y" ]; then
			echo ""
			echo "Moving ROM to OTA build Dir..."
			echo ""
			mkdir -p $STORAGE/${LUNCHCMD[$VAL]}
			mv $SAUCE/out/target/product/${LUNCHCMD[$VAL]}/*$ROM*".zip" $STORAGE/${LUNCHCMD[$VAL]}/
		fi
		echo ""
		echo "Done."
		echo ""

		if [ $OTA = "y" ]; then
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
			echo "Moving OTA to FTP Storage Directory..."
			echo ""
			mkdir -p $FTPOTA/${LUNCHCMD[$VAL]}/$DATE
			mv $SAUCE/mokee/OTA/UNOFFICIAL/${LUNCHCMD[$VAL]}/"OTA"*".zip" $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/
		fi
		echo ""
		echo "Done."
		echo ""

		if [ $FTPSTR = "y" ]; then
			echo ""
			echo -n "Moving OTA md5 to FTP Storage Directory..."
			echo ""
			mkdir -p $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"
			mv $SAUCE/mokee/OTA/UNOFFICIAL/${LUNCHCMD[$VAL]}/"md5"/*".md5sum" $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"/
		fi
		echo ""
		echo "Done."
		echo ""

#------------------------------------------------------------FTP UPLOAD START----------------
				if  [ $FTP = "y" ]; then
				echo ""
				echo ""
				echo ""
				echo "Uploading ROM..."
				echo ""
				echo ""
				echo ""
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."
				
				echo ""
				echo ""
				echo ""
				echo "Uploading ROM md5..."
				echo ""
				echo ""
				echo ""
					curl -v -T $FTPR/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"FULL"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."

				echo ""
				echo ""
				echo ""
				echo "Uploading OTA..."
				echo ""
				echo ""
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/*".zip" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/
				echo "Done."

				echo ""
				echo ""
				echo ""
				echo "Uploading OTA md5..."
				echo ""
				echo ""
				echo ""
					curl -v -T $FTPOTA/${LUNCHCMD[$VAL]}/$DATE/"md5"/*".md5sum" ftp://$FTPUSER:$FTPPASS@$FTPHOST/"OTA"/"UNOFFICIAL"/${LUNCHCMD[$VAL]}/"md5"/
				echo "Done."
					
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
