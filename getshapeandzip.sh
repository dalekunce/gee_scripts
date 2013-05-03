#!/bin/bash
#!/usr/bin/expect
#######################################################
##  Shapefile Zipper   
##  Created by Dale Kunce: (dale@normalhabit.com)
##
##  This script will work for any shapefile directory, 
##  just modify the variables below.
##
#######################################################

date=%Y-%m-%d 
datadir=dir1
filehome=dir2/path/to/file
destination1=hostname:final/destination1/
destination2=hostname:final/destination2/
filesource=hostname/path/to/shapefile
user=user
password=password

#######################################################
## Do Not Edit Below this line
#######################################################

cd $datadir

wget -r -l1 --no-parent -A.shp $filesource
wget -r -l1 --no-parent -A.shx $filesource
wget -r -l1 --no-parent -A.prj $filesource
wget -r -l1 --no-parent -A.dbf $filesource

cd $filehome

for f in *.shp
do
	filename=${f%.*}
	datefile=${f%.*}.txt
	stat -c %Y $filename.shp | echo "$f last updated on $filedate." > $datefile
	echo "For more information please contact" >> $datefile
	
	zip $filename.zip $filename.*
	echo "created $crsname zipfile"

	expect -c "
        # exp_internal 1 # uncomment for debugging
        spawn scp $filehome/$filename.zip $user@$destination2
        expect { 
        "*password:*" { send $password\r\n; interact } 
			eof { exit }
        }
        exit
        "
done

for f in *.shp
do
	filename=${f%.*}

	expect -c "
        # exp_internal 1 # uncomment for debugging
        spawn scp $filehome/$filename.shp $filehome/$filename.shx $filehome/$filename.prj $filehome/$filename.dbf $user@$destination1
        expect { 
        "*password:*" { send $password\r\n; interact } 
			eof { exit }
        }
        exit
        "
done

echo "zipper complete"
