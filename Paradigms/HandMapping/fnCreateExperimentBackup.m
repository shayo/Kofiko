function fnCreateExperimentBackup(g_strctParadigm, command)




global g_strctAppConfig

switch command

	case 'Init'
		g_strctParadigm.backupDirName = [g_strctAppConfig.m_strctDirectories.m_strExperiment_Backup_Folder, g_strctParadigm.m_strPlexonFileName];
		mkdir(g_strctParadigm.backupDirName)
		g_strctParadigm.m_bNewStyleAnalysis = 1;
		save([g_strctAppConfig.m_strctDirectories.m_strExperiment_Backup_Folder,g_strctParadigm.m_strPlexonFileName,'\','ExperimentStimulusVars'],'g_strctParadigm')

	case 'Final'
        try
            save([g_strctAppConfig.m_strctDirectories.m_strExperiment_Backup_Folder,g_strctParadigm.m_strPlexonFileName,'\','ExperimentStimulusVars-Final'],'g_strctParadigm')
        end
    end
return;
