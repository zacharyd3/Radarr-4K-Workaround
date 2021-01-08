#!/bin/bash

#####################################
#
#       Created by: zacharyd3
#
#####################################


#Start Debugging (set as 1 to enable basic info, 2 enables all steps to show and 3 shows all steps and comparison info)
debug=0
#Enable testing mode to simulate the move without actually moving any files (0 = moves files, 1 = Test)
testing=1

#If testing is enabled, automatically switch to debug mode 2
if [[ $testing -eq 1 && $debug -le 2 ]]
then
	debug=2
	echo "<font color='blue'><b>Testing is enabled, enabling advanced debugging.</b></font>"
fi

#Ensures the recycle bin is setup properly
echo "<hr>"
echo "<font color='blue'><b>Recycle Bin scan started!</b></font>"
echo ""
echo "<hr>"

#Checks if the movies recycle bin exists
if [[ ! -d "/mnt/user/Downloads/.Recycle.Bin/Movies/" ]]
then
	echo "<font color='orange'><b>Movie bin not found!</b></font>"
	#Creates missing directory
	mkdir "/mnt/user/Downloads/.Recycle.Bin/Movies/"
	echo "<font color='green'><b>Directory created.</b></font>"
	else
	echo "<font color='green'><b>Movie bin already exists.</b></font>"
fi

#Checks if the tv show recycle bin exists
if [[ ! -d "/mnt/user/Downloads/.Recycle.Bin/TV/" ]]
then
	echo "<font color='orange'><b>TV Show bin not found!</b></font>"
	#Creates missing directory
	mkdir "/mnt/user/Downloads/.Recycle.Bin/TV/"
	echo "<font color='green'><b>Directory created.</b></font>"
else
	echo "<font color='green'><b>TV Show bin already exists.</b></font>"
fi
echo ""

#Start counting the renaming passes made
passNumber=1

#Set radarr recycle bin location
binMovie=/mnt/user/Downloads/.Recycle.Bin/Movies/
binTV=/mnt/user/Downloads/.Recycle.Bin/TV/

#Set the library locations
movieFolderRoot=/mnt/user/Videos/Movies/
tvFolderRoot=/mnt/user/Videos/TV/

#####################################
#
#         Low-res Movie Sorter
#
#####################################

inUse=0
cCheck=0

echo "<hr>"
echo "<font color='blue'><b>Copying Low-res movies back.</b></font>"
echo ""
echo "<hr>"

#Run the next commands on each file in the recycle bin
for file in $binMovie*
do
#Start checking Movies.
	if [ -d "${file}" ]
	then
		directory=$file/
		for movieFile in "${directory}"*
		do
			if [ -f "${movieFile}" ]
			then
#Parse movie name from filenames found ( Change the number after "F" to how many directories there are before the recycle bin and add 2. )
				parseNameOld0=$(echo "$movieFile" | cut -d'/' -f8) #<<Change this number
				parseNameOld1=$(echo "$parseNameOld0" | cut -d'(' -f1)
				parseNameOld2=${parseNameOld1::-2}
				parseNameOld2=$(echo $parseNameOld2 | xargs) #xargs removes leading and trailing whitespace.
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Original Movie name: </b></font>"$parseNameOld2
				fi
#Check if the recycled file is 1080p.
				if [[ $movieFile != *"1080p"* ]]
				then
					if [ $debug -ge "1" ]
					then
						echo "<font color='orange'><b>The file is not 1080p, skipping.</b></font>"
						echo ""
						break
					else
						let cCheck=1
					fi
				fi
#Check if the file is in use.
				if lsof "$movieFile" > /dev/null; then
					echo "<font color='orange'><b>File is in use, skipping.</b></font>"
					echo ""
					inUse=1
					break
				else
					inUse=0
				fi
#Parse file extension
				parseExt=$(echo "$movieFile" | cut -d'.' -f5)
#Turn the parsed movie name into a folder
				movieFolder0=$movieFolderRoot$parseNameOld2
				movieFolder1="${movieFolder0}/"
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Searching for 4K Movie folder: </b></font>"$movieFolder1
				fi
#Test if the movie folder exists
				if [ -d "${movieFolder1}" ]
				then
					cd "${movieFolder1}"
#Search the folder for 4K movies
					foundNew=$(find . -maxdepth 1 -name "*2160p*" -size +1536M)
					if [[ "$foundNew" != "" ]]
					then
						if [ $debug -ge "1" ]
						then
							echo "<font color='green'><b>Found matching 4K Movie: </b></font>"$foundNew
						fi
					fi
