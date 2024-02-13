%% COGNITIVE EFFORT-BASED DECISION-MAKING TASK
% Created 2019-03-05: Julian Matthews
%
% Experiment in 3 parts:
% 1. PRACTICE PHASE
%       Learn the 6 effort conditions
% 2. NO FATIGUE PHASE
%       Establish subjective valuation functions w/o fatigue
%       All effort and reward conditions inclusive)
% 3. FATIGUE PHASE
%       Establish subjective valuation functions w/ fatigue
%       Only low effort and high reward conditions inclusive

function runExp_cedmt

% Define internal settings for debugging/etc
USE_debug = 0; % 1 = subscreen on laptop monitor else full screen
USE_synctest = 1; % 0 = skips psychtoolbox sync test
USE_training = 1; % 0 = move immediately to NO FATIGUE PHASE
USE_nofatigue = 1; % 0 = move immediately to FATIGUE PHASE
USE_screenshots = 0; % 1 = takes PTB screenshots for posters/presentations
USE_loading_index = 1; % 1 = NASA Task Loading Index between PHASE#2 & PHASE#3

% Placeholder for the moment in case we introduce adaptive conditions
% As of 2019-05-08 not implemented
USE_fixed_levels = 1; % 1 = bottom 3 effort & top 3 reward conditions during PHASE#3

dbstop if error

%% EXPERIMENT STARTS HERE
% Add supporting functions to path
addpath('addons');

% Collect participant details
if ~USE_debug
    subj.initials = input('Subject''s initials:\n','s');  % Subject initials
    subj.ID = input('Subject number (01 to 99):\n','s');  % Subject number
    subj.age = input('Age:\n','s');
    
    while 1
        subj.gender = ...
            input('Gender (f)emale, (m)ale, (n)on-binary:\n','s');
        switch subj.gender
            case {'f','m','n'}
                break
            otherwise
                continue
        end
    end
    
    while 1
        subj.hand = ...
            input('Handedness (r)ight, (l)eft, (a)mbidextrous:\n','s');
        switch subj.hand
            case {'r','l','a'}
                break
            otherwise
                continue
        end
    end
    
else
    subj.initials = 'JM'; subj.ID = '99'; subj.age = '32';
    subj.gender = 'm'; subj.hand = 'r';
end

% Load Psychtoolbox parameters and OpenWindow
cfg = parameters(USE_debug,USE_synctest);

% Raw data save location
data_save = '../data/raw/';

% Start clock to measure total experiment time
whole_experiment = tic;

% Crash protection, skip setup if trials already created
if ~exist([data_save subj.ID '_' subj.initials '/' subj.ID subj.initials '_settings.mat'],'file')
    
    % Proportion of PHASE#2 trials that will be tested (value >0 & <1)
    % Defined here so there are 2 trials tested from each effort level
    nofatigue_proportion = 0.13; % 0.1 in original study
    
    % Creates trials
    subj = assign_trials(subj,cfg,nofatigue_proportion,USE_fixed_levels);
    
end

%% Opening screen
Screen('FillRect', cfg.win_ptr, cfg.black);

% Cogsuite#1 has a weird lag issue with first use of DrawFormattedText.
% Including here so it's not noticed by participant
DrawFormattedText(cfg.win_ptr,'0',... 
            'center', 'center',...
            cfg.black,50,[],[],1.1);
        
Screen('DrawTexture',cfg.win_ptr,cfg.instruct.introduction);
Screen('Flip', cfg.win_ptr);

WaitSecs(1);

while (1)
    [~,~,buttons] = GetMouse(cfg.win_ptr);
    if buttons(1) || KbCheck
        break;
    end
end

%% PHASE 1: EFFORT LEARNING
if USE_training
    
    % Takes screenshots of maths operations
    subj = run_training(subj,cfg,USE_screenshots);
    
    % Intermission screen
    Screen('FillRect', cfg.win_ptr, cfg.black);
    Screen('DrawTexture',cfg.win_ptr,cfg.instruct.intermission);
    Screen('Flip', cfg.win_ptr);
    
    WaitSecs(1);
    
    while (1)
        [~,~,buttons] = GetMouse(cfg.win_ptr);
        if buttons(1) || KbCheck
            break;
        end
    end
    
end

%% PHASE 2: NO FATIGUE VERSION
if USE_nofatigue
    
    % Takes screenshots of just the decisions and rewards screens
    subj = run_nofatigue(subj,cfg,USE_screenshots);
    
    % Intermission screen
    Screen('FillRect', cfg.win_ptr, cfg.black);
    Screen('DrawTexture',cfg.win_ptr,cfg.instruct.intermission);
    Screen('Flip', cfg.win_ptr);
    
    WaitSecs(1);
    
    while (1)
        [~,~,buttons] = GetMouse(cfg.win_ptr);
        if buttons(1) || KbCheck
            break;
        end
    end
    
end

%% TASK LOADING INDEX #1
% Present ratings for effort levels 1:6

if USE_loading_index 

    subj = run_loadingindex(subj,cfg);
    
end

%% PHASE 3: FATIGUE VERSION

subj = run_fatigue(subj,cfg,USE_screenshots);

% Intermission screen
Screen('FillRect', cfg.win_ptr, cfg.black);
Screen('DrawTexture',cfg.win_ptr,cfg.instruct.intermission);
Screen('Flip', cfg.win_ptr);

WaitSecs(1);

while (1)
    [~,~,buttons] = GetMouse(cfg.win_ptr);
    if buttons(1) || KbCheck
        break;
    end
end

%% TASK LOADING INDEX #2
% Will only present ratings for effort levels 1:4

if USE_loading_index 

    subj = run_loadingindex(subj,cfg);
    
end

%% END OF EXPERIMENT

% Display final total reward!

% Clear screen
Screen('FillRect', cfg.win_ptr, cfg.black);

Screen('TextSize',cfg.win_ptr,60);

DrawFormattedText(cfg.win_ptr, 'Thanks for participating!', 'center', 'center',...
    cfg.white,50,[],[],1.5);

Screen('Flip', cfg.win_ptr);

%% SAVE & CLOSE

% Append contrasts and SOAs to Subj struct and save in 'data' location
filename = [subj.ID '_' subj.initials '_settings'];
save_location = [data_save subj.ID '_' subj.initials '/'];

% How long did the experiment take:
subj.experiment_time = toc(whole_experiment);

% Overall experiment timing accounting for crashes
subj.end_time = datestr(now);
subj.exp_duration = datestr(datenum(datevec(subj.end_time)) - ...
    datenum(datevec(subj.start_time)),'HH:MM:SS');

% This should be roughly equivalent to exp_duration except in the case of
% crashes
subj.task_time = datestr((subj.experiment_time)/(24*60*60),'HH:MM:SS');

save([save_location filename '.mat'],'subj','cfg');

WaitSecs(2);

ShowCursor;
sca;

clearvars

end