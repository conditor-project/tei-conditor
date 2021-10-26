#!/bin/bash

xslDir=`dirname $1`
shortName=`basename $1 .xsl`
sefPath="$xslDir/$shortName.sef.json"
echo "try to compile $1"
xslt3 -xsl:"$1" -export:"$sefPath" -t -nogo
if [[ $? -eq 0 ]]; then
    echo "Successfully generated $sefPath"
    exit 0
else
    echo "$1 failed to compile..."
    exit 1
fi
