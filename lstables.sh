#!/bin/bash
#===============================================================================
#
#          FILE:  lstables.sh
# 
#         USAGE:  ./lstables.sh <database name>
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  database name
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Pete Schmitt (gemini), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.1
#       CREATED:  10/01/2018 01:55:28 PM EDT
#      REVISION:  ---
#===============================================================================
DB=$1
if test "$DB" = ""
then
    echo "Syntax $0 <database name>"
    exit 1
fi
tables() 
{
    tmpd=`mktemp -d`
    cd $tmpd
    mysql -e "connect $DB; show tables" > tables.txt
    cat tables.txt | grep -v "Tables_in_$DB"
    cd ..; rm -rf $tmpd
}
tables
