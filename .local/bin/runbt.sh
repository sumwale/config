#!/bin/sh

#
# Usage: runbt.sh [-l <local.conf path>] <other options> <bt path>
#
# SNAPPY_SOURCE can be set before running the script to point to non-default snappydata checkout.
#
# Default local.conf is local.conf in PWD or else sql/snappy.local.conf from store SQL test suite.
# Output directory is current directory.
#

if [ -z "$SNAPPY_SOURCE" ]; then
  SNAPPY_SOURCE=$HOME/product/SnappyData/snappydata
  export JTESTS=$SNAPPY_SOURCE/store/tests/sql/build-artifacts/linux/classes/main
fi

outputDir="`pwd`"
localConf=$JTESTS/sql/snappy.local.conf
if [ "$1" = "-l" ]; then
  shift
  localConf=$1
  shift
elif [ -r local.conf ]; then
  localConf="`pwd`/local.conf"
fi

$SNAPPY_SOURCE/store/tests/core/src/main/java/bin/sample-runbt.sh $outputDir $SNAPPY_SOURCE -d false -l $localConf "$@"
