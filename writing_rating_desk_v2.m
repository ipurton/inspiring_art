% Collecting inspiration ratings on writing pieces for NYU 2015 thesis
% Written: 3/16/2015 by Isaac Purton
% email (at) isaacpurton (dot) com
% Based on script by Ed Vessel
%
% Collect ratings on a set of writing pieces using text prompts
% and top 6 rated images from aeshetic_rating
%
% Dependencies: PsychToolbox v3, top_six stim set from aesthetic_rating
% task, word triad stim set (contact experimenter for a copy), stimulus
% order
%
% Revision History:
%   5/15/2015   IP      Fixed summary file
%   4/28/2015   IP      rootdir for imagelab changed to desktop, fixed the
%                       fopen call in the word processor section of the 
%                       experimental task.
%   4/21/2015   IP      Revisions to instructions; added fprintf function
%                       to writing trials in order to write out data during
%                       the task. This prevents crashs from being too
%                       catastrophic.
%   4/20/2015   IP      ACTIVE CODE; added scale instructions, auto-runs
%                       next task
%   4/14/2015   IP      Added gamma table, instructions
%   4/13/2015   IP      Changed data to data_wri, data.wri to data_wri.txt
%   4/12/2015   IP      Formatting/cleaning
%   4/12/2015   IP      Added visual warning for writing task.
%   4/9/2015    IP      Fixes to characters per line, msg/string display,
%                       flexibility of font AR and name, and word processor
%                       timer. Visual warning needs to be added in.
%   4/8/2015    IP      Switched to fixed-width fonts; fixed line spacing
%                       and characters per line in word processor. Timer 
%                       issues may be unavoidable.
%   4/7/2015    IP      To fix: line spacing (too large), characters per
%                       line (too small), and write timer (not ending 
%                       properly).
%   4/7/2015    IP      Font fixes for X11 env, fix for HideCursor.
%                       Wrapping isn't working properly; maybe a rect issue
%   4/6/2015    IP      Added fixes for text in Linux; HideCursor problems
%   4/6/2015    IP      First draft of DrawFormattedText added; inter-trial
%                       interval added.
%   4/2/2015    IP      Practice trial for writing is neccesary due to word
%                       processor limitations. 
%                       Figure out DrawFormmatedText.
%   3/31/2015   IP      Issues with printing new lines in triad stimuli;
%                       GetEchoString problems. DrawFormattedText is needed
%                       to support linebreaks for wrapping text, but this
%                       is not a Screen property. Learn how to do this!
%   3/28/2015   IP      Altered stim presentation, loading image names from
%                       top_six variable. Establishing independence.
%   3/28/2015   IP      Added path definitions back in; draft of word triad
%                       loader. Rethink how order are being done.
%   3/24/2015   IP      Draft of GetEchoString
%   3/17/2015   IP      Added timer
%   3/16/2015   IP      First draft

%% Housekeeping
clear all;
close all;
clc;

timestamp.program_start = GetSecs;
    % Gets timestamp for the beginning of this task
rand('state',sum(100*clock));

Screen('Preference', 'SkipSyncTests', 1);
    % Skips syncing tests in PTB

expcode = 'insp';
so_ext = '.mat';
exp_type = 'wri';

pres_time = 10;
    % Set presentation time to 10 seconds
wait_time = 1; 
    % Time between stimulus presentation and response collection
it_time = 30; 
    % Intertrial wait time
fix_time = 0.5; 
    % Fixation point time
resp_max_time = 10;
    % Maximum time allowed for response
write_time = 180;
    % Set time for writing to three minutes
break_trial = 6;
    % Set trial that has a longer break
practice_time = 180;
    % Amount of time provided for the word processor practice
