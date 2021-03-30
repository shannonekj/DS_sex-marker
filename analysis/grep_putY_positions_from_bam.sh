#!/bin/bash

cd /group/millermrgrp2/shannon/projects/DS_sex-marker/05-putative_y

x=1
n=$(wc -l putative_y.sort.sam | awk '{print $1}')
while [ $x -le $n ]
do
	chr=$(sed -n ${x}p putative_y.sort.sam | awk '{print $3}')
	pos=$(sed -n ${x}p putative_y.sort.sam | awk '{print $4}')
	grep -P \'${chr}"\t"${pos}\' /group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_M_reference/all.counts >> putative_y_rad_depths.counts 
	x=$(( $x + 1 ))
done
