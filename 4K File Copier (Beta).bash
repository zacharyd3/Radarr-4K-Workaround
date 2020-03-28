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

#Start Debugging (set as 1 to enable)
debug=0

#Start counting the renaming passes made
passNumber=1
passNumberTV=1
#Set radarr recycle bin location
binMovie=/mnt/user/Downloads/.Recycle.Bin/Movies/
binTV=/mnt/user/Downloads/.Recycle.Bin/TV/
cd $bin

#Set the library locations
movieFolderRoot=/mnt/user/Videos/Movies/
tvFolderRoot=/mnt/user/Videos/TV/

echo "<hr>"
echo "<font color='blue'><b>Starting Low-res Movie Copier</b></font>"
echo ""
echo "<hr>"

#Run the next commands on each file in the recycle bin
for file in $binMovie*
do


#Search for 1080p or 720p movies in the recycle bin
	if [[ $file == *"1080p"* ]] || [[ $file == *"720p"* ]]
	then
		foundLocation=$file
		if [ $debug -eq "1" ]
		then
			echo "Low-res Movie Location: "$foundLocation
		fi
		
#Parse movie name from filenames found ( Change the number after "F" to how many directories there are before the recycle bin and add 2. )
		parseNameOld0=$(echo "$file" | cut -d'/' -f7) #<<Change this number
		parseNameOld1=$(echo "$parseNameOld0" | cut -d'[' -f1)
		parseNameOld2=${parseNameOld1::-1}
		if [ $debug -eq "1" ]
		then
			echo "Low-res Movie name: "$parseNameOld2
		fi
		
#Parse file extension
		parseExt=$(echo "$file" | cut -d'.' -f5)
		
#Turn the parsed movie name into a folder
		movieFolder0=$movieFolderRoot$parseNameOld2
		movieFolder1="${movieFolder0}/"
		if [ $debug -eq "1" ]
		then
			echo "4K Movie folder: "$movieFolder1
		fi

#Test if the movie folder exists
		if [ -d "${movieFolder1}" ]
		then
			cd "${movieFolder1}"

#Search the folder for 4K movies
			foundNew=$(find . -maxdepth 1 -name "*2160p*" -size +1536M)
			if [[ "$foundNew" != "" ]]
			then
				if [ $debug -eq "1" ]
				then
					echo "<font color='blue'><b>Found 4K Movie: "$foundNew"</b></font>"
				fi
			fi

#Parse movie name only if 4K filename found
			if [[ "$foundNew" == *"2160p"* ]]
			then
				parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
				parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
				parseNameNew2=${parseNameNew1::-1}
				if [ $debug -eq "1" ]
				then
					echo "4K Movie name: "$parseNameNew2
				fi

				if [ "${parseNameOld2}" == "${parseNameNew2}" ]
				then
					if [ "${parseExt}" != "nfo" ]
					then
						echo "Pass: "$passNumber
						echo "<font color='blue'><b>"$parseNameNew2" "$parseExt" moved.</b></font>"
						let passNumber++
						mv "${foundLocation}" "${movieFolder1}"
						/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$parseNameNew2 $parseExt has been copied back." -i "normal"
						echo ""
					fi
				fi
			fi
		fi	
	if [ $debug -eq "1" ]
	then
		echo ""
	fi
fi
done



#####################################
#                                   #
#          TV Show Sorter           #
#                                   #
#####################################
#Start Debugging (set as 1 to enable)
debug=0
inUse=0

echo "<hr>"
echo "<font color='red'><b>Starting Low-res TV Show Copier</b></font>"	
echo ""
echo "<hr>"

