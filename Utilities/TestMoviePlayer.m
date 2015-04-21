Screen('Closeall')
[g_strctStimulusServer.m_hWindow, g_strctStimulusServer.m_aiRect] = Screen(    'OpenWindow',0,[0 0 0],[100 100 500 500]);

%%
moviefile = 'C:\Shay\Data\StimulusSet\MixedStaticMovie\example30fps.mov';
[moviePtr,duration,fps,width,height]=Screen('OpenMovie', g_strctStimulusServer.m_hWindow, moviefile);
fprintf('It took %.1f ms to load the movie header\n',(B-A)*1e3);
framecount = duration * fps;
fprintf('Rough estimate for movie frame count is : %.2f frames\n',framecount);

%fortimeindex = Don't request the next image, but the image closest to time
waitForImage=1;
speed = 1;
loop = 0;
soundvolume = 0; % muted

[droppedframes] = Screen('PlayMovie', moviePtr, speed,loop,soundvolume);

%Screen('SetMovieTimeIndex',moviePtr,0);
% 
% 
% % The 0 - flag means: Don't wait for arrival of new frame, just
% % return a zero or -1 'movietexture' if none is ready.
% [movietexture pts] = Screen('GetMovieImage', win, movie, 0);
A=GetSecs();
tmax = 0;
t=1;
while (1)
    [tex, afTimeRelativeToMovieOnset(t)] = Screen('GetMovieImage', g_strctStimulusServer.m_hWindow, moviePtr,1);
    t=t+1;
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end;
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', g_strctStimulusServer.m_hWindow, tex);

    % Update display:
    Screen('Flip', g_strctStimulusServer.m_hWindow,A+fTimeRelativeToMovieOnset);

    % Release texture:
    Screen('Close', tex);
    
end
   B=GetSecs();
   
   %%
Screen('CloseMovie', moviePtr);
Screen('Close', moviePtr);
    
