% Collecting responses on an AUT for NYU 2015 thesis
% Written: 4/12/2015 by Isaac Purton
% email (at) isaacpurton (dot) com
% Based on script by Ed Vessel
%
% Collects responses made by participants to a specific prompt on an
% alternate uses task (AUT). Prompts are currently shown as text (eg. 'a
% single brick').
%
% Dependencies: PsychToolbox v3
%
% Revisions
%   5/15/2015   IP      Formatting; redid summary file so that it isn't
%                       subject specific.
%	5/1/2015	IP 		Revisions to instructions
%   4/28/2015   IP      rootdir for imagelab changed to desktop
%   4/20/2015   IP      ACTIVE CODE; auto-runs aesth task, revised
%                       instructions
%   4/13/2015   IP      Changed data to data_aut, fixed warning, added
%                       instructions.
%   4/12/2015   IP      Initial code. Rect for responses needs to be
%                       tweaked, images for AUT prompt need to be 
%                       considered. SO needs to be created.

%% Housekeeping
clear all
close all

timestamp.program_start = GetSecs;
rand('state',sum(100*clock));

Screen('Preference', 'SkipSyncTests', 1);

expcode = 'insp';
so_ext = '.mat';
exp_type = 'aut';

pres_time = 10;
    % Set presentation time to 10 seconds
wait_time = 1; 
    % Time between stimulus presentation and response collection
it_time = 30; 
    % Intertrial wait time
fix_time = 0.5; 
    % Fixation point time
write_time = 180;
    % Set time for writing to three minutes
break_trial = 6;
    % Set trial that has longer break
warning_time = 30;
	% Set the desired time to display a warning that the writing
	% period is about to end
dblspace = [char(10) char(10)];
    % Shorthand for putting a full line break between two paragraphs
    
SS.fractScreen = 0.9; 
    % Percentage of Screen image uses
SS.max_area = .75;  
    % Max percentage of stimrect which a stimulus can occupy

%% Set Computer Specific Information
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
autdir = ([rootdir,filesep,'AUT_stim']);
addpath(imagedir);
addpath(datadir);
addpath(codedir);
addpath(autdir);
    
%% Get Participant Information

ssn = input('Subject number: ');
name = input('Subject Initials: ','s');
gend = input('Gender (m/f): ','s');
hand = input('Handedness (l/r): ','s');
age = input('Age: ');

%% Load Stimulus Order
try
    ordertext = [expcode,'_',exp_type,'_s',int2str(ssn),so_ext];
        % Assigns ordertext
    load([orderdir,filesep,ordertext]);
        % Loads word_order variable into workspace
    so = aut_order;
catch
    so = 1;
        % If order file doesn't exist, so = 1
		% At present, this AUT task only uses one stimulus, so
		% no full order file is actually made.
end

n_stim = length(so);

%% Load AUT Stimuli names

autFileName = 'stim_names.txt';
autfid = fopen([autdir,filesep,autFileName]);

aut_temp = textscan(autfid,'%s','Delimiter','\n');
autl = aut_temp{1};
    % Loads each line of aut stimuli into autl

stim = cell(n_stim,1);
for ii = 1:n_stim
    stim{ii} = autl{ii};
        % Loads each line of autl into a seperate stim cell
        % Generates stim array.
end

%% Set Up Screens
% Set screen number
if exist('setScreenNumber', 'var') == 1
    SS.ScreenNumber = setScreenNumber;
else
    SS.ScreenNumber = 1;
end
% Set up preferences, pixel depth, etc.
oldRes = Screen('Resolution',SS.ScreenNumber,newRes.width,newRes.height,newRes.hz,newRes.pixelSize);

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
        old_gt = Screen('LoadNormalizedGammaTable', SS.ScreenNumber, gammaTable);
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
    
    % Declaring margins
    SS.margin.x = 50; %left/right
    SS.margin.y = 50; %top/bottom
    
    % Set up windows and rect's for stimulus, text, & fixation point
    SS.FixRect = [0 0 fixsize fixsize];
    SS.Fixation = CenterRect(SS.FixRect, SS.ScreenRect);
    fixTex = Screen('MakeTexture',wholeScreen,fixcross);
    
    % Setting font properties
    Screen('TextFont', wholeScreen, SS.fontName);
    Screen('Preference', 'TextAlphaBlending', SS.alphaBlend);
    
    textsize = [0 0 200 120];
    Screen('TextSize',wholeScreen,SS.ts);
    SS.textrect = CenterRect(textsize + [0 0 text_border(1) text_border(2)],SS.ScreenRect);
    %[textwin, SS.TextwinRect] = Screen('OpenWindow',SS.ScreenNumber,SS.bgcolor,textrect);
    SS.charPerLine = floor((SS.winWidth - (2*SS.margin.x))/(SS.ts .* SS.fontAR));
        % Characters in a single line of text; doesn't work with
        % variable-width fonts.
%     SS.charPerLine = 100;
%     lines_per_page = floor((SS.winHeight - (2*SS.margin.y + 2*(SS.ts*SS.tsp)))/(SS.ts*SS.tsp));
    Screen('BlendFunction',wholeScreen,GL_ONE,GL_ZERO);
    oldTextBackgroundColor=Screen('TextBackgroundColor', wholeScreen,SS.text_bgcolor);

    %set up Warning prompt
%     SS.warningPos = [SS.x_max*.9 (SS.y_max - SS.margin.y)];
        % Bottom-right of screen
    SS.warningPos = [SS.x_max .* 0.9, SS.y_max .* 0.5];
        % Middle-right of screen
    SS.warningText = [int2str(warning_time) 's Warning'];
    
    SS.usesPos = [SS.x_max*.7 SS.margin.y];
        % Sets position of visible uses counter
    
    SS.stimsize = SS.ScreenRect([1 1 4 4]) .* (SS.fractScreen);
    
    SS.stringRect = [SS.margin.x , SS.y_max - SS.margin.y - (SS.tsp .* 3), ...
            SS.x_max - SS.margin.x, SS.y_max - SS.margin.y];
            % left, top, right, bottom
            % Forms a rect of width equal to window width - x margin * 2 and
            % height equal to three lines of text, centered width wise and at
            % bottom of screen.
    
    %% Instructions
    % Show instructions for the AUT task
    
	pg_count = 1;
		% Keep track of the current page
	msg = ['Instructions for Alternate Uses Task (AUT) - Page ' int2str(pg_count) dblspace ...
        'In this task, you will be asked to give multiple '...
        'unusual uses for a single object. An unusual use is one that '...
        'is neither ordinary (eg. ''holding together papers'' as a use '...
        'for ''paperclip'') nor impossible (eg. ''flying into space'').'...
        dblspace 'Press any key to continue'];
    DrawFormattedText(wholeScreen, msg, ...
        SS.margin.x, SS.margin.y,SS.textColor, SS.charPerLine, 0, 0, 1.5)
		% Show msg. 
    Screen('Flip', wholeScreen);
    KbWait([], 3);
    pause(0.3)
	
	pg_count = pg_count + 1;
    msg = ['Instructions for AUT - Page ' int2str(pg_count) dblspace...
        'You will have ' int2str(write_time / 60) ' minutes to provide as many uses as '...
        'you can. When only ' int2str(warning_time) ' seconds remain for the task, a '...
        'warning will appear in the center-right of the screen, as shown below.' char(10)...
        'Do not worry about repeating ideas; simply focus '...
        'on writing out as many unusual uses as you can think of in the time provided.' ...
        dblspace 'If you are not sure whether a use that you have thought of is '...
		'unusual or impossible, please write it down anyway.' dblspace...
		'Press any key to continue'];
    DrawFormattedText(wholeScreen, msg, ...
        SS.margin.x, SS.margin.y,SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('DrawText',wholeScreen, SS.warningText, ...
        SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
        SS.text_bgcolor);
		% Draws the warning message
    Screen('Flip', wholeScreen);
    KbWait([], 3);
    pause(0.3)
	
	pg_count = pg_count + 1;
	msg = ['Instructions for AUT - Page ' int2str(pg_count) dblspace...
		'For this task, you will use a light word processing program to '...
		'submit uses. You will submit uses one at a time.' dblspace...
		'To submit a use, you will press the ''enter'' key on the keyboard '...
		'after you finish typing it out. Hitting ''enter'' will '...
		'clear the word processor but don''t worry: your data has not been '...
		'lost. Submitting a use will cause a counter to tick up. '...
		'The counter will be shown in the upper right '...
		'of the screen after at least one use has been submitted.' dblspace...
		'During this task, please remember to submit one use at a time. '...
		dblspace 'Next, you will have the opportunity to practice using this '...
		'task''s word processor.' dblspace 'Press any key to continue'];
    DrawFormattedText(wholeScreen, msg, ...
        SS.margin.x, SS.margin.y,SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('DrawText',wholeScreen, SS.warningText, ...
        SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
        SS.text_bgcolor);
    Screen('Flip', wholeScreen);
    KbWait([], 3);
    pause(0.3)
    
    % Practice word processor
    FlushEvents('keydown');
        % Clears keypress queue
    
	pg_count = pg_count + 1;	
    msg = ['Instructions for AUT - Page ' int2str(pg_count) dblspace ...
        'Take a moment to familiarize yourself with the word '...
        'processor used in this task.' char(10)... 
		'Remember that hitting ''enter'' will clear and submit all text.'...
        dblspace 'Common typing tools that will NOT work in this task '...
        'include using the mouse to select text, arrow keys, and '...
        'common keyboard shortcuts, such as Ctrl-C and Ctrl-V. Do '...
        'not attempt to use these tools, as they may cause this task '...
        'to not function as intended.' dblspace ...
        '(To show the next screen of instructions, press the ~ button on the keyboard. '...
        'Instructions will automatically advance after two minutes.)' ...
        dblspace 'Please try typing. Text will appear below:' dblspace];
    string = ' ';
    output = [msg, string];
        
    DrawFormattedText(wholeScreen, output, SS.margin.x,...
        SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);

    Screen('Flip', wholeScreen);
    
    timer_start = GetSecs;
    timer_end = timer_start + 120;
	
	uses_counter = 1;
        
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
                case {13, 3, 10}
                    % enter/return
					uses_counter = uses_counter + 1;
					string = ' ';
                        % When enter is pressed, clear the input field
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
        end%isChar if
        if strcmp(string(end),'`')
            break
        end
		if uses_counter < 2
			DrawFormattedText(wholeScreen, output, SS.margin.x,...
				SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
			Screen('Flip', wholeScreen);
		elseif uses_counter >= 2
			Screen('DrawText',wholeScreen, [int2str(uses_counter - 1)...
				' use(s) submitted!'], SS.usesPos(1), SS.usesPos(2),...
				SS.textColor,SS.text_bgcolor);
				% As uses are submitted, show user feedback about how
				% many uses they've submitted.
			DrawFormattedText(wholeScreen, output, SS.margin.x,...
				SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
			Screen('Flip', wholeScreen);
		end
    end %END of write timer
    
    pause(0.3)
    
	pg_count = pg_count + 1;
    msg = ['Instructions for AUT - Page ' int2str(pg_count) dblspace...
        'Reminder: when submitting uses in this task, please be sure to submit '...
		'only one use at a time.' dblspace...
		'Press any key to continue'];
    DrawFormattedText(wholeScreen, msg, ...
        SS.margin.x, SS.margin.y,SS.textColor, SS.charPerLine, 0, 0, 1.5)
    Screen('DrawText',wholeScreen, SS.warningText, ...
        SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
        SS.text_bgcolor);
    Screen('Flip', wholeScreen);
        % Show Page
    KbWait([], 3);
    pause(0.3)
	
    DrawFormattedText(wholeScreen,...
        ['This is the end of the instructions. Please raise your hand if you have any '...
        'further questions. Otherwise, press any key to proceed.'],...
        SS.margin.x,SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
    Screen('Flip', wholeScreen);
    KbWait([], 3);
    pause(0.3)
        % Show Page
        
    FlushEvents('keydown');
            
    %% LOAD STIMULI
    % Only needed if images are used for the AUT
%     imgsz = zeros(n_stim,3);
%     imgratio = zeros(n_stim,1);
%     img_area = zeros(n_stim,1);
%     imTex = zeros(n_stim,1);
%     
%     for ii = 1:n_stim
%         imgname = imglist{ii};
%         testimg = imread([imagedir,filesep,imgname]);
%         imgsz(ii,:) = size(testimg); %width, height, colorchannels
%         imgratio(ii) = imgsz(ii,1) / imgsz(ii,2); %ratio of width/height
%         if imgsz(ii,1) > SS.stimsize(3) % if image width is bigger than stimrect width
%             imgsz(ii,1) = SS.stimsize(3);
%             imgsz(ii,2) = imgsz(ii,1) ./ imgratio(ii);
%         end
%         if imgsz(ii,2) > SS.stimsize(4)
%             imgsz(ii,2) = SS.stimsize(4);
%             imgsz(ii,1) = imgsz(ii,2) .* imgratio(ii);
%         end
%         img_area(ii) = imgsz(ii,1) .* imgsz(ii,2);
%         if (img_area(ii) > (SS.max_area .* SS.stimsize(3) .* SS.stimsize(4))) %scale max area
%            side_rescale = sqrt((SS.max_area .* SS.stimsize(3).* SS.stimsize(4)) ./ img_area(ii));
%            imgsz(ii,1) = imgsz(ii,1) .* side_rescale;
%            imgsz(ii,2) = imgsz(ii,2) .* side_rescale;
%         end
%         imTex(ii) = Screen('MakeTexture',wholeScreen,testimg);
%             % Populates imTex with an index value for each image
%             % This index value can be called with DrawTexture
%         % Display progress
%         Screen('Drawtext',wholeScreen,['Loading Images: ',int2str(round((ii/20)*100)),'%'],SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
%         Screen('Flip', wholeScreen);  %show text
%     end
%     
%     Screen('Flip',wholeScreen);  %clear text
    
    Screen('DrawText',wholeScreen,'Task 1: AUT',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor)
    Screen('Drawtext',wholeScreen,'Hit any key to start',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
    Screen('Flip', wholeScreen);  %show text
    
    KbWait([], 3);
    pause(0.5)
    
    Screen('Flip',wholeScreen);
    
    pause(1);
    escape = 0;
    
    timestamp.experiment_start = GetSecs;
    
    % Initializing data
    % Switched to specifying task to make each data item more identifiable
    data_aut.time = 0;
    data_aut.resp = 0;  
%     data_aut.image{1} = '';
        % This is not currently used
    data_aut.stim{1} = '';
    data_aut.uses{1} = '';
    
    %% Stimulus presentation
    for trial = 1:n_stim
        
        data_aut.trialstart(trial) = GetSecs - timestamp.experiment_start;
        
        % Draw fixation point
        Screen('DrawTexture',wholeScreen,fixTex,[],SS.Fixation);
        Screen('Flip',wholeScreen);
        
        % Draw stimulus
        DrawFormattedText(wholeScreen, stim{so(trial)}, 'center',...
                    'center', SS.textColor, SS.charPerLine, 0, 0, 1.5);
                % Writes AUT stim name at center of screen
%         stimrect = CenterRect([0 0 imgsz(so(trial),2) imgsz(so(trial),1)],SS.ScreenRect);
%         Screen('DrawTexture',wholeScreen,imTex(so(trial)),[],stimrect);

        %wait & flip
        Screen('Flip',wholeScreen,timestamp.experiment_start + data_aut.trialstart(trial) + fix_time);

        %wait & clear
        Screen('Flip',wholeScreen,timestamp.experiment_start +  data_aut.trialstart(trial) + fix_time + pres_time);
        %% Collecting Writing Sample
        % Based on source code from GetEchoString in PsychToolbox v3

        FlushEvents('keydown');
            
        msg = ['Please provide as many different unusual uses' char(10)...
            'as you can for the object that was just indicated. ' ...
            'An unusual use is one that is neither obvious nor impossible. ' ...
            'Press ''enter'' to submit a use once it has been typed. ' ...
            'Please provide only one use at a time.' dblspace...
			'Response:'];
            
        string = ' ';
        output = [msg, string];
        
        DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);

        Screen('Flip', wholeScreen, timestamp.experiment_start + ...
            data_aut.trialstart(trial) + fix_time + pres_time + wait_time);

        timer_start = timestamp.experiment_start + ...
            data_aut.trialstart(trial) + fix_time + pres_time + wait_time;
        timer_end = timer_start + write_time;

        uses_counter = 1;
        
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
                    case {13, 3, 10}
                        % enter/return
                        data_aut.uses{uses_counter} = string;
                        uses_counter = uses_counter + 1;
                        string = ' ';
                            % When enter is pressed, clear the input field
                            % and record the typed use in data.uses
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
            end%isChar if
            if uses_counter < 2 && GetSecs < timer_end - warning_time
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                Screen('Flip', wholeScreen);
            elseif uses_counter >= 2 && GetSecs < timer_end - warning_time
                Screen('DrawText',wholeScreen, [int2str(uses_counter - 1)...
                    ' use(s) submitted!'], SS.usesPos(1), SS.usesPos(2),...
                    SS.textColor,SS.text_bgcolor);
                    % As uses are submitted, show user feedback about how
                    % many uses they've submitted.
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                Screen('Flip', wholeScreen);
            elseif uses_counter >= 2 && GetSecs >= timer_end - warning_time
                Screen('DrawText',wholeScreen, [int2str(uses_counter - 1)...
                    ' use(s) submitted!'], SS.usesPos(1), SS.usesPos(2),...
                    SS.textColor,SS.text_bgcolor);
                    % As uses are submitted, show user feedback about how
                    % many uses they've submitted.
                Screen('DrawText',wholeScreen, SS.warningText, ...
                    SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
                    SS.text_bgcolor);
                    % If there is less than 30 seconds remaining in trial,
                    % show a red 30 second warning at the top right.
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                Screen('Flip', wholeScreen);
            elseif GetSecs >= timer_end - warning_time
                Screen('DrawText',wholeScreen, SS.warningText, ...
                    SS.warningPos(1), SS.warningPos(2),SS.warningColor,...
                    SS.text_bgcolor);
                    % If there is less than 30 seconds remaining in trial,
                    % show a red 30 second warning at the top right.
                DrawFormattedText(wholeScreen, output, SS.margin.x,...
                    SS.margin.y, SS.textColor, SS.charPerLine, 0, 0, 1.5);
                Screen('Flip', wholeScreen);
            end%timer/uses count if
            
        end %END of write timer
        
        data_aut.uses{uses_counter} = string;
            % Captures any string text left on screen at end of timer
        
        data_aut.stim{trial} = stim{so(trial)};
            % Captures name of the stimuli
        
        Screen('Flip', wholeScreen, timer_end)
            % Flip to blank screen

        %% Inter-trial interval
        % Not presently used, but good to have just in case
        
        it_start = GetSecs;
        it_end = it_start + it_time;

        if trial == break_trial
            Screen('DrawText',wholeScreen,'Take a short break',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
            Screen('DrawText',wholeScreen,'Hit any key to continue',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
            Screen('Flip',wholeScreen);
            KbWait([],3);
            Screen('Flip',wholeScreen);
            pause(1);
                % At break_trial, pause until input is received from
                % participant.
        elseif trial ~= n_stim && trial ~= break_trial
            while GetSecs <= it_start + it_time
            Screen('DrawText',wholeScreen,'Take a short break',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
                if GetSecs >= it_end - 10
                    Screen('DrawText',wholeScreen,'10 seconds to next trial',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
                        % Shows warning when 10 seconds remain
                end
            Screen('Flip',wholeScreen);
                % On all other trials (except final trial), pause for 
                % it_time (currently 30s).
            end
        end
        
        if trial ~= n_stim
            Screen('DrawText',wholeScreen,'Get ready!',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
            Screen('Flip',wholeScreen);
            pause(3)
                % Shows 'Get Ready' before ending loop and continuing to next
                % trial, unless this is the last trial
        end
        
        FlushEvents('keydown');

    end %END trial loop
        
    timestamp.program_end = GetSecs;
    timestamp.exptime = timestamp.program_end - timestamp.experiment_start;

    Screen('Drawtext',wholeScreen,'End of AUT',SS.textrect(1),SS.textrect(2),SS.textColor,SS.text_bgcolor);
    Screen('Drawtext',wholeScreen,'Press any key to continue',SS.textrect(1),SS.textrect(2)+SS.tsp,SS.textColor,SS.text_bgcolor);
    Screen('Flip',wholeScreen);
    KbWait([],3);
    Screen('Flip',wholeScreen);   

    %% CLEAN UP
    %close windows & return pixel depth
    for ii = 1:n_stim
		ShowCursor
    end
    Screen('CloseAll');
    Screen('Resolution',SS.ScreenNumber,oldRes.width,oldRes.height,oldRes.hz,oldRes.pixelSize);
    if exist('old_gt')
		Screen('LoadNormalizedGammaTable',SS.ScreenNumber,old_gt)
    end
    ListenChar;
    
    catch % Cleanup if something goes wrong above.
        sprintf('Error: %s', lasterr)
        Priority(0);
        for ii = 1:n_stim
            ShowCursor
        end
        Screen('CloseAll');
        Screen('Resolution',SS.ScreenNumber,oldRes.width,oldRes.height,oldRes.hz,oldRes.pixelSize);
        if exist('old_gt')
            Screen('LoadNormalizedGammaTable',SS.ScreenNumber,old_gt)
        end
        ListenChar(0);

        save DebugVars;
        error_struct = lasterror;
        error_output = [];
        for ii = 1:length(error_struct.stack)
            error_lines = error_struct.stack(ii);
            error_output = [error_output, sprintf('file: %s\t\t\tline: %d\n',error_lines.name, error_lines.line)];
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
    save([datadir,filesep,'s',int2str(ssn),'_',expcode,'_',exp_type,'.dat'],'so','data_aut','-mat');
end

disp(['Total time: ',num2str(timestamp.exptime,4),' seconds']);

fclose('all');

%% Run next script

clc

input('Please wait for the experimenter''s instructions before starting the next task.','s');
run([codedir,filesep,'aesthetic_rating_desk_v3'])