for file in $binTV*
do
#Start checking TV shows too
	if [ -d "${file}" ]
	then
		directory=$file/
			for tvSeason in "${directory}"*/*
			do
				if [ -f "${tvSeason}" ]
				then
			
#Output the original file
					if [ $debug -eq "1" ]
					then
						echo "Original file:"$tvSeason
						if [{ $tvSeason != *"1080p"* ]}
						then
							echo "<font color='red'><b>The file is not 1080p, skipping.</b></font>"
							break
						fi
						if lsof "$tvSeason" > /dev/null; then
							echo "<font color='red'><b>File is in use, skipping.</b></font>"
							break
							inUse=1
						else
							inUse=0
						fi
					fi

#Parse the show name
					tvShowName=$(echo "$tvSeason" | cut -d'/' -f7)
					if [ $debug -eq "1" ]
					then
						echo "Show name:"$tvShowName
					fi

#Parse the show season
					tvShowSeason=$(echo "$tvSeason" | cut -d'/' -f8)	
					if [ $debug -eq "1" ]
					then
						echo "Show season:"$tvShowSeason
					fi

#Parse the episode
					tvShowEpisode0=$(echo "$tvSeason" | cut -d'/' -f9)
					tvShowEpisode1=$(echo "$tvShowEpisode0" | cut -d'-' -f1)
					if [ $debug -eq "1" ]
					then
						echo "Show episode:"$tvShowEpisode1
					fi

#Parse the folder
					tvShowOriginal=$tvFolderRoot$tvShowName/$tvShowSeason/
					if [ $debug -eq "1" ]
					then
						echo "Show folder:"$tvShowOriginal
					fi
		
#Parse the file extension
					tvShowExtension=$(echo "$tvSeason" | cut -d'.' -f5)	
					if [ $debug -eq "1" ]
					then
						echo "Show extension:"$tvShowExtension
					fi
				
#Check to see if the file matches a show
					if [[ -d $tvShowOriginal ]]
					then
						if [ $debug -eq "1" ]
						then
							echo "Show folder found!"
						fi
					
#Scan the files in the show folder for a matching 4K file
						for original in "${tvShowOriginal}"*
						do 	
							if [[ $original == *$tvShowEpisode1*"2160p"*$tvShowExtension ]] || [[ $original == *$tvShowEpisode1*"2160p"*".mp4" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".avi" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".mkv" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".jpg" ]]
							then
								if [ $debug -eq "1" ]
								then						
									echo "4K file:"$original
								fi
#Copy the matching file back
								if [ -f "${tvSeason}" ]
								then
									if [ $inUse -eq "0" ]
									then
										echo "Pass: "$passNumber
										echo "<font color='blue'><b>"$tvShowName" "$tvShowEpisode1" "$tvShowExtension" moved.</b></font>"
										mv "${tvSeason}" "${tvShowOriginal}"
										let passNumber++
										let passNumberTV++
										/usr/local/emhttp/webGui/scripts/notify -e "4K Copier" -s "Copy Notifcation" -d "$tvShowName $tvShowEpisode1 $tvShowExtension has been copied back." -i "normal"
										if [ $debug -eq "0" ]
										then
											echo ""
										fi
									fi
								fi
							fi
						done
					fi
				if [ $debug -eq "1" ]
				then
					echo ""
				fi
				fi
			done
		fi
	done		
	
	
#####################################
#                                   #
#         Backwards Movie Sorter    #
#                                   #
#####################################
#Start Debugging (set as 1 to enable)
debug=0

echo "<hr>"
echo "<font color='blue'><b>Starting 4K Movie Copier</b></font>"	
echo ""
echo "<hr>"


#Run the next commands on each file in the recycle bin
for file in $binMovie*
do

#Search for 4K movies in the recycle bin
	if [[ $file == *"2160p"* ]]
	then
		foundLocation=$file
		if [ $debug -eq "1" ]
		then
			echo "4K Movie Location: "$foundLocation
		fi
				
#Parse movie name from filenames found ( Change the number after "F" to how many directories there are before the recycle bin and add 2. )
		parseNameOld0=$(echo "$file" | cut -d'/' -f7) #<<Change this number
		parseNameOld1=$(echo "$parseNameOld0" | cut -d'[' -f1)
		parseNameOld2=${parseNameOld1::-1}
		if [ $debug -eq "1" ]
		then
			echo "4K Movie name: "$parseNameOld2
		fi
		
#Parse file extension
		parseExt=$(echo "$file" | cut -d'.' -f5)
		
#Turn the parsed movie name into a folder
		movieFolder0=$movieFolderRoot$parseNameOld2
		movieFolder1="${movieFolder0}/"
		if [ $debug -eq "1" ]
		then
			echo "4K Movie folder: "$movieFolder1
		fi

#Test if the movie folder exists
		if [ -d "${movieFolder1}" ]
		then
			cd "${movieFolder1}"

#Search the folder for Low-res movies
			foundNew=$(find . -maxdepth 1 -name "*1080p*" || "*720p*" -size +1536M)
			if [[ "$foundNew" != "" ]]
			then
				if [ $debug -eq "1" ]
				then
					echo "<font color='blue'><b>Found Low-res Movie: "$foundNew"</b></font>"
				fi
			fi

#Parse movie name only if Low-res filename found
			if [[ "$foundNew" == *"1080p"* || "*720p*" ]]
			then
				parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
				parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
				parseNameNew2=${parseNameNew1::-1}
				if [ $debug -eq "1" ]
				then
					echo "Low-res Movie name: "$parseNameNew2
				fi

				if [ "${parseNameOld2}" == "${parseNameNew2}" ]
				then
					if [ "${parseExt}" != "nfo" ]
					then
						echo "Pass: "$passNumber
						echo "<font color='blue'><b>"$parseNameNew2" "$parseExt" moved.</b></font>"
						let passNumber++
						mv "${foundLocation}" "${movieFolder1}"
						/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$parseNameNew2 $parseExt has been copied back." -i "normal"
						echo ""
					fi
				fi
			fi
		fi	
	if [ $debug -eq "1" ]
	then
		echo ""
	fi
fi
done
		
		
#####################################
#                                   #
#          Backwards TV Show Sorter #
#                                   #
#####################################
#Start Debugging (set as 1 to enable)
debug=0

echo "<hr>"
echo "<font color='red'><b>Starting 4K TV Show Copier</b></font>"	
echo ""
echo "<hr>"

for file in $binTV*
do
#Start checking TV shows too
	if [ -d "${file}" ]
	then
		directory=$file/
			for tvSeason in "${directory}"*/*
			do
				if [ -f "${tvSeason}" ]
				then
			
