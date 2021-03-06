#!/bin/bash
alienv printenv FairShip/latest >> ./config.sh
source config.sh
echo `klist`
set -ux
echo "Starting script."
DIR=$1
ProcId=$2
LSB_JOBINDEX=$((ProcId+1))
MUONS=$4
NTOTAL=$5
NJOBS=$3
EOS_DIR=$6
MAGNET_GEO=$7
MUSHIELD=8
N=$(( NTOTAL/NJOBS + ( LSB_JOBINDEX == NJOBS ? NTOTAL % NJOBS : 0 ) ))
FIRST=$(((NTOTAL/NJOBS)*(LSB_JOBINDEX-1)))
if xrdfs root://eospublic.cern.ch/ stat "$EOS_DIR"/"$DIR"/"$LSB_JOBINDEX"/ship.conical.MuonBack-TGeant4.root; then
	echo "Target exists, nothing to do."
	exit 0
else
	python "$FAIRSHIP"/macro/run_simScript.py --muShieldDesign $MUSHIELD --MuonBack --nEvents $N --firstEvent $FIRST -f $MUONS --FollowMuon --FastMuon -g $MAGNET_GEO --stepMuonShield --tankDesign 6 --nuTauTargetDesign 3
	xrdcp ship.conical.MuonBack-TGeant4.root root://eospublic.cern.ch/"$EOS_DIR"/"$DIR"/"$LSB_JOBINDEX"/ship.conical.MuonBack-TGeant4.root
	if [ "$LSB_JOBINDEX" -eq 1 ]; then
		xrdcp geofile_full.conical.MuonBack-TGeant4.root\
        root://eospublic.cern.ch/"$EOS_DIR"/"$DIR"/geofile_full.conical.MuonBack-TGeant4.root
	fi
fi

