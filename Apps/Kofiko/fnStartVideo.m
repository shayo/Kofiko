function fnStartVideo(strDeviceName)
global g_strctAppConfig
if isfield(g_strctAppConfig,'m_hVideoGrabber') && isempty(g_strctAppConfig.m_hVideoGrabber)
    try
        info = imaqhwinfo('winvideo');
        iSelectedSource  = [];
        for k=1:length(info.DeviceInfo)
            if strcmpi(info.DeviceInfo(k).DeviceName,'Rocketfish 2MP AF Webcam')
                iSelectedSource = k;
            end
        end
        if isempty(iSelectedSource)
            g_strctAppConfig.m_hVideoGrabber = [];
            return;
        end
        
        g_strctAppConfig.m_hVideoGrabber = videoinput('winvideo',iSelectedSource,'YUY2_160x120');
        set(g_strctAppConfig.m_hVideoGrabber,'TriggerRepeat',Inf);
        set(g_strctAppConfig.m_hVideoGrabber,'FramesPerTrigger',1)
        triggerconfig(g_strctAppConfig.m_hVideoGrabber, 'Manual')
        start(g_strctAppConfig.m_hVideoGrabber);
    catch
        g_strctAppConfig.m_hVideoGrabber = [];
    end
else
    g_strctAppConfig.m_hVideoGrabber = [];
end
return;