warning_time = 30;
    % At write_time - warning_time, a warning that the end of the trial is 
    % approaching will be displayed
    
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
%     if (strcmp(hostname(1:8),'imagelab') == 1)
%         hostname = 'imagelab';
%     end
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
        SS.fontAR = 0.6; %font aspect ratio
        SS.alphaBlend = 0; %turn off alpha Blending
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
    case 'rabi.cbi.fas.nyu.edu'
        disp('host set to Rabi')
        rootdir=('/CBI/UserData/starrlab/art_physio');
        newRes.width = 1680;
        newRes.height = 1050;
        newRes.hz = 60;
        newRes.pixelSize = 32;
        setScreenNumber = 1;
    case 'rabi.cbi.fas.nyu.edu'
        disp('host set to Rabi')
        rootdir=('/CBI/UserData/starrlab/art_physio');
        newRes.width = 1680;
        newRes.height = 1050;
        newRes.hz = 60;
        newRes.pixelSize = 32;
        setScreenNumber = 1;
        SS.ts = 18;
        SS.tsp = SS.ts*1.8;
    case 'ziggy.local'
        disp('host set to Ziggy')
        rootdir=('/Users/vessel/Dropbox/BRIEFCASE/art_physio/temp_art_physio');
        newRes.width = 1280; %1680;
        newRes.height = 800; %1050;
        newRes.hz = 0;
        newRes.pixelSize = 32;
        setScreenNumber = 0; 
        %load Phillips202p7_B0_C100_gamma.mat;
        %load ViewsonicVE170_B50_C100_gamma.mat;
        SS.ts = 35;
        SS.tsp = SS.ts;
    case 'ziggy_external'
        disp('host set to Ziggy with External Monitor')
        %rootdir = pwd;  %set root to current directory
        rootdir = ('/Users/vessel/EXPERIMENTS/art_physio');
        newRes.width = 1280;
        newRes.height = 1024;
        newRes.hz = 75 ;
        newRes.pixelSize = 32;
        setScreenNumber = 1;
        SS.ts = 18;
        SS.tsp = SS.ts*1.8;
        %gammaTable = [0:(1/255):1]' *[1 1 1]; %NOT using a linearized CLUT
        %load DellUltrasharp_B100_gamma.mat;
        %load DellUltrasharp_OSXCalib_EV_Gamma2.mat; %using settings computed BY OSX for this monitor
        %load DellUltrasharp_OSXCalib_EV_G18_W85k.mat; %using settings computed BY OSX for this monitor
    case 'hockney'
        disp('host set to hockney')
        rootdir=('C:\Users\artlab\Documents\EXPERIMENTS\art_physio');
        newRes.width = 1280;
        newRes.height = 1024;
        newRes.hz = 60;
        newRes.pixelSize = 32;
        setScreenNumber = 0;
        SS.ts = 18;
        SS.tsp = SS.ts*1.8;
        %load Phillips202p7_B0_C100_gamma.mat;
        load ViewsonicVE170_B50_C100_Win7Calib_Jun2013.mat; %NON linear table! set by OS
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
orderdir = ([rootdir,filesep,'orders']);
datadir = ([rootdir,filesep,'Data']);
worddir = ([rootdir,filesep,'word_triads']);
textdir = ([rootdir,filesep,'text']);
addpath(imagedir);
addpath(datadir);
addpath(codedir);
addpath(worddir);
addpath(textdir);
    
%% Get Participant Information, Image Names

disp('Welcome to the Third Task');
ssn = input('Subject number: ');

load([datadir,filesep,'s',int2str(ssn),'_','sub_data','.mat'],'-mat');
    % Loads the image names of the top_six rated images into variable
    % top_six. Also loads subject information.

n_img = length(top_six);

% name = input('Subject Initials: ','s');
% gend = input('Gender (m/f): ','s');
% hand = input('Handedness (l/r): ','s');
% age = input('Age: ');

%% Load Stimulus Order

ordertext = [expcode,'_',exp_type,'_s',int2str(ssn),so_ext];
    % Assigns ordertext
load([orderdir,filesep,ordertext]);
    % Loads word_order variable into workspace
so = word_order;
n_stim = length(so);

%% Load Word Triads
wtFileName = 'word_triads.txt';
    % Defines the filename for the word triad txt document
wtfid = fopen([worddir,filesep,wtFileName]);

wl_temp = textscan(wtfid,'%s','Delimiter','\n');
wl = wl_temp{1};
    % Loads each line of word triads into wl; one word per line
num_triad = (length(wl) ./ 3);
    % Number of triads is equal to number of words/lines in wl

triads = cell(num_triad,1);
wrd_load = [1 2 3];
for ii = 1:num_triad
    triads{ii} = [wl{wrd_load(1)} char(10) wl{wrd_load(2)} char(10) ...
        wl{wrd_load(3)}];
    wrd_load = wrd_load + 3;
        % Generates triads array.
        % triads{ii} will be a single string vector, with a set of three
        % words from the wl variable, each seperated by a carriage return.
end

%% Set Up Screens
% Set screen number
if exist('setScreenNumber', 'var') == 1
    SS.ScreenNumber = setScreenNumber;
else
    SS.ScreenNumber = 1;
