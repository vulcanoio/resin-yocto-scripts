#!/bin/bash

#
# conf-notes.txt generator
# ------------------------
#
# Signed-off-by: Theodor Gherzan <theodor@resin.io>
# Signed-off-by: Andrei Gherzan <andrei@resin.io>
# Signed-off-by: Florin Sarbu <florin@resin.io>
#

CONF=$1             # CONFNAME file directory location
CONFNAME="conf-notes.txt"

# The conf directory is yocto version specific
CONF=$CONF/samples

# Checks

if [ $# -lt 2 ]; then
    echo -e 'Usage:\n'
    echo -e "./generate-conf-notes.sh ./path/to/meta-resin-<target>/conf/ <json1> <json2> ...\n"
    exit 0
fi

for json in "${@:2}"; do
    if [ ! -f $json ]; then
      echo -e "File $json does not exist. Exiting!\n"
      exit 1
    fi
done

if ! `which jq > /dev/null 2>&1` || [ -z $CONF ] || [ ! -d $CONF ]; then
    exit 1
fi

echo -e "
  _____           _         _       
 |  __ \         (_)       (_)      
 | |__) |___  ___ _ _ __    _  ___  
 |  _  // _ \/ __| | '_ \  | |/ _ \ 
 | | \ \  __/\__ \ | | | |_| | (_) |
 |_|  \_\___||___/_|_| |_(_)_|\___/ 
                                    
 ---------------------------------- \n" > $CONF/$CONFNAME

IMAGES=""
BOARDS_COMMANDS=""

for json in "${@:2}"; do
    IMAGE=`cat $json | jq  -r '.yocto.image | select( . != null)'`
    IMAGES="$IMAGES $IMAGE"
    NAME=`cat $json | jq  -r '.name'`
    MACHINE=`cat $json | jq  -r '.yocto.machine'`
    BOARD_COMMAND=$(printf "%-35s : %s\n" "$NAME" "\$ MACHINE=$MACHINE bitbake $IMAGE")
    if [ -z "$BOARDS_COMMANDS" ]; then
        BOARDS_COMMANDS="$BOARD_COMMAND"
    else
        BOARDS_COMMANDS="$BOARDS_COMMANDS\n$BOARD_COMMAND"
    fi
done

# Unique images
IMAGES=`echo $IMAGES | tr ' ' '\n' | sort -u`

# Write conf file
echo "Resin specific targets are:" >> $CONF/$CONFNAME
for image in $IMAGES; do
    echo -e "\t$image" >> $CONF/$CONFNAME
done
echo >> $CONF/$CONFNAME
echo -e "$BOARDS_COMMANDS" >> $CONF/$CONFNAME
echo >> $CONF/$CONFNAME
