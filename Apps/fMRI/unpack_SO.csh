#!/bin/tcsh -ef 

# Load job variables
if ($#argv == 0) then
    if (-e $InputScript)
        source $InputScript
    else
        set data_sub_dir = 111003Houdini
        set year = "/2011"	
        set user_id = `whoami`
        set srcdir = /space/raw_data${year}/dicom_20${data_sub_dir}
        set targdir = /space/data/${user_id}/cooked${year}/${data_sub_dir}
    endif
else
        set srcdir = $1
        set targdir = $2
endif

# Free parameters

set cfg_file = "./CIT_FS_cfg"

if !(-e ${targdir}) then
    mkdir -p ${targdir}
endif
echo "$FREESURFER_HOME/lib/tcltktixblt/bin/tclsh8.4 unpacksdcmdir_SO.tcl -src $srcdir -targ $targdir -seqcfg $cfg_file -fsfast -sphinx"  >/space/data/shayo/fMRI_Scripts/Debug


echo "Unpacking and correcting for sphinx..." 
$FREESURFER_HOME/lib/tcltktixblt/bin/tclsh8.4 unpacksdcmdir_SO.tcl -src $srcdir -targ $targdir -seqcfg $cfg_file -fsfast -sphinx 
echo "Finished unpacking!" 
