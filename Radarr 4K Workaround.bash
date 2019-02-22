#!/bin/bash
#####################################
#                                   #
#       Created by: zacharyd3       #
#                                   #
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
bin=/mnt/user/Downloads/.Recycle.Bin/
cd $bin

#Set the Movie library location
movieFolderRoot=/mnt/user/Videos/Movies/

#Run the next commands on each file in the recycle bin
for file in $bin*
do

#Search for 1080p or 720p movies in the recycle bin
	if [[ $file == *"1080p"* ]] || [[ $file == *"720p"* ]]
	then
		foundLocation=$file
		#echo "Low-res Movie Location: "$foundLocation
		
#Parse movie name from filenames found ( Change the number after "F" to how many directories there are before the recycle bin and add 2. )
		parseNameOld0=$(echo "$file" | cut -d'/' -f6) #<<Change this number
		parseNameOld1=$(echo "$parseNameOld0" | cut -d'[' -f1)
		parseNameOld2=${parseNameOld1::-1}
		#echo "Low-res Movie name: "$parseNameOld2

#Parse file extension
		parseExt=$(echo "$file" | cut -d'.' -f5)
		
#Turn the parsed movie name into a folder
		movieFolder0=$movieFolderRoot$parseNameOld2
		movieFolder1="${movieFolder0}/"
		#echo "4K Movie folder: "$movieFolder1
		
#Test if the movie folder exists
		if [ -d "${movieFolder1}" ]
		then
			cd "${movieFolder1}"

#Search the folder for 4K movies
			foundNew=$(find . -maxdepth 1 -name "*2160p*" -size +3072M)
			#echo "Found 4K Movie: "$foundNew
			
#Parse movie name from 4K filenames found
			parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
			parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
			parseNameNew2=${parseNameNew1::-1}
			#echo "4K Movie name: "$parseNameNew2
			#echo "['{"$parseNameOld2"}' == '{"$parseNameNew2"}' ]"
			
			if [ "${parseNameOld2}" == "${parseNameNew2}" ]
			then
				echo "Pass: "$passNumber
				echo $parseNameNew2" "$parseExt" moved."
				let passNumber++
				mv "${foundLocation}" "${movieFolder1}"
				/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$parseNameNew2 $parseExt has been copied back." -i "warning"
				echo ""
			fi
		fi	
	fi
done
