#!/bin/sh

if [ -z $BASE ] ; then
  echo BASE for mmablib has not been defined
  exit
fi

if [ ! -f makeall.mk ] ; then
  cp ../makeall.mk .
  if [ $? -ne 0 ] ; then
    echo could not find makeall.mk, aborting
    exit 1
  fi
fi

for d in seaice_seaissmi.cd seaice_ssmibufr.fd
do
  cd $d
  make
  cd ..
done
