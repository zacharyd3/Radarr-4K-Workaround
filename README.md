# Radarr 4K Workaround

### This script is intended for use with Unraid and Radarr
To properly setup this script a few things are needed:
* The recycle bin to be enabled in Radarr
* Your 4K profile must also include 1080p copies
* The userscripts plugin for Unraid
* Your movies need to be sorted into their own folder /Movie Name/
* **The naming scheme of your movies needs to be "Aladin [ 1992 WEBDL-1080p 10bit 5.1].mkv"**
* It's not absolutely needed, but the Recycle Bin plugin for Unraid would also be benefical.


~~## Install Instructions
First off, download or copy the script to a new userscript script. There are 3 variables/entries you'll need to change in the script to suit your situation.~~

~~1. On line 21, change "bin" to the location of your recycle bin folder you have setup in Radarr.~~

~~2. Edit line 25 to change "movieFolderRoot" to be the location you store your movies (i.e /mnt/user/Videos/Movies/)~~

~~3. Edit Line 38 to change the 7 in "f7" to how many directories there are before your recycle bin + 2. (i.e /mnt/user/Downloads/Recycle Bin/ has mnt(1) user(2) Downloads(3) so you'll want to change 7 to 3+2, therefore 5).~~

~~4. *Optional: If you want to automate this even more, you can use the Unraid plugin called Recycle Bin. It creates a recycle bin for any files you delete over the network. That being said, if you set your Radarr recycle bin to the same folder that the plugin uses, and tell the plugin to clear all files over 2 days old, then any files that Radarr moves here that don't have anything to do with 4K copies, will automatically be deleted in 2 days.*~~

~~5. *Optional: There is also a notification setup to send a warning notification to Unraid to show when a file is copied back. It's setup as a warning as I personally only have warnings set to notify me by app. If you'd like to tweak this or disable it outright, change, or remove line 73.*~~

~~This should be all that is needed to get it setup and running. However, you may want to do a test first. To do this, find line 72 and add a pound symbol (#) before the mv. This will comment out this line so it doesn't actually move anything. Next, run the script and you should get an output counting the passes and saying "Movie X .ext moved". As long as you see an output saying files are moved, then you should be good to go. So go back, remove the (#) added to line 72 and it will move the movies accordingly.~~
