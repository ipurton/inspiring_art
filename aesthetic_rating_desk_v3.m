% Collecting aesthetic ratings for NYU 2015 thesis
% Written: 3/15/2015 by Isaac Purton
% email (at) isaacpurton (dot) com
% Based on script by Ed Vessel
%
% Collect ratings on a set of images and generate list of top rated images
%
% Dependencies: PsychToolbox v3, image stimulus set (contact experimenter
% for a copy), stimulus order
%
% Revision History:
%   9/16/2015   IP      Fixed top_six variable to handle ties in ratings
%   5/15/2015   IP      Fixed summary file
%   4/30/2015   IP      Added practice trials
%   4/28/2015   IP      rootdir for imagelab changed to desktop
%   4/20/2015   IP      ACTIVE CODE; fixed data saving, revised
%                       instructions, auto-runs next task
%   4/13/2015   IP      Fixed text formatting. Changed data to data_aesth.
%                       Added instructions.
%   4/12/2015   IP      General formatting
%   4/9/2015    IP      Changes to font. Perform a check to make sure this 
%                       all hangs together.
%   4/7/2015    IP      Text fixes for X11, solved HideCursor problems
%   4/6/2015    IP      Added fixes for text in Linux; HideCursor problems
%   3/30/2015   IP      First test run; small typo corrections. Everything
%                       is faantastic.
%   3/28/2015   IP      Housekeeping. Changed how so works, how top_six
%                       gets saved.
%   3/23/2015	IP      Added imagelab case for display properties; need to go over Ed's revisions
%   3/16/2015   IP      Changed so index properties in stimulus drawing sec
%   3/15/2015   IP      First draft

%% Housekeeping
clear all;
close all;
clc;

timestamp.program_start = GetSecs;
    % Gets timestamp for the beginning of this task
rand('state',sum(100*clock));

Screen('Preference', 'SkipSyncTests', 1);
    % Skips syncing tests in PTB

% KEY PARAMETERS
expcode = 'insp';
so_ext = '.mat';
exp_type = 'aesth';

pres_time = 6;
    % Stimulus presentation time
wait_time = 1; 
    % Time between stimulus presentation and response collection
it_time = 1; 
    % Intertrial wait time
fix_time = 0.5; 
    % Fixation point time
resp_max_time = 10;
    % Maximum time allowed for response
prac_trials = 2;
    % Number of practice trials

dblspace = [char(10) char(10)];
    % Shorthand for putting a full line break between two paragraphs
    
SS.fractScreen = 0.9; 
    % Percentage of Screen image uses
SS.max_area = .75;  
    % Max percentage of stimrect which a stimulus can occupy

%% Set Computer Specific Information
% Sets information about known hardware configurations
try
    hostname = mglGetHostName;
catch
    [retval hostname] = system('hostname');
    if retval ~=0,
        if ispc
            hostname = getenv('COMPUTERNAME');
        else
            hostname = getenv('HOSTNAME');
        end
    end
    hostname = lower(hostname);
    if (hostname(end) == char(10)) %strip off trailing return character
        hostname = hostname(1:(end-1));
    end
    try
        if (isempty(str2num(hostname(9))) == 0)
            % Returns 0 if ninth character is a number; allows for a single
            % case entry for all the imagelab computers.
            hostname = 'imagelab';
        end
    catch
        disp('not Imagelab')
    end
end
disp('CHANGE HOST');
%hostname = 'ziggy.local';

switch hostname
    case 'imagelab'
        disp('host set to ImageLab');
%         rootdir = ('/CBI/Users/ipurton/data/insp');
        rootdir = ('/CBI/Users/ipurton/Desktop/insp');
            % Runs code off of desktop
        newRes.width = 1280;
        newRes.height = 1024;
        newRes.hz = 60;
        newRes.pixelSize = 32;
        setScreenNumber = 0;
        SS.ts = 18;
        SS.tsp = SS.ts*1.5;
        SS.fontAR = 0.6; 
            % Set font aspect ratio
        SS.alphaBlend = 0; 
            % Turn off alpha blending; needed for Linux
        SS.fontName = 'Courier New';
        load Dell_P190S_B75_C60_Win7Calib_Apr2015_gamma.mat
            % Gamma table for imagelab Dell monitors
    case 'ipcomp'
        disp('host set to IPComp');
        rootdir = ('F:\art_lab\insp');
        newRes.width = 1920;
        newRes.height = 1080;
        newRes.hz = 60;
        newRes.pixelSize = 32;
        setScreenNumber = 0;
        SS.ts = 18;
        SS.tsp = SS.ts*1.5;
        SS.fontAR = 0.75;
        SS.alphaBlend = 1;
        SS.fontName = 'Courier New';
    otherwise
        disp('Screen & computer parameters set to default')
        %rootdir = pwd;  %set root to current directory
        rootdir = ('/CBI/UserData/starrlab/an_pt');
        newRes.width = 1280;
        newRes.height = 1024;
        newRes.hz = 75 ;
        newRes.pixelSize = 32;
        setScreenNumber = 1;
        SS.ts = 18;
        SS.tsp = SS.ts*1.6;
        %load Phillips202p7_B0_C100_gamma.mat;
end

%% Set directorys, add paths

