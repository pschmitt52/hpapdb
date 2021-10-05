#!/bin/bash
#===============================================================================
#
#          FILE:  restoredb.sh
# 
#         USAGE:  ./restoredb.sh -d <schema> -f <sql dump file>
# 
#   DESCRIPTION:  restore schema from SQL dump file
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#       UPDATES:  181220: added -v (verbose) option
#        AUTHOR:  Pete Schmitt (gemini), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.1.1
#       CREATED:  09/12/2018 01:55:39 PM EDT
#      REVISION:  Thu Dec 20 13:04:43 EST 2018
#===============================================================================
SCRIPT=`basename ${BASH_SOURCE[0]}`
BOLD='[1;31m'
REV='[1;32m'
OFF='[0m'
V=1
################################################################################
function HELP {
    echo
    echo -n "${REV}Basic syntax:${OFF} ${BOLD}$SCRIPT -d <schema>"
    echo " -f <SQL dump file>$OFF"
    echo
    echo -e "${REV}The following switches are recognized. $OFF "
    echo -e "${REV}-d ${OFF}  Database name"
    echo -e "${REV}-f ${OFF}  SQL dump file to restore"
    echo -e "${REV}-v ${OFF}  Verbosity turned on"
    echo -e "${REV}-h ${OFF}  Displays this help message."
    echo
    exit 1
}
################################################################################
#
# get options
#
if test "$1" = ""
then
    HELP
fi
while getopts d:f:hv FLAG
do
    case $FLAG in
        d)
            DB=$OPTARG
            ;;
        f)
            SQL="$OPTARG"
            if test -f $SQL
            then
                :
            else
                echo "${BOLD}$SQL does not exist!$OFF"
                exit 2
            fi
            ;;
        h)
            HELP
            ;;
        v)
            V=0
            ;;
        \?)
            echo -e "Option not available."
            HELP
            ;;
    esac
done
################################################################################
#
# Let's do the restore
#
if test "$V" -eq 0
then
    echo -e "${REV}restoring $DB schema from $SQL $OFF"
fi
mysql $DB < $SQL 
