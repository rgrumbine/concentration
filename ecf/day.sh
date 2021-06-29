#!/bin/bash --login

tag=20210323
export tag=${tag:-`date +"%Y%m%d"`}
tagm=`expr $tag - 1`
export tagm=`/u/Robert.Grumbine/bin/dtgfix3 $tagm`
export end=$tag
echo initial tag date = $tag

#-----------------------------------------------------------------------------
set -e
echo zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz loading modules zzzzzzzzzzzzzzzzzzzzzzz
#acorn
  source /apps/prod/lmodules/startLmod

#. /usrx/local/Modules/3.2.10/init/bash
module purge
#acorn
module load envvar/1.0
module load PrgEnv-intel
module load intel/19.1.3.304
module load intel/19.1.3.304/cray-mpich/8.1.4
module load prod_util/2.0.3
module load w3nco/2.4.1
module load w3emc/2.7.3
module load bacio bufr g2
module load libpng/1.6.37
module load zlib/1.2.11
module load jasper/2.0.16
module load netcdf/4.7.4
module load imagemagick
#wcoss
#module load ips/19.0.5.281 impi/19.0.5
#module load prod_envir/1.1.0
#module load prod_util/1.1.5 
#module load grib_util/1.1.1
#module load bufr_dumplist/2.3.0
#module load dumpjb/5.1.0

module list
echo zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz done loading modules zzzzzzzzzzzzzzzzzz

set -xe

# Bring the various environment-sensitive definitions out of J jobs and to here:
#NCO refers to these as 'job card' variables

export HOMEbase=/u/Robert.Grumbine/rgdev
export seaice_analysis_ver=v4.4.0
export HOMEseaice_analysis=$HOMEbase/seaice_analysis.${seaice_analysis_ver}

cd $HOMEseaice_analysis/ecf/
. ./jobcards
echo $jlogfile $DATA $cyc $cycle
echo date pdy= $PDY ncepdate = $ncepdate


echo date before obsproc: $PDY
if [ -z $obsproc_dump_ver ] ; then
  echo null obsproc_dump_ver
  export obsproc_dump_ver=v4.0.0
  export obsproc_shared_bufr_dumplist_ver=v1.4.0
fi
echo tag = $tag date after obsproc: $PDY

#--------------------------------------------------------------------------------------
#The actual running of stuff

while [ $tag -le $end ]
do
  export PDY=$tag
  export PDYm1=$tagm
  echo dates: tag= $tag PDY = $PDY

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
  tag=`/u/Robert.Grumbine/bin/dtgfix3 $tag`

done
