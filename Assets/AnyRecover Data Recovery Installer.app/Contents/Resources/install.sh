#!/bin/bash
dmg=$1
domainPath=$2
#echo $dmg

xattr -d com.apple.quarantine "$dmg" 2>/dev/null

mountPoint=$(mktemp -d -t mount 2>/dev/null)

echo "Start Mount"

#bypass EULA with yes
VOL=$(yes | hdiutil attach -mountpoint "$mountPoint" -nobrowse "$dmg" 2>/dev/null)

echo "Mount Success"

if [ $? != 0 ]
then
exit -1
fi

echo "Start Copy"

rsync -a --delete --progress "$mountPoint"/*.app /Applications/

echo "Copy Success"

if [ $? != 0 ]
then
exit -1
fi

files=($mountPoint/*.app)
app_name=$(basename "${files[0]}")
app="/Applications/$app_name"


hdiutil detach -quiet "$mountPoint"
rmdir $mountPoint
if [[ -d "$app" ]];then

	if [[ -d "$app/Contents/MacOS/$app_name" ]];then
    	echo "cp domain1"
    	cp "$domainPath" "$app/Contents/MacOS/$app_name/Contents/MacOS/domain"
	else
		echo "cp domain2"
    	cp "$domainPath" "$app/Contents/MacOS/domain"
	fi

    open "$app"
    echo "Open Success"
fi

rm "$dmg"