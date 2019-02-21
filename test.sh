#!/bin/bash
#####################################
#       Created by: zacharyd3       #
#####################################
#   The echo lines can be disabled  #
#   they're mainly for debugging    # 
#     if movies aren't copied.      #
#####################################
#  For this script to work ensure   #
#      your movies are named:       #
#  Alladin [ 1993 WEBDL-1080p 5.1]  #
#####################################

#Start counting the renaming passes made
echo ""
passNumber=1

#Set radarr recycle bin location
bin=/c/Users/Zach/Downloads/Recycle/
cd $bin

for file in $bin*
do
	echo "Pass: "$passNumber
	#Search for 1080p movies in the recycle bin
	if [[ $file == *"1080p"* ]] || [[ $file == *"720p"* ]]
	then
		foundLocation=$file
		echo "Low-res Movie Location: "$foundLocation
		
		#Parse movie name from filenames found
		parseNameOld0=$(echo "$file" | cut -d'/' -f7)
		parseNameOld1=$(echo "$parseNameOld0" | cut -d'[' -f1)
		echo "Low-res Movie name: "$parseNameOld1
		
		#Turn the parsed movie name into a folder
		movieFolder1=/c/Users/Zach/Downloads/$parseNameOld1
		movieFolder2=${movieFolder1::-1}
		movieFolder3="${movieFolder2}/"
		echo "4K Movie folder: "$movieFolder3
		
		#Test if the movie folder exists
		if [ -d "${movieFolder3}" ]
		then
			cd "${movieFolder3}"
			#Search the folder for 4K movies
			foundNew=$(find . -maxdepth 1 -name "*2160p*")
			echo "Found 4K Movie: "$foundNew
			
			#Parse movie name from 4K filenames found
			parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
			parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
			echo "4K Movie name: "$parseNameNew1
			
			if [ "${parseNameOld1}" == "${parseNameNew1}" ]
			then
				echo "Movies matched!"
				let passNumber++
				mv "${foundLocation}" "${movieFolder3}"
			fi
			echo ""
		fi	
	fi
done