#!/bin/bash
#===============================================================================
#
#          FILE:  lsdatabases.sh
# 
#         USAGE:  ./lsdatabases.sh
# 
#   DESCRIPTION:  lists hpap schemas  
# 
#       OPTIONS:  
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Pete Schmitt (gemini), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.1
#       CREATED:  Tue Oct 16 11:01:35 EDT 2018
#      REVISION:  ---
#===============================================================================
dbs() 
{
    tmpd=`mktemp -d`
    cd $tmpd
    mysql -e "show databases" | grep -i hpap > dbs.txt
    cat dbs.txt 
    cd ..; rm -rf $tmpd
}
dbs