codedir = ([rootdir,filesep,'code']);
imagedir = ([rootdir,filesep,'images']);
prac_imagedir = ([rootdir,filesep,'prac_images']);
orderdir = ([rootdir,filesep,'orders']);
datadir = ([rootdir,filesep,'Data']);
addpath(imagedir);
addpath(prac_imagedir);
addpath(datadir);
addpath(codedir);

%% Load experimental stimuli
d = dir([imagedir,filesep,'*.tif']);
    % Creates struct array 'd' with names of all tif images in imagedir
n_stim = length(d);
    % Finds number of image stimuli
[imglist{1:n_stim}] = deal(d.name);
    % Creates cell array with names of images
    
%% Load practice stimuli
prac_d = dir([prac_imagedir,filesep,'*.tif']);
    % Creates struct array 'd' with names of all tif images in imagedir
prac_stim = length(prac_d);
    % Finds number of image stimuli
[prac_imglist{1:prac_stim}] = deal(prac_d.name);
    % Creates cell array with names of images
    
%% Get Participant Information

ssn = input('Subject number: ');
    % Prompt subject for subject number

try
    load([datadir,filesep,'s',int2str(ssn),'_','sub_data','.mat'],'-mat');
    runnum = 2;
    disp('Welcome to the Fourth Task');
    pause(2);
        % If loading the sub_data file occurs without error, set runnum
        % to 2 and skip prompts for additional subject information.
        % sub_data is created at the end of runnum
catch
    runnum = 1;
    disp('Welcome to the Second Task');
    name = input('Subject Initials: ','s');
    gend = input('Gender (m/f): ','s');
    hand = input('Handedness (l/r): ','s');
    age = input('Age: ');
        % If the sub_data file does not exist, set runnum to 1 and prompt
        % for subject information.
end

%% Get Stimulus Order

ordertext = [expcode,'_',exp_type,'_s',int2str(ssn),...
    '_r',int2str(runnum),so_ext];
    % Defines the filename of the stimulus order file used for this run
load([orderdir,filesep,ordertext]);
    % Calls the art_order variable from the order file
so = art_order;
    % Loads art_order into so variable

FlushEvents('keyDown');

%% Set Up Screens
% Set screen number
if exist('setScreenNumber', 'var') == 1
    SS.ScreenNumber = setScreenNumber;
else
    SS.ScreenNumber = 1;
end
% SS.ScreenNumber = 0;

% Set up preferences, pixel depth, etc.
oldRes = Screen('Resolution',SS.ScreenNumber,...
    newRes.width,newRes.height,newRes.hz,newRes.pixelSize);

% Colors
white = WhiteIndex(SS.ScreenNumber);
black = BlackIndex(SS.ScreenNumber);
gray = 120;
% SS.bgcolor = [gray gray gray];
SS.bgcolor = [white white white];
SS.textColor = [black black black];
% SS.text_bgcolor = [200 200 200];
SS.text_bgcolor = SS.bgcolor;

% Set up trial timing parameters - code times in absolute time, not
% refreshes
RefreshRate = Screen('FrameRate',SS.ScreenNumber); %Measure Refresh Rate

% Set up fixation point
fixsize = 15;
fixcross = ones(fixsize,fixsize,3)*SS.bgcolor(1);
fixcross(ceil(fixsize/2):ceil(fixsize/2),1:fixsize,:) = black;
fixcross(1:fixsize,ceil(fixsize/2):ceil(fixsize/2),:) = black;

%Set up keys, establishes escape key
KbName('UnifyKeyNames');
escKey = KbName('`~');

text_border = [50 150];

