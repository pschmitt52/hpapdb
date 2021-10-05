#!/bin/bash
#===============================================================================
#
#          FILE:  cmptables.sh
# 
#         USAGE:  ./cmptables.sh 
# 
#   DESCRIPTION: compares geometry of all tables of a database on local and
#                remote servers
# 
#       OPTIONS:  see HELP function below
#  REQUIREMENTS:  rowscols.sh
#       UPDATES:  181114: added -r for remote server name
#                 181116: added dialog --gauge for progress bar
#                 190213: added skipping compare of ignored tables
#                 190401: added checks for existance of remote tables
#         NOTES:  called from syncdb
#        AUTHOR:  Pete Schmitt (discovery), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.1.3
#       CREATED:  10/24/2018 13:45:40 EDT
#      REVISION:  Mon Apr  1 11:52:17 EDT 2019
#===============================================================================
source $HOME/.hpapdb.cnf
REM=""
DB=""
SCRIPT=`basename ${BASH_SOURCE[0]}`
BOLD='[1;31m'
REV='[1;32m'
OFF='[0m'
export TITLE="HPAP Database Syncer"
################################################################################
function HELP {
    echo
    echo -en "${REV}Basic syntax:${OFF} ${BOLD}$SCRIPT -d <schema> "
    echo -e "-r <remote server> -i <tables,to,ignore>"
    echo
    echo -e "${REV}The following switches are recognized. $OFF "
    echo -e "${REV}-d ${OFF}  Database name"
    echo -e "${REV}-i ${OFF}  comma separated list of tables to ignore"
    echo -e "${REV}-r ${OFF}  Remote server name"
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
    exit 0
fi
while getopts r:d:i:h FLAG
do
    case $FLAG in
        d)
            DB=$OPTARG
            ;;
        r)
            REM=$OPTARG
            ;;
        i)
            IGNR=$OPTARG
            ;;
        h)
            HELP
            ;;
        *)
            echo -e "Option not available."
            HELP
            ;;
    esac
done
################################################################################
#
# get local/remote dimensions
# 
if test "$DB" = ""
then
    echo "need schema to compare with -d option"
    exit 1
fi
if test "$REM" = ""
then
    echo "need remote server with -r option"
    exit 2
fi
RHOME=`ssh -q $REM pwd`
RBIN=`ssh -q $REM "grep BIN .hpapdb.cnf | cut -f2 -d="`
RLIB=`ssh -q $REM "grep LIB .hpapdb.cnf | cut -f2 -d="`
LOCAL=$HOME/.localtables
REMOTE=$HOME/.remotetables
tblcnt=$($LIB/lstables.sh $DB | wc -l)
PCT=$((100/tblcnt))
p=$PCT

rm -f $HOME/.cmpstatus

$LIB/lstables.sh $DB > $HOME/.local-tbls.list
ssh -q $REM "$RLIB/lstables.sh $DB" > $HOME/.remote-tbls.list

for i in `cat $HOME/.local-tbls.list`
do
    # check to see of table exists on remote DB
    if 
        grep "^${i}$" $HOME/.remote-tbls.list > /dev/null
    then
        :
    else
        echo "$i does not exist in the $DB schema on $REM" >> $HOME/.cmpstatus
        continue
    fi

    # ignore ignored tables
    SKIP=N
    if test "$IGNR" != ""
    then
        IGTBLS=`echo $IGNR | sed 's/,/ /g'`
        for tbl in $IGTBLS
        do
            if test "$tbl" = "$i"
            then
                SKIP=Y
                break
            fi
        done
    fi
    if test $SKIP = Y
    then
        continue
    fi
    echo $p | dialog --backtitle "$TITLE" --gauge "Comparing $i" 10 70 0
    p=$((PCT + p))
    echo -n "$i " > $LOCAL
    $LIB/rowscols.sh -d $DB -t $i >> $LOCAL
    echo -n "$i " > $REMOTE
    ssh -q $REM "$RLIB/rowscols.sh -d $DB -t $i" >> $REMOTE
    if 
        diff -q $LOCAL $REMOTE > /dev/null
    then
        :
    else
        echo "$i unequal" >> $HOME/.cmpstatus
    fi
done
echo 100 | dialog --backtitle "$TITLE" --gauge "Completed" 10 70 0
    
# cleanup
rm -f $HOME/.localtables $HOME/.remotetables
rm -f $HOME/.local-tbls.list $HOME/.remote-tbls.list
sleep 1
