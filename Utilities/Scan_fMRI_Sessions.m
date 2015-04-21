function Scan_fMRI_Sessions(strRoot)
if ~exist('strRoot','var')
    strRoot = 'D:\Data\Doris\MRI\All_Stimulation\';
end

astrctFiles = dir(strRoot);
for k=3:length(astrctFiles) % skip '.' and '..'
    if astrctFiles(k).isdir
        Scan_fMRI_Sessions([strRoot,filesep,astrctFiles(k).name]);
    else 
        [strPath,strFile,strExt]=fileparts(astrctFiles(k).name);
        if strcmpi(strExt,'.mat')
            try
                strctKofiko = load([strRoot,filesep,astrctFiles(k).name]);
                fprintf('%s:\n',strFile)
                bFound = false;
                for i=1:length(strctKofiko.g_astrctAllParadigms)
                    if strcmpi(strctKofiko.g_astrctAllParadigms{i}.m_strName,'fMRI Block Design New')
                        for j=2:length(strctKofiko.g_astrctAllParadigms{i}.Designs.Buffer)
                            fprintf('%s\n',strctKofiko.g_astrctAllParadigms{i}.Designs.Buffer{j}.m_strDesignFileName);
                            bFound = true;
                        end
                    end
                    if strcmpi(strctKofiko.g_astrctAllParadigms{i}.m_strName,'fMRI Block Design')
                        
                        for j=2:length(strctKofiko.g_astrctAllParadigms{i}.ImageList.Buffer)
                            fprintf('%s\n',strctKofiko.g_astrctAllParadigms{i}.ImageList.Buffer{j});
                            bFound = true;
                        end
                        
                    end
                end
                if (~bFound)
                    dbg = 1;
                end
            catch
                fprintf('%s:,  ERROR LOADING FILE !\n',strFile)
            end
            
        end
    end
end