%% Run Experiment
try
    % Making sure we're dealing with the newer version of PTB:
    AssertOpenGL;
    
    % Establish a full screen window
    [wholeScreen, SS.ScreenRect] = ...
        Screen('OpenWindow', SS.ScreenNumber, SS.bgcolor);
    
    HideCursor;
        % Has to be declared after 'OpenWindow' on Linux machines.
    
    slider.mouseMax = SS.ScreenRect(4); 
        % Set mouse maximum before adjusting monitor settings
    
    % Load normalized gamma table, if it exists
    if exist('gammaTable')
        old_gt = Screen('LoadNormalizedGammaTable', wholeScreen, ...
            gammaTable);
    end
        
    % Getting inter-flip interval (ifi), (i.e., the refresh rate, how long
    % it takes the computer to put up a new Screen).
    Priority(MaxPriority(wholeScreen));
    SS.ifi = Screen('GetFlipInterval', wholeScreen, 20);
    Priority(0);
    
    % Storing generally useful screen values in the SS struct array:
    SS.x_min = SS.ScreenRect(1);
    SS.x_max = SS.ScreenRect(3);
    SS.y_min = SS.ScreenRect(2);
    SS.y_max = SS.ScreenRect(4);
    
    SS.AspectRatio = SS.x_max/SS.y_max;
    SS.winWidth = SS.x_max-SS.x_min;
    SS.winHeight = SS.y_max-SS.y_min;
    SS.x_center = SS.winWidth/2;
    SS.y_center = SS.winHeight/2;
    
    % Set up windows and rect's for stimulus, text, & fixation point
    SS.FixRect = [0 0 fixsize fixsize];
    SS.Fixation = CenterRect(SS.FixRect, SS.ScreenRect);
    fixTex = Screen('MakeTexture',wholeScreen,fixcross);
    
    % Setting font properties
    Screen('TextFont', wholeScreen, SS.fontName);
        % Switched to fixed-width font
    Screen('Preference', 'TextAlphaBlending', SS.alphaBlend);
    
    % Declaring margins for DrawFormmatedText
    SS.margin.x = 50; %left/right
    SS.margin.y = 50; %top/bottom
    
    textsize = [0 0 200 120];
    Screen('TextSize',wholeScreen,SS.ts);
        % Sets the size for drawn text to SS.ts
    SS.textrect = CenterRect(textsize + ...
        [0 0 text_border(1) text_border(2)],SS.ScreenRect);
    %[textwin, SS.TextwinRect] = Screen('OpenWindow',SS.ScreenNumber,SS.bgcolor,textrect);
    SS.charPerLine = floor((SS.winWidth - ...
        (2*SS.margin.x))/(SS.ts .* SS.fontAR));
        % Characters in a single line of text; doesn't work with
        % variable-width fonts.
        % Divides width of current window - x margins by the size of the
        % text and rounds down to nearest whole number.
    Screen('BlendFunction',wholeScreen,GL_ONE,GL_ZERO);
    oldTextBackgroundColor=Screen('TextBackgroundColor', ...
        wholeScreen,SS.text_bgcolor);

    SS.stimsize = SS.ScreenRect([1 1 4 4]) .* (SS.fractScreen);
    
    % Set up response slider for ratings
    % Slider between 0 and 1
    % -1 if no response
    % nothing appears on slider until person starts moving mouse?
    % click key to lock in?
    slider.mouse_x = -SS.x_center;
    slider.start_pos = 0.5;
    slider.Color = SS.bgcolor .* 0.8;
    slider.activeColor = [255 0 0];
    slider.lockColor = [0 255 0];
    slider.Width = 200;
    slider.Height = 10;
    slider.Offset = 0; %offset from center of screen
    slider.indWidth = 3;
    
    sliderImg = ones(slider.Height,slider.Width) .* slider.Color(1);
    slider.Tex = Screen('MakeTexture',wholeScreen , sliderImg);
    slider.Size = [0 0 slider.Width slider.Height];
    SS.sliderRect = [0 slider.Offset 0 slider.Offset] + ...
        CenterRect(slider.Size,SS.ScreenRect);
    if mod(ssn,2)
        slider.Dir = -1;
    else
        slider.Dir = 1;
    end
    % Screen('TextSize',slider.Tex,slider.Height);
    slider.sh_offset.l = SS.ts; %text offset off each end
    slider.sh_offset.r = 8;
    slider.sv_offset = -slider.Height; %text offset below slider
    
    %% Show Instructions
   
    % Load practice images
    prac_imgsz = zeros(prac_trials,3);
    prac_imgratio = zeros(prac_trials,1);
    prac_img_area = zeros(prac_trials,1);
    prac_imTex = zeros(prac_trials,1);
    
    for ii = 1:prac_trials
        imgname = prac_imglist{ii};
            % Loads image name
        testimg = imread([prac_imagedir,filesep,imgname]);
            % Reads in image identified by imgname
        prac_imgsz(ii,:) = size(testimg); % width, height, colorchannels
        prac_imgratio(ii) = prac_imgsz(ii,1) / prac_imgsz(ii,2); % ratio of width/height
        if prac_imgsz(ii,1) > SS.stimsize(3) 
            % if image width is bigger than stimrect width
            prac_imgsz(ii,1) = SS.stimsize(3);
            prac_imgsz(ii,2) = prac_imgsz(ii,1) ./ prac_imgratio(ii);
        end
        if prac_imgsz(ii,2) > SS.stimsize(4)
            % if image height is bigger than stimrect height
            prac_imgsz(ii,2) = SS.stimsize(4);
            prac_imgsz(ii,1) = prac_imgsz(ii,2) .* prac_imgratio(ii);
        end
        prac_img_area(ii) = prac_imgsz(ii,1) .* prac_imgsz(ii,2);
            % Calculates the area of the image
        if (prac_img_area(ii) > (SS.max_area .* SS.stimsize(3)...
                .* SS.stimsize(4))) 
           % Scale max area
           side_rescale = sqrt((SS.max_area .* SS.stimsize(3)...
               .* SS.stimsize(4)) ./ prac_img_area(ii));
           prac_imgsz(ii,1) = prac_imgsz(ii,1) .* side_rescale;
           prac_imgsz(ii,2) = prac_imgsz(ii,2) .* side_rescale;
        end
        prac_imTex(ii) = Screen('MakeTexture',wholeScreen,testimg);
            % Populates imTex with an index value for each image
            % This index value can be called with DrawTexture
    end
    
    % Show instructions for the aesthetic rating task on first run
    if runnum == 1
        msg = ['Instructions for Aesthetic Rating Task - Page 1' dblspace... 
            'In this task, you will be asked to make '...
            'judgments about works of art. There are no right or wrong '...
            'answers for any of the images, only your subjective '...
            'impression of how much you like the paintings you see. '...
            'We would like to get a sense of your "gut level" '...
            'preferences in your answers to these questions.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 1
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            % The pause is because I don't fully trust KbWait at this point
        
        msg = ['Instructions for Aesthetic Rating Task - Page 2' dblspace... 
            'Imagine that the images you see are of paintings that may be '...
            'acquired by a museum of fine art.  The curator needs to know '...
            'which paintings are the most aesthetically pleasing '...
            'based on how strongly you as an individual respond to them. '...
            'Your job is to give your gut-level response, based on how '...
            'much you find the painting beautiful, compelling, or powerful. '...
            'Note: The paintings may cover the entire range from '...
            '"beautiful" to "strange" or even "ugly." We ask that you '...
            'respond on the basis of how much this image "moves" you. '...
            'What is most important is for you to indicate what works '...
            'you find powerful, pleasing, or profound.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 2
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            
        msg = ['Instructions for Aesthetic Rating Task - Page 3' dblspace... 
            'On each trial, you will be shown an image of a work of art for '...
            int2str(pres_time), ' seconds. After the image disappears, you will be asked to '...
            'answer the question, "How strongly does this '...
            'painting move you?"  The question will appear on the '...
            'screen along with a slider. You will use the mouse '...
            'to indicate your response by moving it up or down to move '...
            'the slider.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 3
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
        
        msg = ['Instructions for Aesthetic Rating Task - Page 4' dblspace... 
            'If the image was highly moving, then use the '...
            'mouse to position the slider cursor towards the high end '...
            'of the scale (marked "H") and click the mouse to lock in your '...
            'response. If the painting did not move you at all, move '...
            'the slider to the low end of the scale and lock your response. '...
            'If you did not feel strongly one way or the other, use the '...
            'middle of the scale. Please feel free to '...
            'use the entire scale to indicate your feelings.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 4
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response

        msg = ['Instructions for Aesthetic Rating Task - Page 5' dblspace... 
            'You will be given a set of practice trials to '...
            'help you feel more comfortable with the task.' dblspace...
            'Throughout the experiment, take care to rate each image based '...
            'on how you feel about the image AT THAT MOMENT, '...
            'regardless of the ratings you have made on previous trials.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 5
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
    
        %% Practice Trials
            
        msg = ['You will now be run in a series of ' int2str(prac_trials)...
            ' practice trials to familiarize you with the task.' char(10)...
            'On each trial, you will see a painting, and then be asked to '...
            'indicate the strength of your aesthetic reaction '...
            'to the painting. You will respond by moving the '...
            'slider bar to a position corresponding to your reaction.' dblspace...
            '(Hit any key to begin the practice trials)'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 6
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            
        timestamp.practice_start = GetSecs;
        
        for practice = 1:prac_trials
            prac_TimerStart = GetSecs - timestamp.practice_start;
                % Finds the start time of this trial, relative to start of
                % experiment.

            % Draw fixation
            Screen('DrawTexture',wholeScreen,fixTex,[],SS.Fixation);
            Screen('Flip',wholeScreen);

            % Draw stimulus
            stimrect = CenterRect([0 0 prac_imgsz(practice,2) ...
                prac_imgsz(practice,1)],SS.ScreenRect);
            Screen('DrawTexture',wholeScreen,prac_imTex(practice),[],stimrect);

            % wait & flip
            Screen('Flip',wholeScreen,timestamp.practice_start + ...
                prac_TimerStart + fix_time);

            % wait & clear
            Screen('Flip',wholeScreen,timestamp.practice_start +  ...
                prac_TimerStart + fix_time + pres_time);

            % Collect Response
            lock = 0;
            resp = -1;
            m.buttons = 0;
            RespStart = GetSecs;

            % Collect current mouse position
            SetMouse(slider.mouse_x,slider.mouseMax/2 - 1);
            current_pos = slider.start_pos;
            indColor = slider.Color;

            % Display question
            Screen('Drawtext',wholeScreen,'How strongly',SS.textrect(1),...
                SS.textrect(2),SS.textColor,SS.text_bgcolor);
            Screen('Drawtext',wholeScreen,'does this painting move you?',...
                SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);

            % Draw slider
            Screen('DrawTexture',wholeScreen,slider.Tex,[],SS.sliderRect);
            Screen('DrawText',wholeScreen,'L',(SS.x_center) - ...
                (slider.sh_offset.l+slider.Width/2),ceil(SS.y_center)+...
                SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
            Screen('DrawText',wholeScreen,'H',(SS.x_center) + ...
                (slider.sh_offset.r+slider.Width/2),ceil(SS.y_center)+...
                SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
            Screen('DrawLine', wholeScreen ,indColor, SS.x_center + ...
                (slider.Width * current_pos) - (slider.Width/2), ...
                ceil(SS.y_center)+SS.y_min-slider.Height/2, SS.x_center + ...
                (slider.Width * current_pos) - (slider.Width/2), ...
                ceil(SS.y_center)+SS.y_min+slider.Height/2, slider.indWidth);
            Screen('Flip',wholeScreen,timestamp.practice_start + ...
                prac_TimerStart + fix_time + pres_time + wait_time);       

            %Loop that updates slider
            while ~lock %loop until subject locks
                switch resp
                    case -1
                        [m.x,m.y,m.buttons] = GetMouse;
                        switch slider.Dir
                            case 1
                                current_pos = (m.y+1)./ slider.mouseMax;
                            case -1
                                current_pos = 1 - ((m.y+1)./ slider.mouseMax);
                        end
                        if (current_pos ~= slider.start_pos) %wait for movement
                            resp = 0;
                            indColor = slider.activeColor;                        
                        end
                    case 0
                        [m.x,m.y,m.buttons] = GetMouse;
                        switch slider.Dir
                            case 1
                                current_pos = (m.y+1)./ slider.mouseMax;
                            case -1
                                current_pos = 1 - ((m.y+1)./ slider.mouseMax);
                        end
                        if m.buttons(1)
                            %HideCursor;
                            indColor = slider.lockColor;
                            resp = 1;
                            sliderResp = current_pos;
                            tim = GetSecs;
                        end
                    case 1
                        lock = 1;
                end
                % Keep displaying question
                Screen('Drawtext',wholeScreen,'How strongly',...
                    SS.textrect(1),SS.textrect(2),SS.textColor,...
                    SS.text_bgcolor);
                Screen('Drawtext',wholeScreen,...
                    'does this painting move you?',SS.textrect(1),...
                    SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
                % Keep displaying slider
                Screen('DrawTexture',wholeScreen,slider.Tex,[],SS.sliderRect);
                Screen('DrawText',wholeScreen,'L',(SS.x_center) - ...
                    (slider.sh_offset.l+slider.Width/2),ceil(SS.y_center)+...
                    SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
                Screen('DrawText',wholeScreen,'H',(SS.x_center) + ...
                    (slider.sh_offset.r+slider.Width/2),ceil(SS.y_center)+...
                    SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
                Screen('DrawLine', wholeScreen ,indColor, SS.x_center + ...
                    (slider.Width * current_pos) - (slider.Width/2), ...
                    ceil(SS.y_center)+ SS.y_min-slider.Height/2, ...
                    SS.x_center + (slider.Width * current_pos) - ...
                    (slider.Width/2), ceil(SS.y_center)+...
                    SS.y_min+slider.Height/2, slider.indWidth);
                Screen('Flip',wholeScreen);
            end %slider loop

            Screen('Flip',wholeScreen);

            pause(it_time)
        
        end%practice loop
            
        %% Instructions (Cont)
        
        DrawFormattedText(wholeScreen,...
            ['This is the end of the instructions. Please raise your hand if you have any '...
            'further questions. Otherwise, press any key to proceed.'],...
            SS.margin.x,SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
        Screen('Flip', wholeScreen);
        KbWait([], 3);
        pause(0.3)
            % Show Page 7, pause for participant input
            
    elseif runnum == 2
        msg = ['Instructions for Second Aesthetic Rating Task - Page 1' dblspace...
            'In this task you will once again be asked to make '...
            'judgments about works of art. Below are instructions which '...
            'are the same as in the previous aesthetic rating task. Please read over them at your own '...
            'pace to refresh your memory of how the task works.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 1
        KbWait([], 3);
        pause(0.3)
        
        msg = ['Instructions for Second Aesthetic Rating Task - Page 2' dblspace... 
            'In this task, you will be asked to make '...
            'judgments about works of art. There are no right or wrong '...
            'answers for any of the images, only your subjective '...
            'impression of how much you like the paintings you see. '...
            'We would like to get a sense of your "gut level" '...
            'preferences in your answers to these questions.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 2
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            % The pause is because I don't fully trust KbWait at this point
        
        msg = ['Instructions for Second Aesthetic Rating Task - Page 3' dblspace... 
            'Imagine that the images you see are of paintings that may be '...
            'acquired by a museum of fine art.  The curator needs to know '...
            'which paintings are the most aesthetically pleasing '...
            'based on how strongly you as an individual respond to them. '...
            'Your job is to give your gut-level response, based on how '...
            'much you find the painting beautiful, compelling, or powerful. '...
            'Note: The paintings may cover the entire range from '...
            '"beautiful" to "strange" or even "ugly." We ask that you '...
            'respond on the basis of how much this image "moves" you. '...
            'What is most important is for you to indicate what works '...
            'you find powerful, pleasing, or profound.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 3
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            
        msg = ['Instructions for Second Aesthetic Rating Task - Page 4' dblspace... 
            'On each trial, you will be shown an image of a work of art for '...
            int2str(pres_time), ' seconds. After the image disappears, you will be asked to '...
            'answer the question, "How strongly does this '...
            'painting move you?"  The question will appear on the '...
            'screen along with a slider. You will use the mouse '...
            'to indicate your response by moving it up or down to move '...
            'the slider.' dblspace 'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 4
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
        
        msg = ['Instructions for Second Aesthetic Rating Task - Page 5' dblspace... 
            'If the image was highly moving, then use the '...
            'mouse to position the slider cursor towards the high end '...
            'of the scale (marked "H") and click the mouse to lock in your '...
            'response. If the painting did not move you at all, move '...
            'the slider to the low end of the scale and lock your response. '...
            'If you did not feel strongly one way or the other, use the '...
            'middle of the scale. Please feel free to '...
            'use the entire scale to indicate your feelings.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 5
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response

        msg = ['Instructions for Second Aesthetic Rating Task - Page 6' dblspace... 
            'Throughout the experiment, take care to rate each image based '...
            'on how you feel about the image AT THAT MOMENT, '...
            'regardless of the ratings you have made on previous trials.' dblspace...
            'Press any key to continue.'];
        DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
            SS.textColor, SS.charPerLine, 0, 0, 1.5)
        Screen('Flip', wholeScreen);
            % Show Page 6
        KbWait([], 3);
        pause(0.3)
            % Wait for participant response
            
        msg = ['This is the end of the instructions. As a reminder, you will be shown images '...
            'for '  int2str(pres_time) ' seconds and then asked to '... 
            'provide your response on a slider.' dblspace...
            'Please raise your hand if you have any '...
            'further questions. Otherwise, press any key to proceed.'];
        DrawFormattedText(wholeScreen, msg,...
            SS.margin.x,SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
        Screen('Flip', wholeScreen);
        KbWait([], 3);
        pause(0.3)
    end
    
    %% LOAD STIMULI
    
    % Initialize variables used in loader loop
    imgsz = zeros(n_stim,3);
    imgratio = zeros(n_stim,1);
    img_area = zeros(n_stim,1);
    imTex = zeros(n_stim,1);
    
    for ii = 1:n_stim
        imgname = imglist{ii};
            % Loads image name
        testimg = imread([imagedir,filesep,imgname]);
            % Reads in image identified by imgname
        imgsz(ii,:) = size(testimg); % width, height, colorchannels
        imgratio(ii) = imgsz(ii,1) / imgsz(ii,2); % ratio of width/height
        if imgsz(ii,1) > SS.stimsize(3) 
            % if image width is bigger than stimrect width
            imgsz(ii,1) = SS.stimsize(3);
            imgsz(ii,2) = imgsz(ii,1) ./ imgratio(ii);
        end
        if imgsz(ii,2) > SS.stimsize(4)
            % if image height is bigger than stimrect height
            imgsz(ii,2) = SS.stimsize(4);
            imgsz(ii,1) = imgsz(ii,2) .* imgratio(ii);
        end
        img_area(ii) = imgsz(ii,1) .* imgsz(ii,2);
            % Calculates the area of the image
        if (img_area(ii) > (SS.max_area .* SS.stimsize(3)...
                .* SS.stimsize(4))) 
           % Scale max area
           side_rescale = sqrt((SS.max_area .* SS.stimsize(3)...
               .* SS.stimsize(4)) ./ img_area(ii));
           imgsz(ii,1) = imgsz(ii,1) .* side_rescale;
           imgsz(ii,2) = imgsz(ii,2) .* side_rescale;
        end
        imTex(ii) = Screen('MakeTexture',wholeScreen,testimg);
            % Populates imTex with an index value for each image
            % This index value can be called with DrawTexture
            
        % Display progress in center of screen
        Screen('Drawtext',wholeScreen,['Loading Images: ', ...
            int2str(round((ii/20)*100)),'%'],SS.textrect(1), ...
            SS.textrect(2),SS.textColor,SS.text_bgcolor);
        Screen('Flip', wholeScreen);  %show text
    end
    
    Screen('Flip',wholeScreen);  
        % Clear text
        
    switch runnum
        case 1
            Screen('DrawText',wholeScreen,'Task 2: Aesthetic Rating',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
        case 2
            Screen('DrawText',wholeScreen,'Task 4: Aesthetic Rating',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
    end
    
    Screen('Drawtext',wholeScreen,'Hit any key to start',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
    Screen('Flip', wholeScreen);  
        % Show text
    
    KbWait([], 3);
    pause(0.5)
        % Wait for participant input to advance
    Screen('Flip',wholeScreen);
    
    pause(1);
    escape = 0;
    
    timestamp.experiment_start = GetSecs;
        % Prints the time when experiment started
    
    % Need to initialize data
    data_aesth.time = 0;
    data_aesth.resp = 0;  
    data_aesth.image{1} = '';        
    
    %% Trial Loop
    for trial = 1:n_stim
        data_aesth.trialstart(trial) = GetSecs - timestamp.experiment_start;
            % Finds the start time of this trial, relative to start of
            % experiment.

        % Draw fixation
        Screen('DrawTexture',wholeScreen,fixTex,[],SS.Fixation);
        Screen('Flip',wholeScreen);
        
        % Draw stimulus
        stimrect = CenterRect([0 0 imgsz(so(trial),2) ...
            imgsz(so(trial),1)],SS.ScreenRect);
        Screen('DrawTexture',wholeScreen,imTex(so(trial)),[],stimrect);
        
        % wait & flip
        Screen('Flip',wholeScreen,timestamp.experiment_start + ...
            data_aesth.trialstart(trial) + fix_time);

        % wait & clear
        Screen('Flip',wholeScreen,timestamp.experiment_start +  ...
            data_aesth.trialstart(trial) + fix_time + pres_time);

        %% Collect Response
        lock = 0;
        resp = -1;
        m.buttons = 0;
        RespStart = GetSecs;

        % Collect current mouse position
        SetMouse(slider.mouse_x,slider.mouseMax/2 - 1);
        current_pos = slider.start_pos;
        indColor = slider.Color;

        % Display question
        Screen('Drawtext',wholeScreen,'How strongly',SS.textrect(1),...
            SS.textrect(2),SS.textColor,SS.text_bgcolor);
        Screen('Drawtext',wholeScreen,'does this painting move you?',...
            SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
        
        % Draw slider
        Screen('DrawTexture',wholeScreen,slider.Tex,[],SS.sliderRect);
        Screen('DrawText',wholeScreen,'L',(SS.x_center) - ...
            (slider.sh_offset.l+slider.Width/2),ceil(SS.y_center)+...
            SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
        Screen('DrawText',wholeScreen,'H',(SS.x_center) + ...
            (slider.sh_offset.r+slider.Width/2),ceil(SS.y_center)+...
            SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
        Screen('DrawLine', wholeScreen ,indColor, SS.x_center + ...
            (slider.Width * current_pos) - (slider.Width/2), ...
            ceil(SS.y_center)+SS.y_min-slider.Height/2, SS.x_center + ...
            (slider.Width * current_pos) - (slider.Width/2), ...
            ceil(SS.y_center)+SS.y_min+slider.Height/2, slider.indWidth);
        Screen('Flip',wholeScreen,timestamp.experiment_start + ...
            data_aesth.trialstart(trial) + fix_time + pres_time + wait_time);       

        %Loop that updates slider
        while ~lock %loop until subject locks
            switch resp
                case -1
                    [m.x,m.y,m.buttons] = GetMouse;
                    switch slider.Dir
                        case 1
                            current_pos = (m.y+1)./ slider.mouseMax;
                        case -1
                            current_pos = 1 - ((m.y+1)./ slider.mouseMax);
                    end
                    if (current_pos ~= slider.start_pos) %wait for movement
                        resp = 0;
                        indColor = slider.activeColor;                        
                    end
                case 0
                    [m.x,m.y,m.buttons] = GetMouse;
                    switch slider.Dir
                        case 1
                            current_pos = (m.y+1)./ slider.mouseMax;
                        case -1
                            current_pos = 1 - ((m.y+1)./ slider.mouseMax);
                    end
                    if m.buttons(1)
                        %HideCursor;
                        indColor = slider.lockColor;
                        resp = 1;
                        sliderResp = current_pos;
                        tim = GetSecs;
                    end
                case 1
                    lock = 1;
            end
            % Keep displaying question
            Screen('Drawtext',wholeScreen,'How strongly',...
                SS.textrect(1),SS.textrect(2),SS.textColor,...
                SS.text_bgcolor);
            Screen('Drawtext',wholeScreen,...
                'does this painting move you?',SS.textrect(1),...
                SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
            % Keep displaying slider
            Screen('DrawTexture',wholeScreen,slider.Tex,[],SS.sliderRect);
            Screen('DrawText',wholeScreen,'L',(SS.x_center) - ...
                (slider.sh_offset.l+slider.Width/2),ceil(SS.y_center)+...
                SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
            Screen('DrawText',wholeScreen,'H',(SS.x_center) + ...
                (slider.sh_offset.r+slider.Width/2),ceil(SS.y_center)+...
                SS.y_min+slider.sv_offset,SS.textColor,SS.text_bgcolor);
            Screen('DrawLine', wholeScreen ,indColor, SS.x_center + ...
                (slider.Width * current_pos) - (slider.Width/2), ...
                ceil(SS.y_center)+ SS.y_min-slider.Height/2, ...
                SS.x_center + (slider.Width * current_pos) - ...
                (slider.Width/2), ceil(SS.y_center)+...
                SS.y_min+slider.Height/2, slider.indWidth);
            Screen('Flip',wholeScreen);
        end %slider loop

        Screen('Flip',wholeScreen);

        switch resp
            case 1 %Response LOCKED IN
                data_aesth.resp(trial) = sliderResp;
                data_aesth.lock(trial) = 1;
                data_aesth.time(trial) = tim - RespStart; 
                    % time measured from offset of image/resp cue
            case 0 %Response NOT locked in
                data_aesth.resp(trial) = current_pos;
                %data{block}.resp(trial) = sliderResp; %FIX
                data_aesth.lock(trial) = 0;
                data_aesth.time(trial) = -1; 
                    %subject didn't lock in the response (timeout)
            case -1 %subj didn't move slider at all
                data_aesth.resp(trial) = 0;
                data_aesth.lock(trial) = -1;
                data_aesth.time(trial) = 0;
        end
        
        data_aesth.image{trial} = imglist{so(trial)};
        
        disp(['Trial: ',int2str(trial), '  Response: ',...
            num2str(data_aesth.resp(trial),2), ...
            '  Lock: ',int2str(data_aesth.lock(trial))]);

        if escape
            break
        end

        %% Intertrial interval
        % DELETE?
%         while (GetSecs < (tim + it_time)); end

%             
%             if and(brk1=='y', (mod(trial,brktrial) == 0));
%                 Screen('DrawText',wholeScreen,'Take a short break',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
%                 Screen('DrawText',wholeScreen,'Hit a key to continue',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
%                 Screen('FillRect', wholeScreen, PDoff, PDrect);
%                 Screen('Flip',wholeScreen);
%                 KbWait([],3);
%                 Screen('FillRect', wholeScreen, PDoff, PDrect);
%                 Screen('Flip',wholeScreen);
%                 pause(1);
%             end;

        pause(it_time);

        FlushEvents('keydown');

        if escape; break; end

    end %END trial loop
        
    timestamp.program_end = GetSecs;
    timestamp.exptime = timestamp.program_end - timestamp.experiment_start;
    
    if runnum == 1
        Screen('Drawtext',wholeScreen,'End of Second Task',SS.textrect(1),...
            SS.textrect(2),SS.textColor,SS.text_bgcolor);
    elseif runnum == 2
        Screen('Drawtext',wholeScreen,'End of Experiment!',SS.textrect(1),...
            SS.textrect(2),SS.textColor,SS.text_bgcolor);
    end
    Screen('Drawtext',wholeScreen,'Press any key to continue',...
        SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
    Screen('Flip',wholeScreen);
    
    KbWait([],3);
    Screen('Flip',wholeScreen);   

    %% CLEAN UP
    %close windows & return pixel depth
    for ii = 1:n_stim
        ShowCursor
    end
    Screen('CloseAll');
    Screen('Resolution',SS.ScreenNumber,oldRes.width,oldRes.height,...
        oldRes.hz,oldRes.pixelSize);
    if exist('old_gt')
        Screen('LoadNormalizedGammaTable',SS.ScreenNumber,old_gt); 
    end
    
    ListenChar(0);

    catch % Cleanup if something goes wrong above.
        sprintf('Error: %s', lasterr)
        Priority(0);
        for ii = 1:n_stim
            ShowCursor;
        end
        Screen('CloseAll');
        Screen('Resolution',SS.ScreenNumber,oldRes.width,oldRes.height,oldRes.hz,oldRes.pixelSize);
        if exist('old_gt')
            Screen('LoadNormalizedGammaTable',SS.ScreenNumber,old_gt); 
        end
        
        ListenChar(0);

        save DebugVars;
        error_struct = lasterror;
        error_output = [];
        for ii = 1:length(error_struct.stack)
            error_lines = error_struct.stack(ii);
            error_output = [error_output, ...
                sprintf('file: %s\t\t\tline: %d\n',error_lines.name, ...
                error_lines.line)];
        end
        disp(error_output)
        rethrow(lasterror)
end % End try loop
    
%% Write out data

% Find the top six images for this participant
% This had to be changed in order to handle tied ratings (ex. both the 1st
% and 2nd ranked images have a rating of 1). This version pulls image names
% based on the trial number associated with a given rating.
% The script used to run the first 20 subjects used the following:
% if runnum == 1
%     data_resp = zeros(n_stim,1);
%     data_resp(:) = data_aesth.resp(:);
%     data_resp_sort = sort(data_resp,'descend');
%     top_six = cell(6,1);
%     for ii = 1:6
%         index = find(data_resp == data_resp_sort(ii));
%             % Finds the row index for rank ii response in data_resp
%         index_name = data_aesth.image{index};
%             % Finds the name for the rank ii image
%         top_six{ii} = index_name;
%             % Prints name of the rank ii image in top_six at row ii
%             % Writes out a variable with the top_six image names in 
%             % rank order.
%     end
% end

% The final version of this script is as follows:
if runnum == 1
    % If this is Aesthetic-Pre...
    data_resp = zeros(n_stim,2);
    data_resp(:,1) = 1:n_stim;
        % Print the trial number
    data_resp(:,2) = data_aesth.resp(:);
        % Copy aesthetic ratings
    data_resp_sort = sortrows(data_resp,-2);
        % Sorts data_resp by the 2nd column
        % This way, trial number (the first column) is preserved
    top_six = cell(6,1);
    for ii = 1:6
        index = data_resp_sort(ii,1);
            % data_resp_sort has ratings in descending order, from highest
            % rated to lowest. The iith row corresponds to the iith rank
            % (ie. the 1st row refers to the highest rated painting). The
            % first column is the original trial number for that painting.
        index_name = data.aesth.image{index};
            % index refers to a specific trial. This pulls the name of the
            % image used in that specific trial.
        top_six{ii} = index_name;
            % Prints name of the rank ii image in top_six at row ii
            % Writes out a variable with the top_six image names in 
            % rank order.
    end
end


if ssn~=0;
    sumfile = [datadir, filesep, expcode,'_',exp_type,'_summary.txt'];
    sfid = fopen(sumfile,'at');
    % Write text to summary file
    % ssn, date, n_stim, time of the start of experiment, initials, gender,
    % handedness, and age
    fprintf(sfid,'\n %d\t %s\t %d\t %4.1f\t %s\t %s\t %s\t %d\n', ssn, date, ...
        n_stim, timestamp.exptime, name, gend, hand, age);
    % Save .mat file of data_aesth struct
    save([datadir,filesep,'s',int2str(ssn),'_r',int2str(runnum),'_',...
        expcode,'_',exp_type,'.dat'],'so','data_aesth','-mat');
end

if ssn~=0 && runnum == 1
    save([datadir,filesep,'s',int2str(ssn),'_','sub_data','.mat'],...
        'top_six','ssn','runnum','name','gend','hand','age','-mat');
        % Saves out above variables to a mat file for easy loading into
        % writing_rating, if runnum is 1.
end

disp(['Total time: ',num2str(timestamp.exptime,4),' seconds']);

fclose('all');

if runnum == 1
    clc
    input('Please wait for the experimenter''s instructions before starting the next task.','s');
    run([codedir,filesep,'writing_rating_desk_v2'])
end