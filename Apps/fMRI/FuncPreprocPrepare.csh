#! /bin/csh -f
#
#
# This is the script that is going to prepare things for the massive parallel submittion
#
#
#

# Load job variables
if ($#argv == 0) then
    source $InputScript
else
    source $1
endif

# declare we started this job...
echo STARTED >$JobFolder/$JobUID.started
# Add the scripts folder to path

####################################################################

set TemplateUndistorted = $TemplateFolder/mocovolu.nii
set TemplateVSMFile  = $TemplateFolder/vsm_fmc.nii
set BrainMaskUndistortedFile = "$MasksFolder/brain_mask.nii"

if ~(-e $TemplateFolder) then
    mkdir -p $TemplateFolder
endif

echo ===================================================================
echo mri_convert -i $Template4D_file -o $Template3DFileFullPath --frame $Template4D_frame
mri_convert -i $Template4D_file -o $Template3DFileFullPath --frame $Template4D_frame

echo ===================================================================

# At this point, we can start submitting all the jobs

# This is just another job that can run in parallel

set TEdiff = `$ScriptsFolder/extractTEdiff.csh $B0_Mag_FullPath-infodump.dat `
set EPI_echospacing = `$ScriptsFolder/extractEPIspacing.csh $Template4D_file-infodump.dat $nominal_EPI_echospacing`


#% epi undistort the template file

echo ===================================================================
echo epidewarp.fsl --mag $B0_Mag_FullPath --dph $B0_Phase_FullPath --exf $Template3DFileFullPath --tediff $TEdiff --esp $EPI_echospacing --vsm $TemplateVSMFile --exfdw $TemplateUndistorted --perev

epidewarp.fsl --mag $B0_Mag_FullPath --dph $B0_Phase_FullPath --exf $Template3DFileFullPath --tediff $TEdiff --esp $EPI_echospacing --vsm $TemplateVSMFile --exfdw $TemplateUndistorted --perev

gunzip -f $TemplateUndistorted.gz


# Generate brain mask
echo Generating brain masks

if ~(-e $MasksFolder) then
    mkdir -p $MasksFolder
endif

echo ===================================================================
echo mkbrainmask -i $TemplateUndistorted -o $BrainMaskUndistortedFile -thresh 0.5 -ndil 2 -nerode 0
mkbrainmask -i $TemplateUndistorted -o $BrainMaskUndistortedFile -thresh 0.5 -ndil 2 -nerode 0


echo ===================================================================

# in case kofiko file was not pased during unpacking, try now again...
# parsekofiko $KofikoFolder
####################################################################


# declare job was finished
echo FINISHED >$JobFolder/$JobUID.finished
