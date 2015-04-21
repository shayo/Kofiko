#! /bin/csh -f
set inputfile = $argv[1]; shift;
set nominal_EPI_echospacing = $argv[1]; #0.63	#ATTENTION this is the Echo spacing value taken from the sequence tab of the siemens protocol (on the scanner)

set sPat_AccelFactPE = `grep -e "sPat.lAccelFactPE" $inputfile | awk '{split($0, a, "="); print a[2]}'`
set proto_EPI_echospacing = `echo "scale=6; ${nominal_EPI_echospacing} / ${sPat_AccelFactPE}" | bc -l`
set EPI_echospacing = `printf "%01.2f" ${proto_EPI_echospacing}` #0${proto_EPI_echospacing}
echo ${EPI_echospacing}     
