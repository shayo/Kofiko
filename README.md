# Kofiko Tutorial Getting started
#### Meyer 2015
https://github.com/ninehundred1


Kofiko allows you to run the Matlab Psychotoolbox within a wrapper for easy generation of new paradigms. 
Below is a guide how to set up Kofiko to work with a touchscreen and how to modify the paradigms. You need two screens in this tutorial, the right screen needs a lower resolution (as does the touch screen if you want to run it this way). The left screen is a direct mirror of the touch screen. Additionally to that there are also GUI elements that allow for different settings. As those elements need screen size, the left (experimentator) screen needs to be wider in the number of pixes. It is also possible to connect to computers, which we are not doing here.
You would also need hardware connected to handle the giving of a reward, turning on of an LED or whatnot you like to add. You can use different devices, including an Ardunio. Look in the manual for more info on that.

When done, it should look like this (right is what the animal sees, left what the experimentor sees).


![alt text](http://i.imgur.com/5LiBlrD.jpg "Kofiko")

Kofiko is made by Shay Ohayon, California Institute of Technology. 

# PART1 - SETTING UP
These 5 steps below need to be done just to get Kofiko working.
I have not tried newer matlab than 2012, so not sure that works. Also we use 32 bit matlab 2009-2012 (64 will not work with the current mex files it seems). If you only have 64bit matlab (go to the folder where matlab is installed **(eg C:\ProgramFiles\MATLAB\R2012a32bit\bin\)** and see if there is a folder win32. If there is only win64, you need to download the 32bit version of Matlab. Go to the mathworks website, enter your info and then look for previous versions and install the 32bit of matlab 2012.

### 1. Download Kofiko.
Now you have two options:
A. if you want to do the whole tutorial,
download the original zip from here:
https://github.com/shayo/Kofiko
or clone using git:
>git clone https://github.com/shayo/Kofiko

if that file it not available anymore, use the *original* branch here
https://github.com/ninehundred1/Kofiko/tree/original


B. if you want to just set it up to work the way it does here but not go into details, download the current working Version from here

https://github.com/ninehundred1/Kofiko/tree/tutorial

In either case, unzip the file you downloaded, this is the whole of Kofiko.

### 2. Make a new environment variable in windows
go to the windows task bar and click *start-control panel-system and security-system-
advanced system settings-environment variable*, then on the bottom click new.. and type in a new name: 

>MATLAB32BIN

and the value needs to be the path to the 32bit MATLAB.exe, for example

>C:\Program Files\MATLAB\R2012a32bit\bin\win32\MATLAB.exe

this path might be different on your computer. 
then click ok.


### 3. Install Psychtoolbox-3
Download Psychtoolbox from here (follow steps 1-6)
http://psychtoolbox.org/download/#Windows



### 4. Update the config files. 
Go to the folder
**Kofiko\Config\KofikoConfigForDifferentRigs**

**A.** Open Default.xml in notepad (right click then *edit*) and change the directory for the *LogFolder* to your own log folder (make a new folder called Log somewhere and enter the path here, that is where the logs of the pogram and the timestamp data will be saved for each experiment).
Then change the path of *PTB_Folder* to where your Psychtoolbox got installed (likely C:\toolbox\Psychtoolbox\). Change *SingleComputerMode*  to "1" and then save file.

**B.** Open TouchScreen.xml in notepad and change the same things as above (this is the mode we will use to try out Kofiko) and also change AudioDeviceName to "Primary Sound Driver" to avoid an error (we need to reset that later to some other soundcard) save file under a new name using quotations ("") and .xml ending, otherwise it will save as .txt.(eg "TouchScreen_try.xml")


### 5. Start Kofiko
To start Kofiko, there is a bat file (*Run_KOFIKO.bat*) in the Kofiko folder, which you can either start from the terminal or just double click the file name. It will start matlab, set matlabs directory to the current directory and start the file RegisterGUI. 

**This should be all to get Kofiko running and installed.**

### Not starting
in the case you click Start Kofiko! and it does nothing but print *Data saved!* in the Matlab Command Window it usually means that you did not connect (or correctly set up) the hardware interface. Look at the xml file in the config folder (see 4.) and this section and make sure you set the right names, etc:

><DAQ

>VirtualDAQ = "1"

>AcqusitionCard = "arduino"

>AcqusitionCardBoard = "0"



# Modifying Kofiko
Now below are examples to modify Kofiko to your needs with a touch screen in this example.

The contents of the file Run_KOFIKO.bat are:

**start "Kofiko" "%MATLAB32BIN%" -nosplash -r "addpath(genpath(pwd())); RegisterGUI"**

this file does this:
1. set the window title to 'kofiko'
2. start matlab (environment variable name is MATLAB32BIN, which links to the location of matlab.exe)
3. -nosplash is to not show matlab splash screen
4. -r is extra stuff (addpath adds the current folder to the matlab directory, RegisterGUI is the m file that gets executed when matlab opens).

when RegisterGUI is called it opens a GUI, from where everything else gets executed within Matlab. 

When the GUI called RegisterGUI is on the screen, select a picture/profile, then use **TouchScreen_try** (or the name you gave the xml file just above) as the Rig Specific configuration file and click **Start Kofiko!**

A window will appear asking to Start a plexon recording file, just click Ok.


Now the PsychoToolbox should start up and you should see an image of a monkey. The left screen is the experimentor screen, which shows on the left side what the monkey sees, also including statistics (number of trials, etc), on the right of the left screen are GUI settings. 
To be able to activate the mouse, move the cursor down to the task bar on the bottom of the screen, hover it over the matlab icon and click the window *PBT Onscreen Window*.

Now you can move the cursor up back to the settings and change Paradim to Touchscreen training and click start.

This should then get you the default touch training mode, where on the right you have what the monkey sees, on the left what the experimentor sees. The goal is to touch the white circle to get a reward. Move the mouse all the way to one side (right) until it comes out the other screen on the left and it now should leave a trail on the Kofiko machine (the left screen is run by the kofiko machine and is what the experimentor sees, the right screen is what is on the touch screen and what the monkey sees, also called the stimulus server). This trail is supposed to be the eye tracking of the monkey eye, but as we use it in touchscreen mode it is where the touchscreen is touched.
If you use the mouse, whenever the mouse xy coordinates change, that is considered a touch. As would be the case if you drag your finger over the screen without ever lifting it. So if the mouse is not within the circle and is moved, the first pixel it moves to is considered the input, so very unlikely will you make it into the circle.
When done, close the window (press the small x top right on the Kofiko machine (the left screen, the one with the buttons)).

This is the out of the box working of Kofiko.


# Setup your own paradigm


Now you can start to create your own pradigm. Go to the documents folder and read through the **manual.doc** file. That's the manual for the old version of Kofiko, but it should get you some more information. 

What basically happens is that Kofiko will run its main program, where it will run a series of functions, which can be modified with your stuff. There are 9 main functions that will be used by Kofiko (all have the same name of YourParadigmX where X is what the function does (eg draw, gui, cycle, etc), so keep the same  
name system (change YourParadigm, keep the last part).
For example, Kofiko will start by using the *init* function, then generate a user interface (the right side of the left screen with all the sliders, etc) based on what you put in the *GUI* function. Kofiko will then follow the procedure (show stimulus, wait, give reward, play sound, etc) depending on what you put in the *Cycle* 
function. It will show the stimulus depending on what you put in the *Draw* function, etc. 

In the Documents folder open the **NewParadigmProtocol.doc** file.
This file tells you in detail what needs to be done to set up a new paradigm with your own settings and stimuli. It will show you the sequence of when what function is called and what Kofiko requires to keep working.
In our case the Stimulus server and the Kofiko machine are the same (but we now refer the left experimentator screen as *Kofiko machine*, the right touch screen as *stimulus server*). You can run it in a mode where you have a second computer that just shows the stimulus (which would then be the Stimulus server), but we use the same computer, just with a second screen (the touch screen).
Read through the doc file and get an idea what is needed. 

#### Copy files
Now start making your own paradigm. Make a copy of the folder *TouchScreenTraining* (in TouchParadimgs) and name it whatever you want (eg *TouchImageTraining*). Then you need to rename each of the function (replace *Screen* with *Image*) to eg *fnParadigmTouchImageTrainingCallbacks.m* and 
*fnParadigmTouchImageTrainingClose.m* etc.
This will get you your own copy of files and you can always check with the originals if something screws up.


Next go to the folder **Kofiko\Config\KofikoConfigForDifferentRigs** open the *Touchscreen.xml* file in notepad and save it (using " signs) as what your paradigm is called eg *"TouchImageTraining.xml"*.
This will create the config file that you can load when starting Kofiko.

Check the entries for *LogFolder*, *PTB_Folder* (those you should have already changed before, so should be fine). Then go down to  **<Paradigm Name = "Touch Screen Training"**. Copy everything between (and including) the block **"<Paradigm Name"** and **"> </Paradigm>"** (there are more than one, take only the smallest 
block) and paste it  before  **"<Paradigm Name = "Touch Force Choice""**.
Then change the name *Touch Screen Training* to what you want (eg *Touch Image Training*). This is the protocol you will modify.


Next change all the functions to your new functions you created above, so Kofiko will call your fuctions, not the old ones. So change for example **Callbacks =  
"fnParadigmTouchScreenCallbacks"** to **Callbacks = "fnTouchImageTrainingCallbacks"**, so now Kofiko knows when it  
wants to call Callbacks to not use the *TouchScreen* function, but your function (eg *TouchImageTraining*). 

There are a total of 9 function names to change.


Save the file and then run Kofiko again (double click *Run_KOFIKO.bat*), you might have to exit matlab before, so it will read the new file with your added paradigm. When the window with the images appears there should now be the option to select your xml file (eg *TouchImageTraining*)

Then the other windows should show up. Again go hover the mouse of the matlab symbol and click *PBT Onscreen Window* to activate the window. Then go to Paradigm and select your Touch Image Training paradigm and run it.

It should work just as before.

When done, close the window (press the small x top right on the Kofiko machine (left screen, the one with the buttons).
Now you know how to make and run your own paradigm, and now you can start to change it. All changes will be made in this config file (we now call it **TouchImageTraining**) and will modify the paradigm **Touch Image Training** inside of it (same name, but the way it is made that you have the one top level config file with many different paradigms inside of it.



# Changing the paradigm 
Let's start to change things. ALl changes are now made in our new folder *Kofiko\Paradigms\TouchParadigms\TouchImageTraining* and on the new functions we copied and renamed.
If you read the **NewParadigmProtocol.doc** file you have a rough idea what each of the function is responsible for. 

#### Fix spot position
The first thing we change is to stop the round white circle from randomly moving around but moving it to the bottom of the screen in a fixed position. We can also change the color to green.

Open the file **fnParadigmTouchImageCycle.m** which is basically the main function of kofiko (there is a drawCycle function also, which is related to the draw function).

Int the imageCycle function you can see the different cases (or MachineStates) that Kofiko can carry out. If Kofiko moves into state 4, there will be dot shown on the screen, if it moves to state 7, wait for the money to stop touching the screen, etc.


We want to change where the position of the circle is defined, so we are interested in state 1. This is not the actual state where the circle is shown (that is done in state 4), but here the new position of the circle is already set, so later the circle can be shown without delay.

The section that defines where the circle is shown is here and these are steps that are done for a random placement:

1. get the screen size of the screen (so we know where the borders are)

    % Set Next Touch Position
    aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');


2. get the value for the size of the spot (we set that in the config file)   
    

    fSpotSizePix = fnTsGetVar(g_strctParadigm,'SpotRadius');


3. calculate a new pixel position by taking the spot size and then adding a random portion of the screen length (or height), where the spot size has been distracted. So in the case of the screen being 1000 pixels wide, you add a random % of that (eg 0.2 * 1000 gets you pixel number 200). rand return a random value from 0.0 to 1.0 (eg 0.2). You need to make the screen slightly smaller to allow for the circle to fit (spotsizepix), so the circle is not half cut off. You do the same for x and y.


    fSpotX = fSpotSizePix + rand()*(aiStimulusScreenSize(3)-2*fSpotSizePix);
    fSpotY = fSpotSizePix + rand()*(aiStimulusScreenSize(4)-2*fSpotSizePix);
   
4. Now you just need to update the variables with the new x and y position.


    g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos = [fSpotX,fSpotY];
    g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = fSpotSizePix;



As we don't want it to be displayed at a random position, we need to remove the rand multiplier. It is a good idea to make the position dependend on the screen size (20% of screen) rather than using absolute values (pixel 800), so we are flexible with different screen sizes.

So we will replace rand with 0.2 in x and 0.8 in y (pixel 0,0 is the top left) to show the dot in the bottom left corner (20% of x and 80% of y).

So now go ahead and change the lines to this:

      fSpotX = fSpotSizePix + 0.2*(aiStimulusScreenSize(3)-2*fSpotSizePix);
        fSpotY = fSpotSizePix + 0.8*(aiStimulusScreenSize(4)-2*fSpotSizePix);


We can now see what we get by again running Kofiko (if the RegisterGUI is still open, just click Start Kofiko! again, otherwise restart by **Run_KOFIKO.bat** and choose our
configuration **TouchImageTraining** when starting, then after we hovered over the matlab icon and activate *PBT Onscreen Window* we choose **Touch Image Training** as the paradigm.

Now we should be able to catch the dot and get some rewards, as we know where it will show up.

When done, close the window (press the small x top right on the Kofiko machine (left screen, the one with the buttons).


#### Change color of dot
Now let's change the dot into a square. If you look through the function it seems that the part that actually shows the spot is this (in bold):

      % Send a command to display the spot on the stimulus server
          fFlipTime = fnDrawSpotOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos, ...
                                     g_strctParadigm.m_strctCurrentTrial.m_fSpotRad,[255 255 255]);


Namely, **fnDrawSpotOnStimulusScreen**.

We can see that this is a user function and it is actually defined at the bottom of the matlab file. The part that does the actual drawing of the dot is 

    Screen(g_strctStimulusServer.m_hWindow,'FillArc',aiColor, aiTouchSpotRect,0,360);

If you look into the [documentation for Screen() in the Psychotoolbox](http://docs.psychtoolbox.org/FillArc), you can see that is has this template:

>Screen('FillArc',windowPtr,[color],[rect],startAngle,arcAngle)

Now if we want to change the color of the dot, all we need to do is change the [color] triplet (*aiColor*) in this file, which is passed into the function when called. So to change the color, we go to the point where the function is called (also see right above) and we can see the color triplet that is passed in is **[255 255 255]**. 

In the matlab file we go back up again to where the function is called (*case 4*) and change in the line 

     % Send a command to display the spot on the stimulus server
          fFlipTime = fnDrawSpotOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos, ...
                                     g_strctParadigm.m_strctCurrentTrial.m_fSpotRad,[255 255 255]);

the color triple [255 255 255], which is white, to [255 0 0], which is red. We save the matlab file and press *Start Kofiko* again, catch the dot and when done, close the window (press the small x top right on the Kofiko machine (left screen, the one with the buttons).

http://docs.psychtoolbox.org/FillRect




## PART2
#### Add second dot

Now we add a second dot in a green color. As above, we want to look where the current red circle is defined in position, and there we add a second position for the second circle. We need to do that for both, the Kofiko Machine (what the experimentor sees, or the Draw.m file) and for the Stimlus Server (what the monkey sees, so the touch screen or the Cycle.m file).


##### Stimulus server (Cycle file)
Go to **fnParadigmTouchImageCycle.m** and **state 1** (case 1).

As with the first spot, the coordinates for display are stored here:

    g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos 
    
We keep everything for the first spot, but change the name to

    g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green
    
Now for the second spot we want the same size of the spot and the same height, just a different side (x) position, so we just need to modify fSpotx, moving the spot to the bottom right.

So the modified section now looks like this:

    fSpotSizePix = fnTsGetVar(g_strctParadigm,'SpotRadius');
        %set first spot position
        fSpotX = fSpotSizePix +     0.2*(aiStimulusScreenSize(3)-2*fSpotSizePix);
        fSpotY = fSpotSizePix + 0.8*(aiStimulusScreenSize(4)-2*fSpotSizePix);
        %update spot 1 position and size in structure 
        g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = fSpotSizePix;
        g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green = [fSpotX,fSpotY];
        %change x for the second spot
        fSpotX = fSpotSizePix + 0.8*(aiStimulusScreenSize(3)-2*fSpotSizePix);
        %update spot 2 position and size in structure 
        g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = fSpotSizePix;
        g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red = [fSpotX,fSpotY];


As now the old name *m_pt2fSpotPos* has changed to *m_pt2fSpotPos_Green* we need to make sure that those two spots are handles correctly in the dependent functions.


The first one is within the same file the section of **state/case 4**.
The part that displays the spot is the function 

    fFlipTime = fnDrawSpotOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos, ...
                                     g_strctParadigm.m_strctCurrentTrial.m_fSpotRad,[255 255 255]);

This is a user function that is defined at the bottom of the file. It returns fFlipTime which is a timestamp of the time a small rectangle is shown. You can connect a small light reader to the screen and measure when the rectangle is shown, independent of this whole program. Then you can later on align the time the rectangle is shown with the timestamp value of fFlipTime and then precisely find out when the monkey was shown the image. 
We will leave this in, though it is not necessary to have yet.

What we need to do is adapt that user function *fnDrawSpotOnStimulusScreen* to show two dots instead of one.
So go all the way to the bottom, copy the function *fnDrawSpotOnStimulusScreen* and past it below and rename it to **fnDrawTwoSpotsOnStimulusScreen**. The parameters this function takes are the 1. position of spot, 2. size of spot, 3. color triplet.
To adjust it for two spots we need to add a second 1 and 3 for our second spot (the size we keep the same).
So change the parameters to 

    fnDrawTwoSpotsOnStimulusScreen(pt2iSpot_A,pt2iSpot_B, fSpotSizePix,aiColor_A,aiColor_B)

Then we just a second call to *Screen()* which is the psychotoolbox command for displaying something (our spot). *aiTouch* is the actual shape that is generated from the xy position and the size value of the spot. So we need to update that also for the second spot before we call Screen(). As mentioned above we keep fnFlipWrapper unchanged. 

The whole new function looks like this:

    function fFlipTime = fnDrawTwoSpotsOnStimulusScreen(pt2iSpot_A,pt2iSpot_B, fSpotSizePix,aiColor_A,aiColor_B)
    global g_strctStimulusServer
    aiTouchSpotRect = [pt2iSpot_A(:)-fSpotSizePix;pt2iSpot_A(:)+fSpotSizePix];
    Screen(g_strctStimulusServer.m_hWindow,'FillArc',aiColor_A, aiTouchSpotRect,0,360);
    aiTouchSpotRect = [pt2iSpot_B(:)-fSpotSizePix;pt2iSpot_B(:)+fSpotSizePix];
    Screen(g_strctStimulusServer.m_hWindow,'FillArc',aiColor_B, aiTouchSpotRect,0,360);
    fFlipTime = fnFlipWrapper( g_strctStimulusServer.m_hWindow);%, 0, 0, 1); % Non blocking flip
    return;


Now as we have a new display function, we go to where we want this function to be called, **case 4**.

The old function call *fnDrawSpotOnStimulusScreen* is not needed anymore, so you delete or comment out that part. At the same position we now add a call to our new function. We need to supply the parameters we defined, which are *(pt2iSpot_A,pt2iSpot_B, fSpotSizePix,aiColor_A,aiColor_B)*, meaning xy for spot Red, xy for spot Green, size of spot, color spot Red, color Spot Green.

xy for both spots we already made above (m_pt2fSpotPos_Red and m_pt2fSpotPos_Green), the spotsize is the same for both and defined in the config file (m_fSpotRad) and the color triplet for green is [0 255 0] and for red [255 0 0].
The complete function call you know should have is this:

  fFlipTime = fnDrawTwoSpotsOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red, ...
            g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green, g_strctParadigm.m_strctCurrentTrial.m_fSpotRad, ...
                              [255 0 0],[0 255 0]);


Kofiko displays the spots a second time, after the monkey touched the screen (**case5**), so copy the above function call and replace the old function (*fnDrawSpotOnStimulusScreen* ) with the new one after the comment  *% Show OK to release stimulus*.
The time this function gets called here in case 5 is when the monkey pressed the correct key. To show some visual feedback of the monkey doing something we want (touch the screen), we can just show the dots in color white. So change the color triplets for both dots to [255 255 255]. The complete call at that location is then this:

     % Show OK to release stimulus
    fnDrawTwoSpotsOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red, ...
            g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green, g_strctParadigm.m_strctCurrentTrial.m_fSpotRad, ...
                             [255 255 255],[255 255 255]);


If you run the whole thing now, it will show two dots (green and red) on the Stimulus server (touchscreen) but it will crash after, as Kofiko doesn't know what to do next. So now we need to update the handling of the touch events to match our new dots and variable names, but first we will also show the two dots on the Kofiko machine, and also incude the outline border of when a touch counts as inside the spot.

##### Kofiko Machine (Draw file)

Go to the file **fnParadigmTouchImageDraw.m**.

This function runs whenever the machine state (case) is higher than 4 and here is what the experimentor sees and we can also add additional information (trial number, correct choices, etc).
What happens is that again the size of the spot is taken (*m_fSpotRad*), then the xy coordinates of the spot are taken (*m_pt2fSpotPos*), from that the area of a correct touch are calculated (*aiValidRect*) to be shown as a cicle, and the *aiTouchSpotRect* vector is calculated that displays the spot. The one that is taken to measure if a touch is within the boundaries is *aiValidRect*, so the actual spot the monkey sees can be larger or smaller than what actually counts. The spot vector is *aiTouchSpotRect*.
Again both get shown by using Screen(). Screen takes as the first argument the physical screen where it should be displayed at. The Kofiko machine (the laptop) has the screen name *g_strctPTB.m_hWindow*, whereas the stimulus server has the name *g_strctStimulusServer.m_hWindow*. We call the latter for this Screen.

Now what we do is just update the four variables that are involved in showing the spot and the boundary we use to measure touch (*pt2iSpot, aiTouchSpotRect, aiTouchSpotRect, aiColor*) with our _green variable, then copy those and change to red for the second _red variable. 

The whole changed if section is then this:

    if g_strctParadigm.m_iMachineState > 4
    fSpotSizePix = g_strctParadigm.m_strctCurrentTrial.m_fSpotRad;
    fCorrectDist = fnTsGetVar(g_strctParadigm, 'CorrectDistancePix');
    
    %show green spot and boundaries
    pt2iSpot = g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green(:);
    aiColor = [0 255 0];
    aiTouchSpotRect = g_strctPTB.m_fScale * [pt2iSpot-fSpotSizePix;pt2iSpot+fSpotSizePix];
    aiValidRect = g_strctPTB.m_fScale * [pt2iSpot-fCorrectDist;pt2iSpot+fCorrectDist];
    
    Screen(g_strctPTB.m_hWindow,'FillArc',aiColor, aiTouchSpotRect,0,360);
    Screen(g_strctPTB.m_hWindow,'FrameArc',aiColor, aiValidRect,0,360);
    
    %show red spot and boundaries
    pt2iSpot = g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red(:);
    aiColor = [255 0 0];
    aiTouchSpotRect = g_strctPTB.m_fScale * [pt2iSpot-fSpotSizePix;pt2iSpot+fSpotSizePix];
    aiValidRect = g_strctPTB.m_fScale * [pt2iSpot-fCorrectDist;pt2iSpot+fCorrectDist];
    
    Screen(g_strctPTB.m_hWindow,'FillArc',aiColor, aiTouchSpotRect,0,360);
    Screen(g_strctPTB.m_hWindow,'FrameArc',aiColor, aiValidRect,0,360);
    end



### Upate Touch event handling
The case that handles the touch events is **case 5**.

The first section of case 5 is what happens is the time passed after trial begin is larger than the timeout value set, meaning the monkey does nothing and it times out.

The second condition (after the else) is where the touches get handled. The two variables that get compared are the *fDistTouchToSpot* which is where the monkey touched the screen (read the touch screen in the paramenter *m_pt2iEyePosScreen*) and the target area location and size *fCorrectDist_Red*. If the touch is within the target, it was a correct touch, and that gets check at 

    if fDistTouchToSpot_Red < fCorrectDist_Red

To now check for only the green spot (correct), we change the parameters to our new variable names (*m_pt2fSpotPos_Green*). We need to update first the *fDistTouchToSpot* for green, then also the *fCorrectDist*. So change those two lines defining those to:

     fDistTouchToSpot_Green = sqrt(sum((strctInputs.m_pt2iEyePosScreen - g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green).^2));
                fCorrectDist_Green = fnTsGetVar(g_strctParadigm, 'CorrectDistancePix');
                
As we also want to check for when the Red spot is touched, we also generate the corresponding boundaries for red, which we add just below above section:

     %monkey touched red circle - correct
                fDistTouchToSpot_Red = sqrt(sum((strctInputs.m_pt2iEyePosScreen - g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red).^2));
                fCorrectDist_Red = fnTsGetVar(g_strctParadigm, 'CorrectDistancePix');
               

now also update the if case to match those new variables:

     %monkey touched green circle - correct
     if fDistTouchToSpot_Green < fCorrectDist_Green
     
 if you run this paradigm now, there will be two dots, and touching the green will count as correct. However touching anywhere else will stop the trial as incorrect. What we want is that only when red is touched it will count as incorrect, otherwise the trial should continue until either green is touched or it times out.
 
 In the current setting, the above if statement gets run whenever there is a touch. If the IF is correct, give reward, for everything else set it to wrong. So all we need to do is replace the ELSE with a second if for the red button. That way any touch will trigger the IF section, if touc is inside green give reward, if inside red count as wrong, if neither, do nothing.
 
 As the whole WRONG procedures are already present after the ELSE statement, all we really need to do is change the else line to this:
 
    %monkey touched red circle - wrong
    elseif fDistTouchToSpot_Red < fCorrectDist_Red
    
now we replaced the general ELSE with this second IF, so now the paradigm will only stop for those two condition, red and green spot touched, otherwise continue until timeout.

If you run the paradigm now it should show a red and a green dot and moving the mouse (or touching) the red dot will count as an error, the green as correct.




## PART3

Next we want to add a penalty time if the monkey pushes the wrong button. 
For that we will add a new state to the file **fnParadigmTouchImageCycle.m** which handles what happens after a wrong choice.
We add a new case a the bottom (after case 7 and the *end* of the *if* loop, called case 8.

We wait for a set amount of time, which we store in a new variable to wait 5 seconds
     
      fPenalty_Time = 5;
     
Next we need to store the current time which we then compare the passed time against to see when 5 seconds have passed. Kofiko keeps a continoues timer in the variable *fCurrTime*. As the Kofiko cycles through the TouchImageCycle file over and over again, each time updating the timer, you can just set a variable to the current timer to get the current time withint the experiment. We need to set this value right after the monkey made a wrong decision and before we exit that if statment (if we do it here, the timer will update every loop again and we will never pass 5 seconds. So we go to **case 5** again, find the section with this if 

      %monkey touched red circle - wrong
                elseif fDistTouchToSpot_Red < fCorrectDist_Red
                
which is the case of a wrong response. Further down you see how the machine state is set to state 1 (initiate new trial), which we change to 8 to have the cycle go to our new penalty case. 

    g_strctParadigm.m_iMachineState = 8;
    
As in the end of case 8 we set the machine state to case 1 everything will go back to its normal course after the delay.
We also want to clear the screen so there is distracting information for the monkey to see. The command for that is 

     % Clear Stimulus Screen
       fnFlipWrapper(g_strctStimulusServer.m_hWindow, 0, 0, 2); % Non blocking flip

which we put right below what we wrote above.
Now we add that timer below that line

    g_strctParadigm.m_fTimer_Penalty = fCurrTime;
    
We also want to clearly show the experimentator that the monkey did a wrong choice, so we just remove the filled dots while waiting for the penalty delay, which will also allow to see if the monkey tries to correct his choice during the penalty time.
For that, we simply set the size of the inner dot to 0, so only the outer area remains by adding this line somewhere in that loop:

    g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = 0;
    
What this does is that it changes the size of the dot to 0, and as the function *TouchImageDraw* gets called whenever the state is higher than 4 (which it is now, as we set it to 8), it will draw the dots on the experimentor screen with our new size 0.


That whole section now looks like this:

      %monkey touched red circle - wrong
                elseif fDistTouchToSpot_Red < fCorrectDist_Red
                    
                    if ~g_strctParadigm.m_bMultipleAttempts
              
                        % inCorrect trial
                        if g_strctParadigm.m_bPlayIncorrect
                            wavplay(g_strctParadigm.m_afIncorrectTrialSound, g_strctParadigm.m_fAudioSamplingRate,'async');
                        end
                        g_strctParadigm.m_strctStatistics.m_iNumIncorrect=g_strctParadigm.m_strctStatistics.m_iNumIncorrect+1;      
                        
                        g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Incorrect';
                        fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                        g_strctParadigm.m_iMachineState = 8;
                       
                       g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = 0;
                       
                          % Clear Stimulus Screen
                        fnFlipWrapper(g_strctStimulusServer.m_hWindow, 0, 0, 2); % Non blocking flip
                        fnParadigmToKofikoComm('CriticalSectionOff');
                        g_strctParadigm.m_fTimer_Penalty = fCurrTime;
                    end
                    
                end


going back to **case 8**, now all we need to do is keep checking the Kofiko Timer (fCurrTime) and wait until the Kofiko timer - our own timer from section 5 is larger than our fPenalty_Time.

As the file cycles, fCurrTime will increase with each cycle. We use an if statment, not a while loop. We also want to show what is going on on the screen, so we will make one loop that is true if the timer has not passed the penalty time to display 'Penalty wait x sec' and after the time has passed changes to 'Waiting for monkey to initiate trial'. In this last case we also need to change the machine state to 1 (case 1, which means start new trial), otherwise it will keep cycling into case 8 forever.

The whole **case 8** looks like this now:

     case 8
       %wait Penalty time
      
       % fTimeout = fnTsGetVar(g_strctParadigm,'TrialTimeOutSec');
       fPenalty_Time = 5;
            
       if fCurrTime - g_strctParadigm.m_fTimer_Penalty < fPenalty_Time
           fnParadigmToKofikoComm('SetParadigmState',...
            sprintf('Waiting for penalty delay %d sec',round(fPenalty_Time - (fCurrTime - g_strctParadigm.m_fTimer_Penalty))));
    
       else
            g_strctParadigm.m_iMachineState = 1;
            fnParadigmToKofikoComm('SetParadigmState', 'Waiting for monkey to initiate trial');
       end
       
When you now run this, you will see on the bottom of the Kofiko screen how the state changes from 5 to 8 when the red dot is touched, and how the time runs down.




## PART4

Next we want to be able to set the variables during the experiment. When you run the paradigm, you can see there are already sliders present for the amount of juice (how long the valve is open), how many trials, the minimal and maximal trial interval, which, if you go to case 1 in *TouchImageCycle* you can see gets randomly picked by the line 

    g_strctParadigm.m_fWaitInterval = rand() * (fMax-fMin) + fMin;

Other parameters to set are the distance of the area of where a touch counts (the circle you can see on the Kofiko server), which you can set with CorrectDistancePx, then also the size of the circle the monkey sees (SpotRadius). 

Then the GUI contains checkboxes at the bottom for Trial Start Audio, Timeout Audio, Correct Audio and Incorrect Audio. 

The last two boxes are to set if the monkey starts the trial by a touch andwhere on the screen (which will ignore the intertrial times you set) and the last is a multi attempt approach, where a wrong touch gets ignored (with no penalty delay or count).
We want to add one new checkbox to set to randomly change the buttons around, then a second one that rewards both dots (red and green) for initial training and also a slider where you can set the penalty timeout time.

### Adding new GUI elements
Go to the file that creates the GUI, **fnParadigmTouchImageGUI.m**.
We want to add a new section after 

    strctControllers.m_hMultipleAttempts..

Copy that whole section (the four lines of strctControllers.m_hMultipleAttempts) and past them below.

We want to change all the namings from *MulitpleAttempts* to *RandomOrder*. Also, as we add a new checkbox, we need to set the Position to be above the others, which would be [10 80 140 15]. The whole new added section now looks like this:

    
    strctControllers.m_hRandomOrder = uicontrol('Style','checkbox','String','Random Order',...
    'Position',[10 80 140 15],'HorizontalAlignment','Left','Parent',...
   hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleRandomOrder'');'],'value',...
    g_strctParadigm.m_bRandomOrder);

We add another checkbox for the *reward_both* below, with the code

    strctControllers.m_hRewardBoth = uicontrol('Style','checkbox','String','Reward Both',...
    'Position',[160 80 140 15],'HorizontalAlignment','Left','Parent',...
   hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''RewardBoth'');'],'value',...
    g_strctParadigm.m_bRewardBoth);
   
For the slider, we add a new slider callback, if you look at the fnAddTextSlider.. functions above the checkbox function you see how they are organized, which is the similar as with the checkboxes. We copy paste one of the sections and change the variable names to generate this new slider:

     
    strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*7, ...
     'Penalty delay (sec):', 'PenaltySec',  0, 300, [1 5], fnTsGetVar(g_strctParadigm,'PenaltySec'));
  
  
The min and max values for the slider are set to 0 and 300. You can change those values to what you need.


Next we need to add this new setting to all the Callback cases. First we make a new variable. Open **fnParadigmTouchImageInit.m** and behind the line *g_strctParadigm.m_bMultipleAttempts* at the top add our new three variables: 

    g_strctParadigm.m_bToggleRandomOrder =  g_strctParadigm.m_fInitial_RandomOrder;
    g_strctParadigm.m_bRewardBoth =  g_strctParadigm.m_fInitial_RewardBoth;
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PenaltySec', g_strctParadigm.m_fInitial_PenaltySec, iSmallBuffer);
    
For the first example, this creates the variable m_bToggleRandomOrder which is part of our struct g_strctParadigm and sets it to what we set it to in the config file. For this to work we also need to add that *Initial_RandomOrder* to our config file. 

Find the file **TouchImageTraining.xml** here
>\Config\KofikoConfigForDifferentRigs\

open it outside of matlab (right click) and then as we did earlier in the section of *<Paradigm Name = "Touch Image Training"* add a a new variable below *Initial_MultipleAttempts* by adding this line

     Initial_RandomOrder = "0"
     
Then save and exit. When this config file is read at the startup, our new variable *Initial_RandomOrder* gets parsed as *g_strctParadigm.m_fInitial_RandomOrder* (so in this case to 0). which is what we need. If you want the default at startup to have the tickbox ticked, use "1" instead of "0".

Again, we also add a default entry for the *reward_both* and *Penalty_Sec* by adding this:

    Initial_RewardBoth = "0"
    Initial_PenaltySec = "5"
    
This sets the tickbox for reward both to unticked and the slider for Penalty Sec to 5. Save the file.
Now we need to add a way to change this variable in case the checkbox is ticked.

Open the file **fnParadigmTouchImageCallbacks.m** and add the new case at the bottom before the *otherwise*

     case 'ToggleRandomOrder'
        g_strctParadigm.m_hRandomOrder = ~g_strctParadigm.m_bToggleRandomOrder;
        set(g_strctParadigm.m_strctControllers.m_hToggleRandomOrder,'value',g_strctParadigm.m_bToggleRandomOrder);

What happens here is that this file Callbacks.m gets called whenever something has been clicked in the GUI. If you new checkbox has been clicked, the case ToggleRandomOrder (which is our checkbox) gets called. The first line inverts what the boolean that is there (if it was 1, it is now 0, if was 0 is now 1), then the set will change the button to either be ticked (if now 1) or unticked (if now 0). m_hRadomOrder is the handle of the tickbox, which is then changed according to the new value.

We do the same for the *reward_both* case by adding another case below:

     case 'RewardBoth'
        g_strctParadigm.m_bRewardBoth = ~g_strctParadigm.m_bRewardBoth;
        set(g_strctParadigm.m_strctControllers.m_hRewardBoth,'value',g_strctParadigm.m_bRewardBoth);

For the slider, there are no different states (ticked or not), so we can just read if straight of the slider element. We do that by adding 

     case 'PenaltySec'
     
further on top of the file where the other slider cased are.

### Handling the new GUI cases
Now we need to do something when those variables change.
For the checkboxes we now that we have a variable that is either 0 or 1 depeding if ticked, we can now check for that and randomise the sided.
As we did above, the position of the red and green dot is set in the file **fnParadigmTouchImageCycle.m** within case 1. What we now want to do is to flip the position of the dots around if the RandomOrder variable is set (meaning the box is ticked). So we first check if the variable is set by 

    if g_strctParadigm.m_bToggleRandomOrder
    --flip here
    end
First we need to pick a random case which is true for 50% of the time. The fuction *rand()* returns a value between 0.0 and 1.0. So we just check 

    if rand() > 0.5
    
which should be true in half the cases. If true we just flip the coordinates of red and green around (we need to save one of them in a temporay variable). The while new parameter case looks now like this:

     %flip coordinates around if set to random
        if g_strctParadigm.m_bToggleRandomOrder
            if rand() > 0.5
                tempxy = g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green;
                g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green = g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red;
                g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Red = tempxy;
            end
        end

If you now run Kofiko and check the random order box it should randomly alternate the sides.

For the delay, when we added the case 8 above we set the delay to 5 seconds (look in the file **TouchImageCycle**, case 8), by using

    fPenalty_Time = 5
    
so all we need to do to use the setting from the penalty delay slider is to replace that with 

    fPenalty_Time = fnTsGetVar(g_strctParadigm,'PenaltySec');
 
this function reads the slide setting and uses its current value.  As it does that with each trial, you can change the slider setting during the experiment to adjust.

Now, to be able to reward both if a checkbox if pressed, it requires a little more work. Currently, the green button is set to be correct, the red to be wrong. To be more flexible we need to be able to not treat green as correct and red as wrong but as two buttons. To make it less messy it makes sense to wrap all the code that runs for a correct press and an incorrect press into a distinct function (DoOnCorrect, DoOnWrong), so we can then at the place in the code where a button is pressed instead of doing all the maintenance (give reward, log events,etc) just call a function in a single line. That means we can then use a few cases for each button without it getting messy.
The way to do that is to just copy (and then delete) all the code in **case 5** between line 

    if fDistTouchToSpot_Green < fCorrectDist_Green
    
and including line
    
    g_strctParadigm.m_iMachineState = 7; % Wait for monkey release  
 to the very bottom of the file. Before that block we define the function by adding 
 
     function fnDoOnCorrect(fCurrTime)
   
As every variable used in this block is in a global structure we can just simply move it here. The only thing we need to do is add

    global g_strctParadigm  

after that function defintion to note that we want to use the global space there. The only variable that is not global is fCurrTime, this is why we pass it into the function. We also add a return at the end.

The whole *DoOnCorrect* function looks like this:


    function fnDoOnCorrect(fCurrTime)
    global g_strctParadigm
    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Correct';
    g_strctParadigm.m_strctCurrentTrial.m_fTrialEnd_TS = fCurrTime;
    fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
    % Correct trial
    if g_strctParadigm.m_bPlayCorrect
    wavplay(g_strctParadigm.m_afCorrectSound, g_strctParadigm.m_fAudioSamplingRate,'async');
    end
    g_strctParadigm.m_strctStatistics.m_iNumCorrect  = g_strctParadigm.m_strctStatistics.m_iNumCorrect  + 1;
    fnParadigmToKofikoComm('SetParadigmState', 'Correct Trial. Waiting for release');
    % Show OK to release stimulus
    fFlipTime =  fnDrawTwoSpotsOnStimulusScreen(g_strctParadigm.m_strct     CurrentTrial.m_pt2fSpotPos_Red, ...
    g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos_Green,       g_strctParadigm.m_strctCurrentTrial.m_fSpotRad, ...
    [255 255 255],[255 255 255]);
    fJuiceTimeMS = fnTsGetVar(g_strctParadigm, 'JuiceTimeMS');
    fnParadigmToKofikoComm('Juice',  fJuiceTimeMS);
    g_strctParadigm.m_iMachineState = 7; % Wait for monkey release
    return
    
In **case 5** where we deleted the code we used for above function it now only says this (before *elseif fDistTouchToSpot_Red < fCorrectDist_Red*):

    if fDistTouchToSpot_Green < fCorrectDist_Green
                     fnDoOnCorrect(fCurrTime)
                      
Which is much shorter and cleaner.

We now to the same for the case below, we copy and delete everything after line 

     if ~g_strctParadigm.m_bMultipleAttempts

until including line

    g_strctParadigm.m_fTimer_Penalty = fCurrTime;
    
and paste it at the bottom at the file. We add above the pasted code a function definition

    function fnDoOnWrong(fCurrTime)

followed by defining the global space

    global g_strctParadigm  g_strctStimulusServer
    
and a *return* at the end to give us this complete OnWrong Function:


    function fnDoOnWrong(fCurrTime)
    global g_strctParadigm  g_strctStimulusServer
    % inCorrect trial
    if g_strctParadigm.m_bPlayIncorrect
    wavplay(g_strctParadigm.m_afIncorrectTrialSound, g_strctParadigm.m_fAudioSamplingRate,'async');
    end
    g_strctParadigm.m_strctStatistics.m_iNumIncorrect=g_strctParadigm.m_strctStatistics.m_iNumIncorrect+1;
    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Incorrect';
    fnTsSetVarParadigm('acTrials',     g_strctParadigm.m_strctCurrentTrial);
    g_strctParadigm.m_iMachineState = 8;
    g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = 0;
    % Clear Stimulus Screen
    fnFlipWrapper(g_strctStimulusServer.m_hWindow, 0, 0, 2); % Non blocking flip
    fnParadigmToKofikoComm('CriticalSectionOff');
    g_strctParadigm.m_fTimer_Penalty = fCurrTime;
    return

Now we again call this function in **case 5** by adding the call *fnDoOnWrong(fCurrTime)* into the if case to get us this shorted section:

    elseif fDistTouchToSpot_Red < fCorrectDist_Red
                    if ~g_strctParadigm.m_bMultipleAttempts
                        fnDoOnWrong(fCurrTime)
                    end
    end


Now that we have a much shorter section that gets called when each button is pressed we can easily add the case where both buttons get rewarded. There is nothing to change in the case of the green button as that gets rewarded anyways. For the red button we just add the case that *if not reward both* do what is done currently, *if reward both* don't do the usual but count as correct. The modifed section looks like this:

    %monkey touched red circle
                elseif fDistTouchToSpot_Red < fCorrectDist_Red
                    %if not reward both
                    if ~g_strctParadigm.m_bRewardBoth
                        %if not ignore wrong
                        if ~g_strctParadigm.m_bMultipleAttempts
                            fnDoOnWrong(fCurrTime)
                        end
                    %if reward both
                    else
                       fnDoOnCorrect(fCurrTime) 
                    end
                end



That should work. If now, let me know.