#!/bin/bash
#===============================================================================
#
#          FILE:  create_checklist.sh
#
#         USAGE:  ./create_checklist.sh
#
#   DESCRIPTION:
#
#       OPTIONS:  see function HELP below
#       UPDATES:  190321: Added -r and -D options for selecting remote items
#        AUTHOR:  Pete Schmitt (discovery), pschmitt@upenn.edu
#       COMPANY:  University of Pennsylvania
#       VERSION:  0.1.0
#       CREATED:  10/16/2018 11:08:50 EDT
#      REVISION:  Thu Mar 21 19:56:11 EDT 2019
#===============================================================================
SCRIPT=`basename ${BASH_SOURCE[0]}`
BOLD='[1;31m'
REV='[1;32m'
OFF='[0m'
ANS=$HOME/.answer
source $HOME/.hpapdb.cnf
###############################################################################
function HELP {
    echo
    echo -n "${REV}Basic syntax:${OFF} ${BOLD}$SCRIPT -t [table|database]"
    echo " -d <database> -D [local|remote] -r Remote_Host"
    echo
    echo -e "${REV}The following switches are recognized. $OFF "
    echo -e "${REV}-t ${OFF} Type of list, [table | database]"
    echo -e "    Note: if type = table, then -t and -d are required"
    echo -e "${REV}-d ${OFF} database to use for listing tables"
    echo -e "${REV}-D ${OFF} local or remote database to use for listing tables"
    echo -e "${REV}-h ${OFF} Displays this help message."
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
while getopts D:r:t:d:h FLAG
do
    case $FLAG in
        t)
            TYPE="$OPTARG"
            ;;
        d)
            DB="$OPTARG"
            ;;
        D)
            LOC="$OPTARG"
            ;;
        r)
            R="$OPTARG"
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
# Get the list of tables or databases
#
LIST=$HOME/.list

if test "$LOC" = local
then
    if test "$TYPE" = "database"
    then
        $LIB/lsdatabases.sh > $LIST
    elif test "$TYPE" = "table"
    then
        $LIB/lstables.sh $DB > $LIST
    fi

elif test "$LOC" = remote
then
    RHOME=`ssh -q $R pwd`
    RBIN=`ssh -q $R "grep BIN .hpapdb.cnf | cut -f2 -d="`
    RLIB=`ssh -q $R "grep LIB .hpapdb.cnf | cut -f2 -d="`

    if test "$TYPE" = "database"
    then
        ssh -q $R "$RLIB/lsdatabases.sh" > $LIST
    elif test "$TYPE" = "table"
    then
        ssh -q $R "$RLIB/lstables.sh $DB" > $LIST
    fi
fi

################################################################################
#
# Let's create the dialog checklist and run it
#
DLG=$HOME/.dialog
listlen=`wc -l $LIST | cut -f1 -d' '`
num=1
boxheight=$((7+$listlen))

if test "$TYPE" = 'database'
then
    echo 'dialog --backtitle "$TITLE" --radiolist \' > $DLG
    echo -n \"Select database to sync\" $boxheight 50 $listlen '2> ' >> $DLG
else
    echo 'dialog --backtitle "$TITLE" --checklist \' > $DLG
    echo -n \"Select table\(s\) to ignore\" $boxheight 50 $listlen '2> ' >> $DLG
fi
echo -n $ANS >> $DLG
echo ' \' >> $DLG
for i in `cat $LIST`
do
    if test $num -lt $listlen
    then
        echo $num $i off '\' >> $DLG
    else
        echo $num $i off  >> $DLG
    fi
    num=$((num+1))
done

bash $DLG  # run dialog script

sed -i -e '$a\' $ANS   # add EOL to file
answer=`cat $ANS`
# return results
rm -f $HOME/.selected
for i in $answer
do
    head -n $i $LIST | tail -1 >> $HOME/.selected
done
#rm -f $LIST $DLG