#Parse movie name only if 4K filename found
				if [[ "$foundNew" == *"2160p"* ]]
				then
					parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
					parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
					parseNameNew2=${parseNameNew1}
					parseNameNew2=$(echo $parseNameNew2 | xargs) #xargs removes leading and trailing whitespace
					if [ $debug -ge "2" ]
					then
						echo "<font color='red'><b>Name Comparison:</b></font> |" $parseNameOld2 "|" $parseNameNew2 "|"
					fi
						if [ "${parseNameOld2}" == "${parseNameNew2}" ]
						then
							if [ "${parseExt}" != "nfo" ]
							then
								if [ $debug -ge "2" ] && [ $inUse -eq "0" ]
								then
									echo "<font color='red'><b>Files Checked: </b></font>"$passNumber
								fi
								let passNumber++
								if [ $testing -eq "0" ]
								then
									mv "${movieFile}" "${movieFolder1}"
								fi
								/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$parseNameNew2 $parseExt has been copied back." -i "normal"
								echo "<font color='green'><b>"$parseNameNew2" "$parseExt" moved.</b></font>"
								echo ""
							fi
						fi
					fi
				fi
				if [ $debug -ge "1" ]
				then
					echo ""
				fi
			fi
		done
	fi
done

if [[ passNumber -eq "1" ]]
then
echo "No files to process"
echo ""
echo ""
fi

#####################################
#
#         4K Movie Sorter
#
#####################################

passNumber=1
inUse=0
cCheck=0

echo "<hr>"
echo "<font color='blue'><b>Copying 4K Movies back.</b></font>"
echo ""
echo "<hr>"

#Run the next commands on each file in the recycle bin
for file in $binMovie*
do
#Start checking Movies.
	if [ -d "${file}" ]
	then
		directory=$file/
		for movieFile in "${directory}"*
		do
			if [ -f "${movieFile}" ]
			then
#Parse movie name from filenames found ( Change the number after "F" to how many directories there are before the recycle bin and add 2. )
				parseNameOld0=$(echo "$movieFile" | cut -d'/' -f8) #<<Change this number
				parseNameOld1=$(echo "$parseNameOld0" | cut -d'(' -f1)
				parseNameOld2=${parseNameOld1::-2}
				parseNameOld2=$(echo $parseNameOld2 | xargs) #xargs removes leading and trailing whitespace.
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Original Movie name: </b></font>"$parseNameOld2
				fi
#Check if the recycled file is 4K.
				if [[ $movieFile != *"2160p"* ]]
				then
					if [ $debug -ge "1" ]
					then
						echo "<font color='orange'><b>The file is not 4K, skipping.</b></font>"
						echo ""
						break
					else
						let cCheck=1
					fi
				fi
#Check if the file is in use.
				if lsof "$movieFile" > /dev/null; then
					echo "<font color='orange'><b>File is in use, skipping.</b></font>"
					echo ""
					inUse=1
					break
				else
					inUse=0
				fi
#Parse file extension
				parseExt=$(echo "$movieFile" | cut -d'.' -f5)
#Turn the parsed movie name into a folder
				movieFolder0=$movieFolderRoot$parseNameOld2
				movieFolder1="${movieFolder0}/"
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Searching for Low-res Movie folder: </b></font>"$movieFolder1
				fi
#Test if the movie folder exists
				if [ -d "${movieFolder1}" ]
				then
					cd "${movieFolder1}"
#Search the folder for Low-res movies
					foundNew=$(find . -maxdepth 1 -name "*1080p*" -size +1536M)
					if [[ "$foundNew" != "" ]]
					then
						if [ $debug -ge "1" ]
						then
							echo "<font color='green'><b>Found matching Low-res Movie: </b></font>"$foundNew
						fi
					fi
