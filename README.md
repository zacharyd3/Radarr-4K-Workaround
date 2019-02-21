# Radarr-Recycle-Copy

### This script is intended for use with Unraid and Radarr
To properly setup this script a few things are needed:
* The recycle bin to be enabled in Radarr
* Your 4K profile must also include 1080p copies
* The userscripts plugin for unraid
* Your movies need to be sorted into their own folder /Movie Name/
* **The naming scheme of your movies needs to be "Aladin [ 1992 WEBDL-1080p 10bit 5.1].mkv"**


## Install Instructions
First off, download or copy the script to a new userscript script. There are 3 variables/entries you'll need to change in the script to suit your situation. 

1. On line 21, change "bin" to the location of your recycle bin folder you have setup in Radarr. 

2. Edit line 25 to change "movieFolderRoot" to be the location you store your movies (i.e /mnt/user/Videos/Movies/)

3. Edit Line 38 to change the 7 in "f7" to how many directories there are before your recycle bin + 2. (i.e /mnt/user/Downloads/Recycle Bin/ has mnt(1) user(2) Downloads(3) so you'll want to change 7 to 3+2, therefore 5).

This should be all that is needed to get it setup and running. However, you may want to do a test first. To do this, find line 72 and add a pound symbol (#) before the mv. This will comment out this line so it doesn't actually move anything. Next, run the script and you should get an output counting the passes and saying "Movie X .ext moved". As long as you see an output saying files are moved, then you should be good to go. So go back, remove the (#) added to line 72 and it will move the movies accordingly.
