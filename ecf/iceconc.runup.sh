#!/bin/bash --login
#####
#BSUB -J aice_2021
#BSUB -q "dev"
#BSUB -P RTO-T2O
#BSUB -W 2:59
# #BSUB -W 0:09
#BSUB -o aice.%J
#BSUB -e aice.%J
#BSUB -R "affinity[core(1)]"
#  #BSUB -R "rusage[mem=1024]"
#####


#set -e
#debug env > env.10 2> env.20
#acorn
    source /apps/prod/lmodules/startLmod
#-----------------------------------------------------------------------------
echo zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz loading modules zzzzzzzzzzzzzzzzzzzzzzz
module purge
#phase3
#module load EnvVars/1.0.3
#module load ips/19.0.5.281 impi/19.0.5
#module load prod_envir/1.1.0
#module load prod_util/1.1.5
#module load grib_util/1.1.1
#module load bufr_dumplist/2.3.0
#module load dumpjb/5.1.0
#module load imagemagick/6.9.9-25
#module load lsf/10.1 #for internal job management, i.e., bkill
#acorn
    module load envvar/1.0
    module load PrgEnv-intel
    module load intel/19.1.3.304
    module load intel/19.1.3.304/cray-mpich/8.1.4
    module load prod_envir
    module load prod_util
    #module load bacio bufr g2
    #module load libpng/1.6.37
    #module load zlib/1.2.11
    #module load jasper/2.0.16
    module load netcdf/4.7.4

module list
echo zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz done loading modules zzzzzzzzzzzzzzzzzz

# Bring the various environment-sensitive definitions out of J jobs and to here:
#NCO refers to these as 'job card' variables
#set -xe
set -x

tagm=20210324
tag=20210325
end=20210325

export HOMEbase=/u/Robert.Grumbine/rgdev
export seaice_analysis_ver=v4.4.0
export HOMEseaice_analysis=$HOMEbase/seaice_analysis.${seaice_analysis_ver}

#Use this to override system in favor of my archive:
export DCOMROOT=/u/Robert.Grumbine/save/dcom
export RGTAG=""
export my_archive=true

cd $HOMEseaice_analysis/ecf

export COMINsst_base=/u/Robert.Grumbine/save/sst/prod/sst
#debug env > env.1 2> env.2
. ./jobcards
#debug env > env.1b 2> env.2b

if [ -z $obsproc_dump_ver ] ; then
  echo null obsproc_dump_ver
  export obsproc_dump_ver=v4.0.0
  export obsproc_shared_bufr_dumplist_ver=v1.4.0
fi

########################################################
#DBN stuff -- now in jobcards
########################################################

#--------------------------------------------------------------------------------------
#The actual running of stuff

while [ $tag -le $end ]
do
  export PDY=$tag
  export PDYm1=$tagm

  if [ $my_archive == "true" ] ; then
    export DCOM=${DCOMROOT}/$RGTAG/$PDY
  fi

  export job=seaice_filter
  export DATA=$DATAROOT/${job}.${pid}
  #script handles make: mkdir $DATA
  time ./sms.filter.fake > /u/Robert.Grumbine/noscrub/com/sms.filter.$tag

  export job=seaice_analysis
  export DATA=$DATAROOT/${job}.${pid}
  #script handles make: mkdir $DATA
#Required for dumpjb to run:
  export TMPDIR=$DATA
  time ./sms.fake > /u/Robert.Grumbine/noscrub/com/sms.$tag

#  module load gempak
#  time ../jobs/JICE_GEMPAK > gempak.$tag

  tagm=$tag
  tag=`expr $tag + 1`
  tag=`dtgfix3 $tag`

done