#Parse movie name only if Low-res filename found
				if [[ "$foundNew" == *"1080p"* ]]
				then
					parseNameNew0=$(echo "$foundNew" | cut -d'[' -f1)
					parseNameNew1=$(echo "$parseNameNew0" | cut -d'/' -f2)
					parseNameNew2=${parseNameNew1}
					parseNameNew2=$(echo $parseNameNew2 | xargs) #xargs removes leading and trailing whitespace
					if [ $debug -ge "2" ]
					then
						echo "<font color='red'><b>Name Comparison:</b></font> |" $parseNameOld2 "|" $parseNameNew2 "|"
					fi
						if [ "${parseNameOld2}" == "${parseNameNew2}" ]
						then
							if [ "${parseExt}" != "nfo" ]
							then
								if [ $debug -ge "2" ] && [ $inUse -eq "0" ]
								then
									echo "<font color='red'><b>Files Checked: </b></font>"$passNumber
								fi
								let passNumber++
								if [ $testing -eq "0" ]
								then
									mv "${movieFile}" "${movieFolder1}"
								fi
								/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$parseNameNew2 $parseExt has been copied back." -i "normal"
								echo "<font color='green'><b>"$parseNameNew2" "$parseExt" moved.</b></font>"
								echo ""
							fi
						fi
					fi
				fi
				if [ $debug -ge "1" ]
				then
					echo ""
				fi
			fi
		done
	fi
done

if [[ passNumber -eq "1" ]]
then
echo "No files to process"
echo ""
echo ""
fi

#####################################
#
#          TV Show Sorter
#
#####################################

passNumber=1
inUse=0
cCheck=0
folderCheck=0

echo "<hr>"
echo "<font color='blue'><b>Copying Low-res TV Show's back.</b></font>"
echo ""
echo "<hr>"

for file in $binTV*
do
#Start checking TV shows.
	if [ -d "${file}" ]
	then
		directory=$file/
		for tvSeason in "${directory}"*/*
		do
			if [ -f "${tvSeason}" ]
			then
#Parse the show name, episode and season
				tvShowName=$(echo "$tvSeason" | cut -d'/' -f7)
				tvShowSeason=$(echo "$tvSeason" | cut -d'/' -f8)
				tvShowEpisode0=$(echo "$tvSeason" | cut -d'/' -f9)
				tvShowEpisode1=$(echo "$tvShowEpisode0" | cut -d'-' -f1)
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Show name: </b></font>"$tvShowName
					echo "<font color='green'><b>Show episode: </b></font>"$tvShowEpisode1
				fi
#Ensure the recycled file is 1080p
				if [[ $tvSeason == *"1080p"* ]]
				then
					let cCheck=1
					let folderCheck=0
				fi
#Check if the recycled file isn't 1080p.
				if [[ $tvSeason != *"1080p"* ]]
				then
					if [ $debug -ge "1" ]
					then
						echo "<font color='orange'><b>The file is not 1080p, skipping.</b></font>"
						echo ""
					fi
					let cCheck=0
				else
					let cCheck=1
#Check if the file is in use.
					if lsof "$tvSeason" > /dev/null; then
						echo "<font color='orange'><b>File is in use, skipping.</b></font>"
						echo ""
						inUse=1
						break
					else
						inUse=0
					fi
				fi
#Parse the folder and Extension
				tvShowOriginal=$tvFolderRoot$tvShowName/$tvShowSeason/
				tvShowExtension=$(echo "$tvSeason" | cut -d'.' -f5)
#Check to see if the file matches a show
				if [[ -d $tvShowOriginal ]]
				then
					if [[ $debug -ge "1"  && cCheck -ge "1" ]]
					then
						echo "<font color='green'><b>Searching for 4K show folder: </b></font>"$tvShowOriginal
					fi
#Scan the files in the show folder for a matching 4K file
					for original in "${tvShowOriginal}"*
					do
						if [[ $original == *$tvShowEpisode1*"2160p"*$tvShowExtension ]] || [[ $original == *$tvShowEpisode1*"2160p"*".mp4" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".avi" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".mkv" ]] || [[ $original == *$tvShowEpisode1*"2160p"*".jpg" ]]
						then
							if [[ $debug -ge "1" && $cCheck -ge "1"  && $folderCheck -lt "1" ]]
							then
								echo "<font color='green'><b>Found matching 4K show: </b></font>"$original
							fi
#Copy the matching file back
							if [ -f "${tvSeason}" ]
							then
								if [[ $inUse -eq "0"  && $cCheck -ge "1" && $folderCheck -lt "1" ]]
								then
									if [ $debug -ge "2" ]
									then
										echo "<font color='red'><b>Files Checked: </b></font>"$passNumber
									fi
									if [ $testing -eq "0" ]
									then
										mv "${tvSeason}" "${tvShowOriginal}"
									fi
									let passNumber++
									let folderCheck++
									/usr/local/emhttp/webGui/scripts/notify -e "4K Copier" -s "Copy Notifcation" -d "$tvShowName $tvShowEpisode1 $tvShowExtension has been copied back." -i "normal"
									if [ $folderCheck -eq "1" ]
									then
										if [ $debug -ge "2" ]
										then
											echo "<font color='red'><b>cCheck: </b></font>"$cCheck
										fi
										echo "<font color='green'><b>"$tvShowName" "$tvShowEpisode1" "$tvShowExtension" moved.</b></font>"
										echo ""
										let folderCheck++
									fi
								fi
							fi
						fi
					done
				fi
				if [ $debug -ge "2" ]
				then
					echo ""
				fi
			fi
		done
	fi
done

if [[ passNumber -eq "1" ]]
then
echo "No files to process"
echo ""
echo ""
fi

#####################################
#
#          4K TV Show Sorter
#
#####################################

passNumber=1
inUse=0
cCheck=0
folderCheck=0

echo "<hr>"
echo "<font color='blue'><b>Copying 4K TV Shows back.</b></font>"
echo ""
echo "<hr>"

for file in $binTV*
do
#Start checking TV shows.
	if [ -d "${file}" ]
	then
		directory=$file/
		for tvSeason in "${directory}"*/*
		do
			if [ -f "${tvSeason}" ]
			then
