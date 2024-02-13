function [cfg] = parameters( USE_debug, USE_synctest )
% `parameters.m` loads the parameters required to run the COG FATIGUE exp
% so it can be displayed on the current screen. It also initiates
% PsychToolBox and opens a window for the experiment to take place.

%% INITIALISE SCREEN

% Window size
cfg.window_size = [];

% Select screen
cfg.screens = Screen('Screens');

if size(cfg.screens,2) == 1
    % Subsets window on main screen for single-monitor setups
    cfg.window_size = [10 10 950 650]; 
end

cfg.computer = Screen('Computer');
cfg.version = Screen('Version');

% Screen setup using Psychtoolbox is notoriously clunky in Windows,
% particularly for dual-monitors. This relates to the way Windows handles 
% multiple screens (it defines a 'primary display' independent of 
% traditional numbering) and numbers screens in the reverse order to 
% Linux/Mac.

% The 'isunix' function should account for the reverse numbering but if
% you're using a second monitor you will need to define a 'primary display'
% using the Display app in your Windows Control Panel. See the psychtoolbox
% system reqs for more info: http://psychtoolbox.org/requirements/#windows

if isunix
    if USE_debug
        cfg.screen_num = max(cfg.screens);
    else
        cfg.screen_num = min(cfg.screens); % Attached monitor
        % cfg.screen_num = max(cfg.screens); % Main display (eg, laptop)
    end
else
    if USE_debug
        cfg.screen_num = min(cfg.screens);
    else
        cfg.screen_num = max(cfg.screens);
        % cfg.screen_num = min(cfg.screens);
    end
end

% Define colours
cfg.white = WhiteIndex(cfg.screen_num);
cfg.black = BlackIndex(cfg.screen_num);
cfg.gray = round((cfg.white + cfg.black)/2);
cfg.highlight = [255 255 0]; % Yellow RGB

% Fix for unexpected contrast settings
if round(cfg.gray) == cfg.white
    cfg.gray = cfg.black;
end

cfg.window_colour = cfg.black;

% Used to debug syncerrors
if ~USE_synctest
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

%('OpenWin', WinPtr, WinColour, WinRect, PixelSize, AuxBuffers, Stereo)
[cfg.win_ptr, cfg.win_rect] = Screen('OpenWindow', ...
    cfg.screen_num, cfg.window_colour, cfg.window_size, [], 2, 0);

% Find window size
[cfg.width, cfg.height] = Screen('WindowSize', cfg.win_ptr);

% Define center X & Y
[cfg.xCentre , cfg.yCentre] = RectCenter(cfg.win_rect);

% Font
Screen('TextFont', cfg.win_ptr, 'Courier');

% Text size
cfg.text_size = 35;
cfg.operation_text = 50;
cfg.minor_text = 18;
Screen('TextSize', cfg.win_ptr, cfg.text_size);

cfg.frame_rate = Screen('NominalFrameRate', cfg.win_ptr,1); 

% Estimate of monitor flip interval for specified window
[cfg.flip_interval, cfg.flip_samples, cfg.flip_stddev]...
    = Screen('GetFlipInterval', cfg.win_ptr);

%% CORE PRESENTATION INTERVALS 

% Seconds that the effort level is displayed for during training
cfg.effort_time = 1; 

% Seconds to make REST or WORK decision (4secs in original study)
cfg.work_decision_time = 4;

% Amount of time that each operand appears
cfg.operation_time = 0.75;

% Time to make OPERATION response
cfg.response_time = 1.5;

% Time to view feedback on your OPERATION response
cfg.feedback_time = 1.2;

% Seconds to make SUBJECTIVE FATIGUE response (4secs in original study)
cfg.vas_time = 4;

% Adjusts how quickly the VAS bar moves when arrow is pressed
% Lower is more sensitive
cfg.vas_sensitivity = 0.045;

% Intertrial interval (0.5secs in original study)
cfg.intertrial_time = 0.5;

% Amount of time between operands
cfg.interstimulus_interval = 0.4;

% Amount of time to wait on missed WORK decisions or 'decision_only' trials
% 6 Operands and 5 ISIs
cfg.stoppage = (cfg.interstimulus_interval+cfg.operation_time)*6 - ...
    cfg.interstimulus_interval;

