#!/bin/bash
#######################################################
##  Vector Build Script   
##  Created by Dale Kunce: (dale@normalhabit.com)
##
##  This script will work for any shapefile directory, 
##  just modify the variables below.
##
##  This script assumes you have Google Earth Fusion
##	installed on the same machine as the source data.
##
#######################################################

now=$(date -I)
datadir=/path/to/your/data
resrcdir=Resources/Vector/path/
template=/path/to/templates/template.khdsp
provider=provider
project=Projects/Vector/projectname.kvproject
db=Databases/databaseName
server=serverName
log=/path/to/logfile/buildlog.txt

#######################################################
## Do Not Edit Below this line
#######################################################

cd $datadir

echo "Project build started $now" > $log

for f in *.shp
do
	filename=${f%.*}
	echo "filename = $filename"
	sourcename=$f
	echo "sourcename = $f"
	echo "modifying vector resource $filename"
	gemodifyvectorresource --sourcedate $now --provider $provider -o $resrcdir/$filename $sourcename
	gebuild $resrcdir/$filename
done

#building the project is unnessasary when building the database but it adds another check
gebuild $project
prjstat=$(gequery --status $project)

if [ $prjstat != "Succeeded" ]; then
	while [ $prjstat != "Succeeded" ]
	do
		if [ $prjstat = "Failed" ]; then
			echo "Project $project FAILED $now" >> $log
			break   #Run away from the while loop
		elif [ $prjstat = "Blocked" ]; then
			echo "Project $project BlOCKED $now" >> $log
			break   #Oh NO run far far away from the while loop
		fi
	done
else
	echo "Project $project Successful $date" >> $log
fi

gebuild $db
dbbldstat=$(gequery --status $db)

#gotta wait until the build finishes otherwise fusion error
if [ $dbbldstat != "Succeeded" ]; then
	while [ $dbbldstat != "Succeeded" ]
	do
		wait 30
		
		if [ $dbbldstat = "Failed" ]; then
			echo "Database $db FAILED $now" >> $log
			break   #Abandon the while lopp.
		elif [ $dbbldstat = "Blocked" ]; then
			echo "Database $db BLOCKED $now" >> $log
			break   #Abandon the while lopp.
		fi
	done
else
	echo "Database $db Successful $date" >> $log
fi
		
gepublishdatabase --publish $db --server $server

echo "Database $db Published" >> $log