#Parse the show name, episode and season
				tvShowName=$(echo "$tvSeason" | cut -d'/' -f7)
				tvShowSeason=$(echo "$tvSeason" | cut -d'/' -f8)
				tvShowEpisode0=$(echo "$tvSeason" | cut -d'/' -f9)
				tvShowEpisode1=$(echo "$tvShowEpisode0" | cut -d'-' -f1)
				if [ $debug -ge "1" ]
				then
					echo "<font color='green'><b>Show name: </b></font>"$tvShowName
					echo "<font color='green'><b>Show episode: </b></font>"$tvShowEpisode1
				fi
#Ensure the recycled file is 2160p
				if [[ $tvSeason == *"2160p"* ]]
				then
					let cCheck=1
					let folderCheck=0
				else
					let cCheck=0
				fi
#Check if the recycled file isn't 4K.
				if [[ $tvSeason != *"2160p"* ]]
				then
					if [ $debug -ge "1" ]
					then
						echo "<font color='orange'><b>The file is not 4K, skipping.</b></font>"
						echo ""
					fi
					let cCheck=0
				else
					let cCheck=1
				fi
#Check if the file is in use.
				if lsof "$tvSeason" > /dev/null; then
					echo "<font color='orange'><b>File is in use, skipping.</b></font>"
					echo ""
					inUse=1
					break
				else
					inUse=0
				fi
#Parse the folder and Extension
				tvShowOriginal=$tvFolderRoot$tvShowName/$tvShowSeason/
				tvShowExtension=$(echo "$tvSeason" | cut -d'.' -f5)
#Check to see if the file matches a show
				if [[ -d $tvShowOriginal ]]
				then
					if [[ $debug -ge "1"  && cCheck -ge "1" ]]
					then
						echo "<font color='green'><b>Searching for 1080p show folder: </b></font>"$tvShowOriginal
					fi
#Scan the files in the show folder for a matching Low-res file
					for original in "${tvShowOriginal}"*
					do
						if [[ $original == *$tvShowEpisode1*"1080p"*$tvShowExtension || $original == *$tvShowEpisode1*"1080p"*".mp4" || $original == *$tvShowEpisode1*"1080p"*".avi" || $original == *$tvShowEpisode1*"1080p"*".mkv" || $original == *$tvShowEpisode1*"1080p"*".jpg" || $original == *$tvShowEpisode1*"720p"*$tvShowExtension || $original == *$tvShowEpisode1*"720p"*".mp4" || $original == *$tvShowEpisode1*"720p"*".avi" || $original == *$tvShowEpisode1*"720p"*".mkv" || $original == *$tvShowEpisode1*"720p"*".jpg" ]]
						then
							if [[ $debug -ge "1" && $cCheck -ge "1"  && $folderCheck -lt "1" ]]
							then
								echo "<font color='green'><b>Found matching 1080p show: </b></font>"$original
							fi
