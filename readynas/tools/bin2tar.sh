#!/bin/bash

# extract the tarball from a ReadyNAS .bin addon 

ARCH=`uname -m`
if [ "${ARCH}" == "padre" ]; then
  BSIZE=512
else
  BSIZE=16384
fi

if [ -f $1 ]; then
  TFIL=`basename $1 .bin`
  TFIL="${TFIL}.tar"
  dd if=$1 of=${TFIL} bs=${BSIZE} skip=1
else
  echo "Add-on file doesn't exist"
fi