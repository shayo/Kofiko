% assume this is called from root scripts folder

cd FuncPreproc
mkdir inorm2_proj/src
mcc -o inorm2_exe -W main:inorm2_exe -T link:exe -d inorm2_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v inorm2_exe.m 
movefile inorm2_proj/src/inorm2_exe .



% mcc -o mcparams2extreg_exe -W main:mcparams2extreg_exe -T link:exe -d /home/helios/data/shayo/cooked/2010/101225Houdini_MyScripts/mcparams2extreg_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v /home/helios/data/shayo/cooked/2010/101225Houdini_MyScripts/mcparams2extreg_exe.m 


mkdir mcparams2extreg_proj/src
mcc -o mcparams2extreg_exe -W main:mcparams2extreg_exe -T link:exe -d mcparams2extreg_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v mcparams2extreg_exe.m 
movefile mcparams2extreg_proj/src/mcparams2extreg_exe .
cd ..



cd ParseKofiko
mkdir parsekofiko_proj/src
mcc -o parsekofiko -W main:parsekofiko -T link:exe -d parsekofiko_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v fnParseKofiko.m 
movefile parsekofiko_proj/src/parsekofiko .
cd ..
