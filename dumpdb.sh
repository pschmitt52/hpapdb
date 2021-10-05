#!/bin/bash
#===============================================================================
#
#          FILE:  dumpdb.sh
# 
#         USAGE:  ./dumpdb.sh -d <schema> -p /some/path -i <tables to ignore> 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  only option required is -d
#       UPDATES:  181010: added -p option
#        AUTHOR:  Pete Schmitt (docker), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.2
#       CREATED:  09/12/2018 01:34:12 PM EDT
#      REVISION:  Wed Oct 10 10:48:07 EDT 2018
#===============================================================================
SCRIPT=`basename ${BASH_SOURCE[0]}`
BOLD='[1;31m'
REV='[1;32m'
OFF='[0m'
DUMPDIR=$PWD
################################################################################
function HELP {
    echo
    echo -n "${REV}Basic syntax:${OFF} ${BOLD}$SCRIPT -d <schema> -t <tables>"
    echo " -p /some/path$OFF"
    echo
    echo -e "${REV}The following switches are recognized. $OFF "
    echo -e "${REV}-d ${OFF}  Database name"
    echo -e "${REV}-t ${OFF}  Table(s) to ignore"
    echo -e "     ex: table1 or as a list (no spaces): table1,table2"
    echo -e "${REV}-p ${OFF}  Directory to write dump to."
    echo -e "     Default is current directory: $PWD"
    echo -e "${REV}-v ${OFF}  Verbose with messages"
    echo -e "${REV}-h ${OFF}  Displays this help message."
    echo
    echo "Note: Output file named .<schema>.sql"
    echo
    exit 1
}
################################################################################
#
# get options
#
V=false
while getopts d:t:p:hv FLAG
do
    case $FLAG in
        d) DB=$OPTARG ;;
        t) TBLS="$OPTARG" ;;
        p) DUMPDIR="$OPTARG" ;;
        v) V=true ;;
        h) HELP ;;
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
        if test "$V" = true
        then
            echo "Schema $DB does not exist"
        fi
        exit 2
    fi
    rm -rf $tmpd 
fi
################################################################################
#
# Let's do the dump
#
if test "$TBLS" = ""
then
    if test $V = true
    then
        echo -e "dumping $DB database to $DUMPDIR/.${DB}.sql"
    fi
    mysqldump --databases $DB > $DUMPDIR/.${DB}.sql
else
    OFS="$IFS"
    IFS=','
    ITBLS=""
    for tbl in $TBLS
    do
        ITBLS+=" --ignore-table=${DB}.$tbl"
    done
    IFS="$OFS"

    if test $V = true
    then
        echo -e "dumping $DB database to $DUMPDIR/${DB}.sql (minus $TBLS)"
    fi
    mysqldump --databases $DB $ITBLS > $DUMPDIR/.${DB}.sql
fi
