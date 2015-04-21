#! /bin/csh -f
set inputfile = $argv[1]

set TE0 = `grep -e alTE\\\[0\\\] $inputfile | awk '{split($0, a, "=") ;print a[2]}'`
set TE1 = `grep -e alTE\\\[1\\\] $inputfile | awk '{split($0, a, "="); print a[2]}'`
set TEdiff = `echo "scale=6; (${TE1} - ${TE0}) / 1000" | bc -l`
echo $TEdiff