end

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
SS.warningColor = [255 0 0];
%SS.text_bgcolor = [200 200 200];
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
    
    ListenChar(2);
        % Suppresses output to command line for word processor section;
        % gets disabled in Clean Up section    
        
    slider.mouseMax = SS.ScreenRect(4); 
        % Set mouse maximum before adjusting monitor settings
    
    % Load normalized gamma table
    if exist('gammaTable', 'var')
        old_gt = Screen('LoadNormalizedGammaTable', SS.ScreenNumber, ...
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
    
    % Declaring margins for word processor
    SS.margin.x = 50; %left/right
    SS.margin.y = 50; %top/bottom
    
    % Set up windows and rect's for stimulus, text, & fixation point
    SS.FixRect = [0 0 fixsize fixsize];
    SS.Fixation = CenterRect(SS.FixRect, SS.ScreenRect);
    fixTex = Screen('MakeTexture',wholeScreen,fixcross);
    
    % Setting font properties
    Screen('TextFont', wholeScreen, SS.fontName);
        % Switched to fixed-width font
    Screen('Preference', 'TextAlphaBlending', SS.alphaBlend);
    
    textsize = [0 0 200 120];
    Screen('TextSize',wholeScreen,SS.ts);
     SS.textrect = CenterRect(textsize + ...
        [0 0 text_border(1) text_border(2)],SS.ScreenRect);
    %[textwin, SS.TextwinRect] = Screen('OpenWindow',SS.ScreenNumber,SS.bgcolor,textrect);
    SS.charPerLine = floor((SS.winWidth - ...
        (2*SS.margin.x))/(SS.ts .* SS.fontAR));
        % Characters in a single line of text; doesn't work with
        % variable-width fonts.
        % Divides width of current window - x margins by the size of the
        % text and rounds down to nearest whole number.
%     lines_per_page = floor((SS.winHeight - (2*SS.margin.y + 2*(SS.ts*SS.tsp)))/(SS.ts*SS.tsp));
    Screen('BlendFunction',wholeScreen,GL_ONE,GL_ZERO);
    oldTextBackgroundColor=Screen('TextBackgroundColor', ...
        wholeScreen,SS.text_bgcolor);

    %set up Warning prompt
    SS.warningPos = [SS.x_max*.9 SS.margin.y];
    SS.warningText = [int2str(warning_time) 's Warning'];
    
    SS.stimsize = SS.ScreenRect([1 1 4 4]) .* (SS.fractScreen);
    
    % Set up response slider for ratings
    % Slider between 0 and 1
    % -1 if no response
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
    
    msg = ['Instructions for Writing Task - Page 1' dblspace...
        'In this task, you will be participating in a creative '...
        'writing task. You will be asked to write freely for three minutes at '...
        'a time in response to ' int2str(n_stim) ' prompts. When only '...
        int2str(warning_time) ' seconds remain for the writing period, a warning will appear at the '...
        'top-right of the screen, as shown above.'  dblspace ... 
        'Press any key to continue.'];
    DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
        SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('DrawText',wholeScreen, SS.warningText, ...
        SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
        SS.text_bgcolor);
    Screen('Flip', wholeScreen);
        % Show Page 1
    KbWait([], 3);
    pause(0.3)
        % Wait for participant response
        
   msg = ['Instructions for Writing Task - Page 2' dblspace ...
        'Imagine that you are participating in a creative writing workshop. ' ...
        'On each trial, you will be given a prompt to serve as inspiration for your writing. '...
        'Your task is to write a short creative piece for each prompt. '...
        'What you write can be related to the prompt in any way you choose. '...
        'However, please avoid simply describing the prompt or your reaction to it. ' ...
        'Your goal is to create something artistically new.'...
        dblspace 'On some trials, the prompt will be a series of words. '...
        'On other trials, the prompt will be a piece of art. '...
        'Your task is the same, regardless of the type of prompt - use that prompt as inspiration for a short piece of creative writing. '...
        'Please think of each new trial as a separate piece, so that by the end '...
        'you have generated a series of independent, short creative writing '...
        'samples, each inspired by a different prompt.' dblspace ...
        'Press any key to continue.'];
    DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
        SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('Flip', wholeScreen);
        % Show Page 2
    KbWait([], 3);
    pause(0.3)
        % Wait for participant response
        
    % Practice word processor
    FlushEvents('keydown');
        % Clears keypress queue
        
    msg = ['Instructions for Writing Task - Page 3' char(10) ...
        char(10) 'Take a moment to familiarize yourself with the word '...
        'processor used in this task. Note that ''enter'' no longer clears '...
        'all text, and instead functions normally. Common typing tools that will NOT work '...
        'include using the mouse to select text, arrow keys, and '...
        'common keyboard shortcuts, such as Ctrl-C and Ctrl-V. Do '...
        'not attempt to use these tools, as they may cause this task '...
        'to not function as intended.' dblspace...
        '(To show the next screen of instructions, press the ~ button on the keyboard. '...
        'Instructions will automatically advance after ' int2str(practice_time / 60) ' minutes.)' ...
        dblspace 'Please try typing. Text will appear below:' dblspace];
    string = ' ';
    output = [msg, string];
        
    DrawFormattedText(wholeScreen, output, SS.margin.x,...
        SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);

    Screen('Flip', wholeScreen);
        % Show Page 3
    
    timer_start = GetSecs;
    timer_end = timer_start + practice_time;
        
    while GetSecs <= timer_end
        % Runs this while loop until timer_end is reached
        isChar = CharAvail;
            % Determines if a character is waiting in the queue
        if isChar
            newChar = GetChar;
                % If there is a pending character, proceed with this
                % script. This allows the loop to expire if the
                % participant is sitting without typing.
            switch (abs(newChar))
                case 8
                    % backspace
                    if strcmp(string, ' ') == 0 || ~isempty(string)
                        string = string(1:length(string) - 1);
                    end
                otherwise
                    % Prints typed character to string
                    string = [string, newChar];
            end%switch
            output = [msg, string];
            DrawFormattedText(wholeScreen, output, SS.margin.x,...
                SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
            Screen('Flip', wholeScreen);
        end%isChar if
        if strcmp(string(end),'`')
            break
        end
    end %END of write timer
    
    pause(0.3)
    
    msg = ['Instructions for Writing Task - Page 4' dblspace ...
        'After writing, you will be asked to rate how inspired you felt during that writing period. '...
        'We are asking you to judge the feeling of inspiration you had while starting your '...
        'creative process - do not judge the prompt itself, and do not judge what you produced. '...
        'For example, a feeling of inspiration might involve a strong desire to '...
        'produce creative writing, and a lack of a feeling of inspiration might '...
        'involve a sense of hesitancy or unwillingness to write.' dblspace...
        'You will be using a slider response scale to rate your level of inspiration. '...
        'Use the far right of the scale if you felt highly inspired, the far left if '...
        'you were not inspired at all, and the middle if you didn''t '...
        'feel strongly one way or the other. '...
        'When rating your feelings of inspiration, we ask that you only '...
        'consider the writing period you just completed. Please feel free to '...
        'use the entire scale.' dblspace ...
        'Press any key to continue.'];
    DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
        SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('Flip', wholeScreen);
        % Show Page 4
    KbWait([], 3);
    pause(0.3)
        % Wait for participant response
    
    msg = ['Instructions for Writing Task - Page 5' dblspace ...
        'You will be given a longer break halfway through this task.' ...
        dblspace 'Press any key to continue.'];
    DrawFormattedText(wholeScreen, msg, SS.margin.x, SS.margin.y,...
        SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('Flip', wholeScreen);
        % Show Page 5
    KbWait([], 3);
    pause(0.3)
        % Wait for participant response
    
    DrawFormattedText(wholeScreen,...
        ['This is the end of the instructions. Please raise your hand if you have any '...
        'further questions. Otherwise, press any key to proceed.'],...
        SS.margin.x,SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
    Screen('Flip', wholeScreen);
    KbWait([], 3);
    pause(0.3)
        % Show Page 6, pause for participant input
    
    %% LOAD STIMULI

    % Initialize variable uses in loader loop
    imgsz = zeros(n_img,3);
    imgratio = zeros(n_img,1);
    img_area = zeros(n_img,1);
    imTex = zeros(n_img,1);
    
    for ii = 1:n_img
        imgname = top_six{ii};
            % Loads image names based on the top_six variable generated
            % during aesthetic-pre. Loaded from top_six variable that was 
            % loaded in from sub_data.
        testimg = imread([imagedir,filesep,imgname]);
            % Reads in image identified by imgname
        imgsz(ii,:) = size(testimg); %width, height, colorchannels
        imgratio(ii) = imgsz(ii,1) / imgsz(ii,2); %ratio of width/height
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
            %scale max area
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
    
    Screen('DrawText',wholeScreen,'Task 3: Creative Writing',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor)
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
    
    % Initializing data
    data_wri.time = 0;
    data_wri.resp = 0;  
    data_wri.stim{1} = '';
    data_wri.txt{1} = '';
    
    %% Trial Loop
    for trial = 1:n_stim
        data_wri.trialstart(trial) = GetSecs - timestamp.experiment_start;
            % Finds the start time of this trial, relative to start of
            % experiment.
            
        % Draw fixation point
        Screen('DrawTexture',wholeScreen,fixTex,[],SS.Fixation);
        Screen('Flip',wholeScreen);
        
        % Draw stimulus
        % Stimulus type alternates (text -> image -> text ...), with a
        % random order of each type of stimulus
        if so(trial,1) == 1
            DrawFormattedText(wholeScreen, triads{so(trial,2)}, 'center', ...
                    'center', SS.textColor, SS.charPerLine, 0, 0, 1.5);
                % If the first column so value is 1, show a text stimuli
        elseif so(trial,1) == 2
            stimrect = CenterRect([0 0 imgsz(so(trial,2),2) ...
                imgsz(so(trial,2),1)],SS.ScreenRect);
            Screen('DrawTexture',wholeScreen,imTex(so(trial,2)),[],stimrect);
                % If the first column so value is 2, show an image stimuli
        end
        
        %wait & flip
        Screen('Flip',wholeScreen,timestamp.experiment_start + ...
            data_wri.trialstart(trial) + fix_time);

        %wait & clear
        Screen('Flip',wholeScreen,timestamp.experiment_start +  ...
            data_wri.trialstart(trial) + fix_time + pres_time);
        %% Collecting Writing Sample
        % Based on source code of GetEchoString from Psychtoolbox v3

        FlushEvents('keydown');
            % Disable keyboard output to matlab window during script
            
        msg = ['Write freely for 3 minutes, based on what ' ...
            'you just viewed:' char(10)];
        string = '';
        output = [msg, string];
        
        DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
        Screen('Flip', wholeScreen, timestamp.experiment_start + ...
            data_wri.trialstart(trial) + fix_time + pres_time + wait_time);
        
        timer_start = timestamp.experiment_start + ...
            data_wri.trialstart(trial) + fix_time + pres_time + wait_time;
        timer_end = timer_start + write_time;
        
        while GetSecs <= timer_end
            % Runs this while loop for the duration of write_time
            isChar = CharAvail;
                % Determines if a character is waiting in the queue
            if isChar
                newChar = GetChar;
                    % If there is a pending character, proceed with this
                    % script. This allows the loop to expire if the
                    % participant is sitting without typing.
                switch (abs(newChar))
                    case 8
                        % backspace
                        % Removes the last typed character
                        if ~isempty(string)
                            string = string(1:length(string)-1);
                        end
                    otherwise
                        % Prints typed character to string
                        string = [string, newChar];
                end
                output = [msg, string];
            end%isChar if
            if GetSecs < timer_end - 30
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                    % Wrap is set to SS.charPerLine, line spacing to 1.5
                Screen('Flip', wholeScreen);
            elseif GetSecs >= timer_end - 30
                Screen('DrawText',wholeScreen, SS.warningText, ...
                    SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
                    SS.text_bgcolor);
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                Screen('Flip', wholeScreen);
                    % If there is less than 30 seconds remaining in trial,
                    % show a red 30 second warning at the top right.
            end
        end %END of write timer
        data_wri.txt{trial} = output((length(msg) + 1):end);
            % Stores written string in data array, omitting msg and first 
            % line break.
        
        % Writes out each trial to a seperate text file; helps prevent
        % crashes from ruining the experiment
        toWrite = fopen([textdir, filesep, 's', int2str(ssn), '_text_t', int2str(trial),'.txt'],'w');
        fprintf(toWrite, '%s', data_wri.txt{trial});
        fclose(toWrite);
        
        Screen('Flip', wholeScreen, timer_end)
            % Flip to blank screen

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
        Screen('Drawtext',wholeScreen,'were you inspired?',...
            SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,...
            SS.text_bgcolor);
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
        Screen('Flip',wholeScreen,timer_end + wait_time);       

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
            Screen('Drawtext',wholeScreen,'How strongly',SS.textrect(1),...
                SS.textrect(2),SS.textColor,SS.text_bgcolor);
            Screen('Drawtext',wholeScreen,'were you inspired?',...
                SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,...
                SS.text_bgcolor);
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
                data_wri.resp(trial) = sliderResp;
                data_wri.lock(trial) = 1;
                data_wri.time(trial) = tim - RespStart; 
                    % time measured from offset of image/resp cue
            case 0 %Response NOT locked in
                data_wri.resp(trial) = current_pos;
                %data{block}.resp(trial) = sliderResp; %FIX
                data_wri.lock(trial) = 0;
                data_wri.time(trial) = -1; 
                    % subject didn't lock in the response (timeout)
            case -1 %subj didn't move slider at all
                data_wri.resp(trial) = 0;
                data_wri.lock(trial) = -1;
                data_wri.time(trial) = 0;
        end
        
        disp(['Trial: ',int2str(trial), '  Response: ',...
            num2str(data_wri.resp(trial),2), '  Lock: ',...
            int2str(data_wri.lock(trial))]);

%% Inter-trial interval
        
        it_start = GetSecs;
        it_end = it_start + it_time;

        if trial == break_trial
            Screen('DrawText',wholeScreen,'End of Block 1',...
                SS.textrect(1),SS.textrect(2),SS.textColor,...
                SS.text_bgcolor);
            Screen('DrawText',wholeScreen,'Take a longer break',...
                SS.textrect(1),SS.textrect(2),SS.textColor,...
                SS.text_bgcolor);
            Screen('DrawText',wholeScreen,'Hit any key to continue',...
                SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,...
                SS.text_bgcolor);
            Screen('Flip',wholeScreen);
            KbWait([],3);
            Screen('Flip',wholeScreen);
            pause(1);
                % At break_trial, pause until input is received from
                % participant.
        elseif trial ~= n_stim && trial ~= break_trial
            while GetSecs <= it_start + it_time
            Screen('DrawText',wholeScreen,'Take a short break',...
                SS.textrect(1),SS.textrect(2),SS.textColor,...
                SS.text_bgcolor);
                if GetSecs >= it_end - 10
                    Screen('DrawText',wholeScreen,...
                        '10 seconds to next trial',SS.textrect(1),...
                        SS.textrect(2)+SS.tsp,SS.textColor,...
                        SS.text_bgcolor);
                        % Shows warning when 10 seconds remain
                end
            Screen('Flip',wholeScreen);
                % On all other trials (except final trial), pause for 
                % it_time (currently 30s).
            end
        end
        
        if trial ~= n_stim
            Screen('DrawText',wholeScreen,'Get ready!',SS.textrect(1),...
                SS.textrect(2),SS.textColor,SS.text_bgcolor);
            Screen('Flip',wholeScreen);
            pause(3)
                % Shows 'Get Ready' before ending loop and continuing to next
                % trial, unless this is the last trial
        end

        FlushEvents('keydown');

    end %END trial loop
        
    timestamp.program_end = GetSecs;
    timestamp.exptime = timestamp.program_end - timestamp.experiment_start;

    Screen('Drawtext',wholeScreen,'End of Third Task',SS.textrect(1),...
        SS.textrect(2),SS.textColor,SS.text_bgcolor);
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
    ListenChar;
    
    catch % Cleanup if something goes wrong above.
        sprintf('Error: %s', lasterr)
        Priority(0);
        for ii = 1:n_stim
            ShowCursor;
        end
        Screen('CloseAll');
        Screen('Resolution',SS.ScreenNumber,oldRes.width,oldRes.height,...
            oldRes.hz,oldRes.pixelSize);
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
    
end %try loop

%% Write out data

% Write text to summary file
% ssn name gend hand age
% trials n_stim heapnum
if ssn~=0;
    sumfile = [datadir, filesep, expcode,'_',exp_type,'_summary.txt'];
    sfid = fopen(sumfile,'at');
    fprintf(sfid,'\n %d\t %s\t %d\t %4.1f\t %s\t %s\t %s\t %d\n', ssn, date, ...
        n_stim, timestamp.exptime, name, gend, hand, age);
    %save .mat file of main data sets
    %sl, sc, M, data, n_comp
    save([datadir,filesep,'s',int2str(ssn),'_',expcode,'_',exp_type,...
        '.dat'],'so','data_wri','-mat');
end

disp(['Total time: ',num2str(timestamp.exptime,4),' seconds']);

fclose('all');

clc

input('Please wait for the experimenter''s instructions before starting the next task.','s');
run([codedir,filesep,'aesthetic_rating_desk_v3'])