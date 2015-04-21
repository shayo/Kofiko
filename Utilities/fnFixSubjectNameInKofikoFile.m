clear all
strFileName ='D:\Data\Doris\Electrophys\Bert\Optogenetics\120814\RAW\120814_100438_Bert.mat';
load(strFileName);
g_strctAppConfig.m_strctSubject.m_strName = 'Bert';
save(strFileName,'g_strctAppConfig','-append');
             