%% RESPONSE KEYBOARD SETTINGS

KbName('UnifyKeyNames')

% Can change this to response box or whatever keys
cfg.leftKey = KbName('LeftArrow');
cfg.rightKey = KbName('RightArrow');
cfg.upKey = KbName('UpArrow');
cfg.fatigueKey = KbName('LeftControl');

%% MEASURES DEGREES VISUAL ANGLE
[x,y] = Screen('DisplaySize',cfg.win_ptr);
cfg.xDimCm = x/10;
cfg.yDimCm = y/10;

% Expect participant to be sitting 60cm from screen (visual angle test)
cfg.distanceCm = 60;

% Calculate visual angle
% Unintutitive order of operations but have confirmed #ok
cfg.visualAngleDegX = atan(cfg.xDimCm/(2*cfg.distanceCm))/pi*180*2;
cfg.visualAngleDegY = atan(cfg.yDimCm/(2*cfg.distanceCm))/pi*180*2;

% Calculate visual angle per degree
cfg.visualAnglePixelPerDegX = cfg.width/cfg.visualAngleDegX;
cfg.visualAnglePixelPerDegY = cfg.height/cfg.visualAngleDegY;

% Usually mean pixels per degree is reported in papers
cfg.pixelsPerDegree = mean([cfg.visualAnglePixelPerDegX,... 
    cfg.visualAnglePixelPerDegY]); 

%% RESPONSE BOXES

% This value is used to separate boxes by magnitudes of visual angle
cfg.box_length = round(cfg.pixelsPerDegree * 2.5); % 2.5 degrees visual angle

cfg.box_width = 6;

% Can play around with the sizer value to rescale response boxes
% Sizer represents scale relative to text (e.g., 2 = 200% textbounds)
sizer = 5; % Higher number == larger box

% Determine box sizes (as proportion of text and sizer)
Screen('TextSize', cfg.win_ptr, (cfg.text_size * sizer));

[~,~,cfg.box_size]=DrawFormattedText(cfg.win_ptr,'X',...
    'center', 'center');

%% LOAD INSTRUCTION IMAGES & MAKE TEXTURES

image_location = 'addons/instructions/';

instruct_practice = imread([image_location 'instructions_practice.png']);
instruct_decisions = imread([image_location 'instructions_decisions.png']);
instruct_nofatigue = imread([image_location 'instructions_nofatigue.png']);
instruct_fatigue = imread([image_location 'instructions_fatigue.png']);

introduction = imread([image_location 'instructions_overall.png']);
intermission = imread([image_location 'intermission.png']);

cfg.instruct.practice_effort = Screen('MakeTexture',cfg.win_ptr,...
    instruct_practice);
cfg.instruct.practice_decisions = Screen('MakeTexture',cfg.win_ptr,...
    instruct_decisions);
cfg.instruct.nofatigue = Screen('MakeTexture',cfg.win_ptr,...
    instruct_nofatigue);
cfg.instruct.fatigue = Screen('MakeTexture',cfg.win_ptr,...
    instruct_fatigue);

cfg.instruct.introduction = Screen('MakeTexture',cfg.win_ptr,...
    introduction);
cfg.instruct.intermission = Screen('MakeTexture',cfg.win_ptr,...
    intermission);

%% LOAD EFFORT IMAGES & MAKE TEXTURES
% Not the most efficient method but it's effective

effort_location = 'addons/effort_levels/';

effort_img.l1 = imread([effort_location 'effort1.png']);
effort_img.l2 = imread([effort_location 'effort2.png']);
effort_img.l3 = imread([effort_location 'effort3.png']);
effort_img.l4 = imread([effort_location 'effort4.png']);
effort_img.l5 = imread([effort_location 'effort5.png']);
effort_img.l6 = imread([effort_location 'effort6.png']);

cfg.effort.l1 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l1);
cfg.effort.l2 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l2);
cfg.effort.l3 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l3);
cfg.effort.l4 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l4);
cfg.effort.l5 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l5);
cfg.effort.l6 = Screen('MakeTexture',cfg.win_ptr,...
    effort_img.l6);

end