#Copy the matching file back
							if [ -f "${tvSeason}" ]
							then
								if [[ $inUse -eq "0"  && $cCheck -ge "1" && $folderCheck -lt "1" ]]
								then
									if [ $debug -ge "2" ]
									then
										echo "<font color='red'><b>Files Checked: </b></font>"$passNumber
									fi
									if [ $testing -eq "0" ]
									then
										mv "${tvSeason}" "${tvShowOriginal}"
									fi
									let passNumber++
									let folderCheck++
									/usr/local/emhttp/webGui/scripts/notify -e "4K Copier" -s "Copy Notifcation" -d "$tvShowName $tvShowEpisode1 $tvShowExtension has been copied back." -i "normal"
									if [ $folderCheck -eq "1" ]
									then
										if [ $debug -ge "2" ]
										then
											echo "<font color='red'><b>cCheck: </b></font>"$cCheck
										fi
										echo "<font color='green'><b>"$tvShowName" "$tvShowEpisode1" "$tvShowExtension" moved.</b></font>"
										echo ""
										let folderCheck++
									fi
								fi
							fi
						fi
					done
				fi
				if [ $debug -ge "2" ]
				then
					echo ""
				fi
			fi
		done
	fi
done

if [[ passNumber -eq "1" ]]
then
echo "No files to process"
echo ""
echo ""
fi

#####################################
#
#     Remove Empty Directories
#
#####################################

deletedDirCount=0

echo "<hr>"
echo "<font color='blue'><b>Removing empty directories.</b></font>"
echo ""
echo "<hr>"

#Clear empty movie bins
for emptyDir in $binMovie*
do
#Check that the scanned item is a directory
	if [ -d "${emptyDir}" ]
	then
#Check for empty directories only
		if [[ -z $(ls -A "$emptyDir") ]]
		then
#Log individual deleted files if advanced debugging is enabled.
			if [ $debug -ge "2" ]
				then
				echo "<font color='green'><b>Deleting: </b></font>"$emptyDir
			fi
#Actually do the removing and count how many directories have been deleted.
			if [ $testing -eq 0 ]
			then
				rmdir "${emptyDir}"
				let deletedDirCount++
			fi
		fi
	fi
done

#Clear empty tv show season bins (This has to be done before trying to remove the show folder)
for emptyDir in $binTV*
do
	for emptySeason in $binTV*/*
	do
#Check that the scanned item is a directory
		if [ -d "${emptySeason}" ]
		then
#Check for empty directories only
			if [[ -z $(ls -A "$emptySeason") ]]
			then
#Log individual deleted files if advanced debugging is enabled.
				if [ $debug -ge "2" ]
					then
					echo "<font color='green'><b>Deleting: </b></font>"$emptySeason
				fi
#Actually do the removing and add to how many directories have been deleted.
				if [ $testing -eq 0 ]
				then
					rmdir "${emptySeason}"
					let deletedDirCount++
				fi
			fi
		fi
	done
done

#Clear empty tv show bins (this has to be done after removing the seasons first [above])
for emptyDir in $binTV*
do
#Check that the scanned item is a directory
	if [ -d "${emptyDir}" ]
	then
#Check for empty directories only
		if [[ -z $(ls -A "$emptyDir") ]]
		then
#Log individual deleted files if advanced debugging is enabled.
			if [ $debug -ge "2" ]
				then
				echo "<font color='green'><b>Deleting: </b></font>"$emptyDir
			fi
#Actually do the removing and add to how many directories have been deleted.
			if [ $testing -eq 0 ]
			then
				rmdir "${emptyDir}"
				let deletedDirCount++
			fi
		fi
	fi
done

#Log the deleted files and print message if testing is enabled instead.
if [ $testing -eq 0 ]
then
	echo "<font color='green'><b>Empty directories deleted: </b></font>"$deletedDirCount
else
	echo "<font color='orange'><b>Testing is enabled, so nothing has been deleted.</b></font>"
fi

#Send a notification with total files copied.
let passNumber--

#Notification where nothing was deleted but files were copied.
if [[ $passNumber -gt 1 && $testing -eq 0 && $deletedDirCount -eq 0 ]]
then
	/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$passNumber files have been copied." -i "warning"
fi

#Notification where directories were deleted and files were copied.
if [[ $passNumber -gt 1 && $testing -eq 0 && $deletedDirCount -gt 0 ]]
then
	/usr/local/emhttp/webGui/scripts/notify -e "Radarr Copy" -s "Copy Notifcation" -d "$passNumber files have been copied, and $deletedDirCount empty directories have been deleted." -i "warning"
fi
