#! /bin/csh -f


# Load job variables
if ($#argv == 0) then
    source $InputScript
else
    source $1
endif

# declare we started this job...
echo STARTED >$JobFolder/$JobUID.started

###########################################################


goto set_filenames_start
set_filenames_end:

goto motion_correction_start
motion_correction_end:

goto B0_dewarp_start
B0_dewarp_end:

goto SpatialSmoothing_start
SpatialSmoothing_end:

goto IntensityNormalization_start
IntensityNormalization_end:

goto finish_pipeline


###########################################################

finish_pipeline:
echo ------------------------------------------
echo Finished processing run

# declare job was finished
echo FINISHED >$JobFolder/$JobUID.finished

exit 0;






#############################################################
set_filenames_start:

set InputFileInfoFullPath =  $InputFileFullPath-infodump.dat

set MotionParametersFile =  $InputFolder/$Subfolder_BOLD/$Seq/fmc.mcdat
set MotionParametersFile6D = $InputFolder/$Subfolder_BOLD/$Seq/mcextreg
set MotionCorrectedEPI =  $InputFolder/$Subfolder_BOLD/$Seq/fmc.nii

set B0_InfoFile = ${B0_Mag_FullPath}-infodump.dat
set MotionCorrectedUnwarpFile = $InputFolder/$Subfolder_BOLD/$Seq/fmcu.nii
set MotionCorrectedUnwarpVSMFile = $InputFolder/$Subfolder_BOLD/$Seq/vsm_fmc.nii

set MotionCorrectedEPI_Smooth =  $InputFolder/$Subfolder_BOLD/$Seq/fmcs.nii
set MotionCorrectedUnwarpSmoothFile =  $InputFolder/$Subfolder_BOLD/$Seq/fmcus.nii

goto  set_filenames_end
#############################################################







#############################################################

motion_correction_start:

echo Starting motion correction stage

# Step 1: Motion correction

echo mc-afni2 --i $InputFileFullPath --t $Template3DFileFullPath --frame 0 --o $MotionCorrectedEPI --mcdat $MotionParametersFile

mc-afni2 --i $InputFileFullPath --t $Template3DFileFullPath --frame 0 --o $MotionCorrectedEPI --mcdat $MotionParametersFile
$ScriptsFolder/mcparams2extreg_exe $MotionParametersFile $MotionParametersFile6D

goto motion_correction_end



#############################################################

B0_dewarp_start:


echo Starting B0 dewarping stage

goto extract_b0_values_start
extract_b0_values_end:

epidewarp.fsl --mag $B0_Mag_FullPath --dph $B0_Phase_FullPath --exf $MotionCorrectedEPI --tediff $TEdiff --esp $EPI_echospacing --vsm $MotionCorrectedUnwarpVSMFile --exfdw $MotionCorrectedUnwarpFile --perev

if (-e $MotionCorrectedUnwarpFile.gz) then
   gunzip -f $MotionCorrectedUnwarpFile.gz
endif

goto  B0_dewarp_end

##
extract_b0_values_start:

set TEdiff = `$ScriptsFolder/extractTEdiff.csh $B0_InfoFile `
set EPI_echospacing = `$ScriptsFolder/extractEPIspacing.csh $InputFileInfoFullPath $EPI_Echo_Spacing`

goto extract_b0_values_end

#############################################################


IntensityNormalization_start:
echo Starting Intensity mean computation

# TODO: parallelize this ?
$ScriptsFolder/inorm2_exe $MotionCorrectedEPI 0
$ScriptsFolder/inorm2_exe $MotionCorrectedUnwarpFile 0
$ScriptsFolder/inorm2_exe $MotionCorrectedEPI_Smooth 0
$ScriptsFolder/inorm2_exe $MotionCorrectedUnwarpSmoothFile 0

goto IntensityNormalization_end

#############################################################
SpatialSmoothing_start:

# TOO: parallelize this ?
echo Starting Spatial smoothing stage
echo Outputs going to be in $MotionCorrectedEPI_Smooth

mri_fwhm --i $MotionCorrectedEPI --o $MotionCorrectedEPI_Smooth --smooth-only --fwhm $Smoothing_FWHM
mri_fwhm --i $MotionCorrectedUnwarpFile --o $MotionCorrectedUnwarpSmoothFile --smooth-only --fwhm $Smoothing_FWHM


goto SpatialSmoothing_end


#############################################################
