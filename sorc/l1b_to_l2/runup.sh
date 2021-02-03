#!/bin/bash --login
#####
#BSUB -J l2runup
#BSUB -q "dev"
#BSUB -P RTO-T2O
# #BSUB -W 7:59
#BSUB -W 0:09
#BSUB -o l2runup.%J
#BSUB -e l2runup.%J
#BSUB -R "affinity[core(1)]"
#  #BSUB -R "rusage[mem=128]"
#####

#Get a day's SSMIS L1b information and write out with concentration in NetCDF L2
#Robert Grumbine

export PDY=${PDY:-`date +"%Y%m%d"`}
export HH=${HH:-00}
export PM=${PM:-12}
export DCOMROOT=/u/Robert.Grumbine/noscrub/legacy/
export RGTAG=prod
export EXDIR=/u/Robert.Grumbine/rgdev/concentration/sorc/l1b_to_l2/
export OUTDIR=/u/Robert.Grumbine/noscrub/l2

module load EnvVars/1.0.3 ips/19.0.5.281 impi/19.0.5
module load bufr/11.3.1 NetCDF/4.5.0 w3nco/2.2.0
module load dumpjb/5.1.0 bufr_dumplist/2.3.0

export PDY=20181230

x=$$
mkdir -p /gpfs/dell2/ptmp/wx21rg/runup.$x
cd /gpfs/dell2/ptmp/wx21rg/runup.$x

set -x
while [ $PDY -le 20181231 ]
do

  export DCOM=${DCOMROOT}/$RGTAG/$PDY

  time ${EXDIR}/getday_ssmis.sh

  PDY=`expr $PDY + 1`
  PDY=`/u/Robert.Grumbine/bin/dtgfix3 $PDY`
done
rm -r /gpfs/dell2/ptmp/wx21rg/runup.$x
#ls -l /gpfs/dell2/ptmp/wx21rg/runup.$x