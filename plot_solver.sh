#!/bin/bash

######################### HEADER ########################
gmt set MAP_TITLE_OFFSET 0.1c MAP_LABEL_OFFSET 0.1c
gmt set FONT_ANNOT_PRIMARY 10p,Helvetica MAP_FRAME_PEN 1
gmt set PS_PAGE_ORIENTATION landscape PS_MEDIA a0 PROJ_LENGTH_UNIT cm
gmt set FONT_LABEL 10p,Helvetica
gmt set FONT_TITLE 10p,Helvetica

########## PARAMETERS (FROM fortran code)

dmodel=$1
xmax=$2
zmax=$3
frames=$4
homog=$5
folder=$6
model_name=$7
solver_name=$8
gif_name=$9
cpt_model=${10}
cpt_solver=${11}

########################################################

xmin=0.
zmin=0.
SCALE=$xmax/-$zmax

######### RANGE AND SCALE
RANGE=$xmin/$xmax/$zmin/$zmax
RANGE2=$RANGE
SCALE2=$SCALE
dx=$dmodel
dz=$dmodel

######### PALETS AND MODELS
model=$model_name
modelgrd=$model.grd
pal=$folder/palet_model.cpt

pal2=$folder/palet_solver.cpt
gmt makecpt -C$cpt_solver -T-0.6/0.6/0.001 -Z > $pal2

num=1
while [[ $num -le $frames ]]; do

model2=$solver_name$num.dat
modelgrd2=$model2.grd
psfile=$folder/solver_frame_$num.ps

if [ $frames -ge 10 ] && [ $num -lt 10 ]
then
	psfile=$folder/solver_frame_0$num.ps
fi


gmt psbasemap -Bxf500a1000 -Byf1a2 -By+l"Depth (km)" -BWeS -Jx$SCALE -R$RANGE -V -K > $psfile
gmt psbasemap -Bxf10a5 -Bx+l"Distance (km)" -BN -Jx$SCALE -R$RANGE -V -O -K >> $psfile

if [ $homog -eq 0 ]
then
	#echo "PLOT Model $model"
	gmt xyz2grd $model -G$modelgrd -R$RANGE -I$dx/$dz -V
	gmt grd2cpt $modelgrd -C$cpt_model -I > $pal
	gmt grdimage $modelgrd -C$pal -Jx$SCALE -R$RANGE -V -O -K >> $psfile
	#echo "PLOT Solver $model2"
	gmt xyz2grd $model2 -G$modelgrd2 -R$RANGE2 -I$dx/$dz -V
	gmt grdimage $modelgrd2 -C$pal2 -R$RANGE2 -Jx$SCALE2 -t40 -O -V >> $psfile
	gmt psconvert $psfile -Tj -E600 -A -V -P
fi

if [ $homog -eq 1 ]
then
	#echo "PLOT Solver $model2"
	gmt xyz2grd $model2 -G$modelgrd2 -R$RANGE2 -I$dx/$dz -V
	gmt grdimage $modelgrd2 -C$pal2 -R$RANGE2 -Jx$SCALE2 -O -V >> $psfile
	gmt psconvert $psfile -Tj -E600 -A -V -P
fi

let num+=1

if [ $homog -eq 0 ]
then
	rm $modelgrd
fi

rm $modelgrd2
rm $psfile

done

mogrify -resize 30% $folder/*.jpg
convert -delay 40 -loop 1 $folder/*.jpg $gif_name

if [ $homog -eq 0 ]
then
	rm $pal
fi

rm $folder/*.jpg
rm $pal2

#########################################################################################
