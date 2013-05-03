#!/bin/bash
#######################################################
##  Google Earth Enterprise Backup Script     
##  Created by Dale Kunce: (dale@normalhabit.com)
##
##	Started with advice from Google Support Page @
##		http://bit.ly/ryOQ2f
#######################################################

#gehttpd dir
ghttpdir=/opt/google/gehttpd/

#stuff to backup
gassets=/gevol/assets/
gprojects=Projects/Vector/
gkmls=/volumes/kml
gicons=/gevol/src/icons/

#backup dirs
gbu=/data/backup/
gbuassets=/data/backup/assets/
gbulayers=/data/backup/layertemplates/
gbukmls=/data/backup/kmls/
gbuicons=/data/backup/icons/

#tars of backups
gtar=/data/zips/

#logs
glog=/data/logs/gBackupLog.txt
gXMLlist=/data/logs/gXML.txt
gKMLlist=/data/logs/gKML.txt
gIconlist=/data/logs/gIcon.txt

#######################################################
## Do Not Edit Below this line
#######################################################

echo "BACKUP $(date +%Y_%m_%d)" >> $glog

#backup gehttpd
echo "starting gehttpd backup"
cd $ghttpdir

rsync -r -l htdocs cgi-bin conf conf.d $ghttpdir

if [ $? == 0 ]; then
	echo "success gehttpd $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED gehttpd $(date +%Y_%m_%d)" >> $glog
fi

#backup config and userdata stuff in assets
echo "starting assets backup"
cd $gassets

rsync -r .config .userdata $gbuassets

if [ $? == 0 ]; then
	echo "success assets $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED assets $(date +%Y_%m_%d)" >> $glog
fi

#backup the ever important xml
echo "starting xml backup"
find . -name \*xml > $gXMLlist
rsync --files-from=$gXMLlist $gassets $gbuassets
echo "gooFileList updated $(date +%Y%m%d)" >> $gXMLlist

if [ $? == 0 ]; then
	echo "success xml $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED xml $(date +%Y_%m_%d)" >> $glog
fi

#backup kml directory
echo "starting kml backup"
cd $gkmls

find . -name \*kml > $gKMLlist
find . -name \*kmz >> $gKMLlist
rsync -r -l --files-from=$gKMLlist $gkmls $gbukmls
echo "KML file list updated $(date +%Y_%m_%d)" >> $gKMLlist

if [ $? == 0 ]; then
	echo "success kml $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED kml $(date +%Y_%m_%d)" >> $glog
fi

#backup icons
echo "starting icon backup"
cd $gicons

find . -name \*png > $gIconlist
rsync -r -l --files-from=$gIconlist $gicons $gbuicons
echo "Icon File List Updated $(date +%Y_%m_%d)" >> $gIconlist

if [ $? == 0 ]; then
	echo "success icons $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED icons $(date +%Y_%m_%d)" >> $glog
fi

#backup vector layer templates
echo "starting layer template backup"
#delete layer template dir otherwise fusion throws an error
rm -rf $gbulayers

if [ $? == 0 ]; then
	echo "success cleaned $gbulayers $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED cleaned $gbulayers $(date +%Y_%m_%d)" >> $glog
fi

#add multiple projects by adding a new line for each project
#geeexportlayertemplate --project [relative path to project] --alllayers -o [absolute path to backup location (must be unique for each project)]
geexportlayertemplate --project $gprojects --alllayers -o $gbulayers

if [ $? == 0 ]; then
	echo "success layer templates $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED layer templates $(date +%Y_%m_%d)" >> $glog
fi


#create archives of layer templates and other stuff
#to save space clean up the backup dir of tar files older than seven days
echo "starting tar"
cd $gtar
delfiles=`find -name \*tgz -mtime +7`
find -name \*tgz -mtime +7 -exec rm -f {} \; 

if [ -z "$delfiles" ]; then
  echo "No archives deleted $(date +%Y_%m_%d)" >> $glog
else
  echo "DELETED $delfiles $(date +%Y_%m_%d)" >> $glog
fi

tar -Pczf $gtar/CTEarthBackup_$(date +%Y%m%d).tgz $gbu

if [ $? == 0 ]; then
	echo "success archiving $(date +%Y_%m_%d)" >> $glog
else
	echo "FAILED archiving $(date +%Y_%m_%d)" >> $glog
fi

exit


