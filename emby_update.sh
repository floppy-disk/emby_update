#!/bin/bash

Help()
{
   # Display Help
   echo "This update script will check if there is a newer version"
   echo "of Emby available and install it if there is."
   echo 
   echo "You must make ONE update to this script: server_url variable"
   echo "must be updated to your Emby url or ip address"
   echo "Don't forget the http:// or https://"
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
     \?) # incorrect option
         Help
         exit;;
   esac
done

##### UPDATE MEEEEEEEE ##########
server_url="https://127.0.0.1:8096"
#################################

inst_ver=$(curl -s -m 10 $(echo $server_url)/web/index.html) 
inst_ver=$(echo "$inst_ver" \
    | sed -n '/data-appversion=\"/p' \
    | awk -F "data-appversion=\"" '{print $2}' \
    | sed 's/\".*//')
echo "Current version installed: $inst_ver"

curr_release=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest) 
curr_release=$(echo "$curr_release" | sed -n '/tag_name\"/p'| awk -F':' '{ print $2 }' | sed 's/\"//; s/\",//; s/^[ \t]*//')
echo "Latest verion available: $curr_release"

if [ "$inst_ver" = "$curr_release" ]; then
    echo "Emby is up to date."
else
    echo "Emby will be updated now."
    download_url=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep browser_download_url | grep emby-server-deb.*amd64.deb | grep -v "md5" | cut -d '"' -f 4)
    echo $download_url
    wget -q $download_url -O "/tmp/emby_latest.deb"
    dpkg -i "/tmp/emby_latest.deb"
    rm "tmp/emby_latest.deb"
    echo "Emby has been updated and the install file has been cleaned up."
fi
