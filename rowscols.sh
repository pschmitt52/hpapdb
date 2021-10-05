#!/bin/bash
#===============================================================================
#
#          FILE:  rowscols.sh
# 
#         USAGE:  ./rowscols.sh <database> <table> 
# 
#   DESCRIPTION:  print row and column count of table
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Pete Schmitt (gemini), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  1.0
#       CREATED:  10/02/2018 11:06:21 AM EDT
#      REVISION:  ---
#===============================================================================
SCRIPT=`basename ${BASH_SOURCE[0]}`
BOLD='[1;31m'
REV='[1;32m'
OFF='[0m'
DUMPDIR=$PWD
################################################################################
function HELP {
    echo
    echo -e "${REV}Basic syntax:${OFF} ${BOLD}$SCRIPT -d <schema> -t <table>"
    echo
    echo -e "${REV}The following switches are recognized. $OFF "
    echo -e "${REV}-d ${OFF}  Database name"
    echo -e "${REV}-t ${OFF}  Table name"
    echo -e "${REV}-h ${OFF}  Displays this help message."
    echo
    exit 1
}
################################################################################
#
# get options
#
while getopts d:t:h FLAG
do
    case $FLAG in
        d)
            DB=$OPTARG
            ;;
        t)
            TBL="$OPTARG"
            ;;
        h)
            HELP
            ;;
        \?)
            echo -e "Option not available."
            HELP
            ;;
    esac
done
################################################################################
#
# ensure DB exists
#
if test "$DB" = ""
then
    HELP
    exit 0
else
    tmpd=`mktemp -d`
    mysql -e "show databases;" > $tmpd/databases.txt
    if 
        egrep ^${DB}$ $tmpd/databases.txt > /dev/null
    then
        :
    else
        echo "Schema $DB does not exist"
        exit 2
    fi
    rm -rf $tmpd 
fi
################################################################################
#
# Let's get the rows and columns
#
cmd="connect $DB;select "
cmd+='count(*) '
cmd+="from \`$TBL\`"
rows=`mysql -e "$cmd" | tail -1`

cols=`mysql -e "select count(*) from information_schema.columns \
     where ( table_schema = '$DB' AND table_name = '$TBL' )" | tail -1`

echo "$rows:$cols"