#Output the original file
					if [ $debug -eq "1" ]
					then
						echo "Original file:"$tvSeason
						if [[ $tvSeason != *"2160p"* ]]
						then
							echo "<font color='red'><b>The file is not 2160p, skipping.</b></font>"
							break
						fi
						if lsof "$tvSeason" > /dev/null; then
							echo "<font color='red'><b>File is in use, skipping.</b></font>"
							inUse=1
							break
						else
							inUse=0
						fi
					fi

#Parse the show name
					tvShowName=$(echo "$tvSeason" | cut -d'/' -f7)
					if [ $debug -eq "1" ]
					then
						echo "Show name:"$tvShowName
					fi

#Parse the show season
					tvShowSeason=$(echo "$tvSeason" | cut -d'/' -f8)	
					if [ $debug -eq "1" ]
					then
						echo "Show season:"$tvShowSeason
					fi

#Parse the episode
					tvShowEpisode0=$(echo "$tvSeason" | cut -d'/' -f9)
					tvShowEpisode1=$(echo "$tvShowEpisode0" | cut -d'-' -f1)
					if [ $debug -eq "1" ]
					then
						echo "Show episode:"$tvShowEpisode1
					fi

#Parse the folder
					tvShowOriginal=$tvFolderRoot$tvShowName/$tvShowSeason/
					if [ $debug -eq "1" ]
					then
						echo "Show folder:"$tvShowOriginal
					fi
		
#Parse the file extension
					tvShowExtension=$(echo "$tvSeason" | cut -d'.' -f5)	
					if [ $debug -eq "1" ]
					then
						echo "Show extension:"$tvShowExtension
					fi
				
#Check to see if the file matches a show
					if [[ -d $tvShowOriginal ]]
					then
						if [ $debug -eq "1" ]
						then
							echo "Show folder found!"
						fi
					
#Scan the files in the show folder for a matching Low-res file
						for original in "${tvShowOriginal}"*
						do 	
							if [[ $original == *$tvShowEpisode1*"1080p"*$tvShowExtension ]] || [[ $original == *$tvShowEpisode1*"1080p"*".mp4" ]] || [[ $original == *$tvShowEpisode1*"1080p"*".avi" ]] || [[ $original == *$tvShowEpisode1*"1080p"*".mkv" ]] || [[ $original == *$tvShowEpisode1*"1080p"*".jpg" ]] || [[ $original == *$tvShowEpisode1*"720p"*$tvShowExtension ]] || [[ $original == *$tvShowEpisode1*"720p"*".mp4" ]] || [[ $original == *$tvShowEpisode1*"720p"*".avi" ]] || [[ $original == *$tvShowEpisode1*"720p"*".mkv" ]] || [[ $original == *$tvShowEpisode1*"720p"*".jpg" ]]
							then
								if [ $debug -eq "1" ]
								then						
									echo "Low-res file:"$original
								fi
#Copy the matching file back
								if [ -f "${tvSeason}" ]
								then
									if [ $inUse -eq "0" ]
									then
										echo "Pass: "$passNumber
										echo "<font color='blue'><b>"$tvShowName" "$tvShowEpisode1" "$tvShowExtension" moved.</b></font>"
										mv "${tvSeason}" "${tvShowOriginal}"
										let passNumber++
										let passNumberTV++
										/usr/local/emhttp/webGui/scripts/notify -e "4K Copier" -s "Copy Notifcation" -d "$tvShowName $tvShowEpisode1 $tvShowExtension has been copied back." -i "normal"
										if [ $debug -eq "0" ]
										then
											echo ""
										fi
									fi
								fi
							fi
						done
					fi
				if [ $debug -eq "1" ]
				then
					echo ""
				fi
				fi
			done
		fi
	done
		
	
#Send a notification with total files copied.
let passNumber--
if [ $passNumber -gt 1 ]
then
	/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$passNumber files have been copied." -i "warning"
fi
