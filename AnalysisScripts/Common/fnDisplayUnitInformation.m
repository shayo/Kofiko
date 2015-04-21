function fnDisplayUnitInformation(ahPanels,strctUnit)
switch strctUnit.m_strParadigm
    case 'Passive Fixation'
        switch strctUnit.m_strImageListDescrip
            case 'Sinha'
                fnDisplaySinhaAnalysis(ahPanels,strctUnit);
            case 'Face Views'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'Faces'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'FOB'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'SinhaFOB'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'SinhaFOB_v2'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'FOB_Pink'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'FacesObjects'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);

        end;

    case 'Classification Image'
        switch strctUnit.m_strImageListDescrip
            case 'FacesObjects'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);
            case 'FOB_Pink'
                fnDisplayFOBAnalysis(ahPanels,strctUnit);

        end;
end;

return;

