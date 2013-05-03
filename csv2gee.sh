#!/bin/bash
#######################################################
##  Vector Build/Import Script   
##  Created by Dale Kunce: (dale@normalhabit.com)
##
##  This script will work for any csv directory, 
##  just modify the variables below.
##
#######################################################

now=$(date -I)
datadir=/gevol/src/path/to/files
resrcdir=Resources/Vector/
provider=provider
project=Projects/Vector/project.kvproject
log=/path/to/log/log.txt

#######################################################
## Do Not Edit Below this line
#######################################################

cd $datadir

echo "import started $now" >> $log

for f in *.csv
do
	filename=${f%.*}
	echo "filename = $filename"
	sourcename=$f
	echo "sourcename = $f"
	echo "adding vector resource $filename"
	geaddvectorresource --sourcedate $now --provider $provider -o $resrcdir/$filename $sourcename
	
	#build the resource
	gebuild $resrcdir/$filename
done
