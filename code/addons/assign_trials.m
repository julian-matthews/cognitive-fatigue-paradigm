function [subj] = assign_trials( subj,cfg,nofatigue_proportion,lvl_fix )
%% BUILDS TRIALS FOR COGNITIVE FATIGUE TASK
% Prepares PHASE#1 practice trials
% Prepares PHASE#2 no fatigue trials
% Prepares PHASE#3 fatigue trials

% Builds directory for data ie. mw-dual-task/data/raw/99_JM/
% If folder does not exist we assume this participant needs their task
% order assigned and trials created
if ~exist(['../data/raw/' subj.ID '_' subj.initials],'dir')
    mkdir('../data/raw/', [subj.ID '_' subj.initials]);
end

subj.save_location = ['../data/raw/' subj.ID '_' subj.initials '/'];

% Reset random number generator by the clock time & save
t = clock;
subj.RNG_seed = t(3)*t(4)*t(5);
rng(subj.RNG_seed,'twister')

% Calculate when trials were created, this is resolved at end of experiment
subj.start_time = datestr(now);
subj.end_time = [];
subj.exp_duration = [];
subj.task_time = [];

% Set blank slots for timing variables
subj.timing_phase1 = [];
subj.timing_phase2 = [];
subj.timing_phase3 = [];

%% PRELOAD OPERATIONS
% fatigue_stimuli.csv includes 12 variables:
% ID= Operation number
% EffortDegree= Number from 0 or 1:5
% Reward= Value from 1 or 2:2:10
% Num1 through Num6= Operation values either +ve or -ve
% CorrectResult= Response that is correct
% WrongResult= Response that is incorrect
% Difference= The difference between the correct & incorrect response

% Load csv (N rows, 10 columns)
stimuli = readtable('fatigue_stimuli.csv');

%% ASSIGN SELECTION ORIENTATION
% If the subj ID is an odd number, REST on LEFT and WORK on RIGHT
% If the subj ID is an even number, REST on RIGHT and WORK on LEFT

if mod(str2double(subj.ID),2)==1
    subj.selection_side = {'REST','WORK'};
else
    subj.selection_side = {'WORK','REST'};
end

%% PHASE#1A: PRACTICE EFFORT
% Present "repeats"*operations at each of 6 effort levels

repeats = 3; % cycles through effort levels 3 times

effort_levels = {'effort_1','effort_2','effort_3',...
    'effort_4','effort_5','effort_6'};

% Determine effort levels and operations
effort_all = repmat(effort_levels,1,repeats);
cycle_operations = sort(repmat(1:repeats,[1,8]));

for tr = 1 : length(effort_levels)*repeats
    
    TR(tr).phase = 'learning_effort'; %#ok<*AGROW>
    
    % Not applicable during training
    TR(tr).test_flag = NaN;
    
    TR(tr).effort_level = effort_all{tr};
    
    % Not applicable during training
    TR(tr).reward_level = NaN;
    TR(tr).work_decision = NaN;
    TR(tr).work_decision_RT = NaN;
    
    %% SELECT OPERATION
    
    % Select operations from list corresponding to effort level
    temp = stimuli(stimuli.EffortDegree == (str2double(...
        TR(tr).effort_level(end))-1),...
        stimuli.Properties.VariableNames);
    
    % Ensures training operations are identical for all participants
    switch TR(tr).effort_level
        case 'effort_1'
            line_pick = 1; % Only one type of operation for effort_1
        otherwise
            line_pick = cycle_operations(tr);
    end
    
    TR(tr).operations_vector = {num2str(temp.Num1(line_pick)),...
        num2str(temp.Num2(line_pick)),...
        num2str(temp.Num3(line_pick)),...
        num2str(temp.Num4(line_pick)),...
        num2str(temp.Num5(line_pick)),...
        num2str(temp.Num6(line_pick))};
    
    TR(tr).correct_num = num2str(temp.CorrectResult(line_pick));
    TR(tr).incorrect_num1 = num2str(temp.WrongResult1(line_pick));
    TR(tr).incorrect_num2 = num2str(temp.WrongResult2(line_pick));
    
    % Save some other details about the operation
    TR(tr).difference1 = temp.Difference1(line_pick);
    TR(tr).difference2 = temp.Difference2(line_pick);
    TR(tr).operationID = temp.ID(line_pick);
    
    % Randomise side that is correct
    TR(tr).correct_side = randi(3,1); % 1=LEFT, 2=MIDDLE, 3=RIGHT
    
    % Blank variable for inputting response (1:3 = LEFT,MIDDLE,RIGHT)
    TR(tr).response_side = [];
    TR(tr).response_RT = [];
    
end

% Input saved trials and clear TR for building PHASE#1B
phase(1).TR = TR; clear TR;

%% PHASE#1B: PRACTICE DECISIONS + VAS
% Present x trials with randomly selected effort & reward levels
% Every decision is tested and final reward is displayed
% Designed to practice selecting between effort levels for credits
% Also practice recording cognitive fatigue via the VAS?

practice_trials = 6; % Original had 12 trials according to Mindy

effort_labels = {'effort_2','effort_3','effort_4','effort_5','effort_6'}';
reward_labels = {'reward_2','reward_4','reward_6','reward_8','reward_10'}';

% Select a random assortment of effort & reward levels
effort_all = effort_labels(randi(length(effort_labels),practice_trials,1));
reward_all = reward_labels(randi(length(reward_labels),practice_trials,1));

for tr = 1:practice_trials
    
    TR(tr).phase = 'learning_decisions';
    
    TR(tr).test_flag = 'decision_tested';
    
    % Find the reward and effort conditions
    TR(tr).effort_level = effort_all{tr};
    TR(tr).reward_level = reward_all{tr};
    
    % If it's the first prac trial, fix the example at maximum effort for
    % minimum reward. This is an example of a bad offer so is used to
    % explain the concept of 'rest'
    if tr == 1
        TR(tr).effort_level = effort_labels{end};
        TR(tr).reward_level = reward_labels{1};
    end
    
    % Reward on this trial
    TR(tr).reward = [];
    
    % REST or WORK response (order determined by subj.selection_side)
    TR(tr).work_decision = []; % 'work' or 'rest'
    TR(tr).work_decision_RT = [];
    
    %% SELECT OPERATION
    
    % Select operations from list corresponding to effort & reward levels
    temp = stimuli(stimuli.EffortDegree == (str2double(...
        TR(tr).effort_level(end))-1) & ...
        stimuli.Reward == (str2double(...
        TR(tr).reward_level(8:end))),...
        stimuli.Properties.VariableNames);
    
    line_pick = randi(height(temp));
    
    % Check if this operation was just tested and reroll
    if tr > 1
        check_count = 0;
        while TR(tr-1).operationID == temp.ID(line_pick)
            line_pick = randi(height(temp));
            check_count = check_count + 1;
            if check_count > 100 % Attempts to reroll 100 times
                break
            end
        end
    end
    
    TR(tr).operations_vector = {num2str(temp.Num1(line_pick)),...
        num2str(temp.Num2(line_pick)),...
        num2str(temp.Num3(line_pick)),...
        num2str(temp.Num4(line_pick)),...
        num2str(temp.Num5(line_pick)),...
        num2str(temp.Num6(line_pick))};
    
    TR(tr).correct_num = num2str(temp.CorrectResult(line_pick));
    TR(tr).incorrect_num1 = num2str(temp.WrongResult1(line_pick));
    TR(tr).incorrect_num2 = num2str(temp.WrongResult2(line_pick));
    
    % Save some other details about the operation
    TR(tr).difference1 = temp.Difference1(line_pick);
    TR(tr).difference2 = temp.Difference2(line_pick);
    TR(tr).operationID = temp.ID(line_pick);
    
    % Randomise side that is correct
    TR(tr).correct_side = randi(3,1); % 1=LEFT, 2=MIDDLE, 3=RIGHT
    
    % Blank variable for inputting response
    TR(tr).response_side = [];
    TR(tr).response_RT = [];
    
    TR(tr).response_outcome = [];
    
end

% Input saved trials and clear TR for building PHASE#2
phase(1).prac = TR; clear TR;

%% PHASE#2: NO FATIGUE TRIALS
% Present 3 trials at each of 5 effort levels and 5 reward levels
% Total 75 trials in original study

trial_repetitions = 3; % Total of 75 trials counterbalanced 3x25 conditions

% Tested on 10% of trials (randomly selected) but can modify here
% In Mindy's original, PHASE#2 included 2 untimed breaks

% Counterbalance 5 effort levels (1vs2:1vs6) and reward levels (2:10)
effort_labels = {'effort_2','effort_3','effort_4','effort_5','effort_6'}';
reward_labels = {'reward_2','reward_4','reward_6','reward_8','reward_10'}';

effort_conditions = length(effort_labels);
reward_conditions = length(reward_labels);

condition_order = repmat(randperm(effort_conditions * reward_conditions),...
    1,trial_repetitions);
decision_order = Shuffle(condition_order);

% Build condition labels balanced by effort & reward conditions
condition_labels = cell(effort_conditions * reward_conditions,2);

count = 0;
for eff = 1:effort_conditions
    for rew = 1:reward_conditions
        count = count+1;
        condition_labels{count,1} = effort_labels{eff};
        condition_labels{count,2} = reward_labels{rew};
    end
end

% Substitute condition labels into decision order
effort_reward = condition_labels(decision_order,:);

for tr = 1:length(effort_reward)
    
    TR(tr).phase = 'no_fatigue';
    
    % Default is 'do not test' but flag
    TR(tr).test_flag = 'decision_only';
    
    % Find the reward and effort conditions
    TR(tr).effort_level = effort_reward{tr,1};
    TR(tr).reward_level = effort_reward{tr,2};
    
    % Reward on this trial
    TR(tr).reward = [];
    
    % REST or WORK response (order determined by subj.selection_side)
    TR(tr).work_decision = []; % 'work' or 'rest'
    TR(tr).work_decision_RT = [];
    
    % Placeholder operations
    TR(tr).operations_vector = NaN;
    TR(tr).correct_num = NaN;
    TR(tr).incorrect_num = NaN;
    
    % This is a NaN unless the decision is tested
    TR(tr).correct_side = NaN;
    
    % These are NaNs unless the decision is tested
    TR(tr).response_side = NaN;
    TR(tr).response_RT = NaN;
    
    TR(tr).response_outcome = NaN;
    
    % Anything else I require here
    
end

% Randomly select nofatigue_proportion of trials to be tested
if nofatigue_proportion == 1 || nofatigue_proportion > 1
    nofatigue_proportion = (length(decision_order)-1)/length(decision_order);
elseif nofatigue_proportion == 0 || nofatigue_proportion < 0
    nofatigue_proportion = 1-...
        (length(decision_order)-1)/length(decision_order);
end

% Determine order of testing 
test_this = zeros(1,round(length(decision_order) * nofatigue_proportion));

cycle = randperm(effort_conditions)-1;
cycler = randperm(reward_conditions);

count = 0;
while test_this(end) == 0
    for cyc = 1:length(cycler)
       cycler(cyc) = cycler(cyc)+1;
       if cycler(cyc) == 6
           cycler(cyc) = 1;
       end
    end
    
    for eff = 1:effort_conditions
        count = count + 1;
        test_this(count) = cycler(eff) + ...
            (reward_conditions*cycle(eff));
        if test_this(end) > 0
            break
        end
    end
end

% % Random method:
% tested_trials = randperm(length(decision_order)-1,...
%     round(length(decision_order) * nofatigue_proportion));

% Identify tested trials
tested_trials = zeros(1,length(test_this));

count = 1;
recount = 0;
while count < (length(test_this)+1)
    for tes = 1:length(decision_order)
        if decision_order(tes) == test_this(count)
            recount = recount + 1;
            tested_trials(recount) = tes;
            count = count + 1;
            if count > length(test_this)
                break
            end
        end
    end
end

% Substitute test_flag on tested trials
for tr = 1:length(tested_trials)
    this_tr = tested_trials(tr);
    
    TR(this_tr).test_flag = 'decision_tested'; % Test this trial
    
    %% SELECT OPERATION
    
    % Select operations from list corresponding to effort & reward levels
    temp = stimuli(stimuli.EffortDegree == (str2double(...
        TR(this_tr).effort_level(end))-1) & ...
        stimuli.Reward == (str2double(...
        TR(this_tr).reward_level(8:end))),...
        stimuli.Properties.VariableNames);
    
    % Randomly select an operation
    line_pick = randi(height(temp));
    
    % This is a quick test to check if the randomly selected operation was
    % tested before. If this is detected, we reroll the random operation. 
    
    % This ensures the same operation won't appear twice in a row. There 
    % is a small possibility that it can reappear at some other point but
    % participants don't know how many operations we're pulling from so
    % should still find the operation effortful.

    if tr > 1
        check_test = tested_trials(tr-1);
        check_count = 0;
        while TR(check_test).operationID == temp.ID(line_pick)
            line_pick = randi(height(temp));
            check_count = check_count + 1;
            if check_count > 100 % Attempts to reroll 100 times
                break
            end
        end
    end     
    
    TR(this_tr).operations_vector = {num2str(temp.Num1(line_pick)),...
        num2str(temp.Num2(line_pick)),...
        num2str(temp.Num3(line_pick)),...
        num2str(temp.Num4(line_pick)),...
        num2str(temp.Num5(line_pick)),...
        num2str(temp.Num6(line_pick))};
    
    TR(this_tr).correct_num = num2str(temp.CorrectResult(line_pick));
    TR(this_tr).incorrect_num1 = num2str(temp.WrongResult1(line_pick));
    TR(this_tr).incorrect_num2 = num2str(temp.WrongResult2(line_pick));
    
    % Save some other details about the operation
    TR(this_tr).difference1 = temp.Difference1(line_pick);
    TR(this_tr).difference2 = temp.Difference2(line_pick);
    TR(this_tr).operationID = temp.ID(line_pick);
    
    % Randomise side that is correct
    TR(this_tr).correct_side = randi(3,1);
    
    % Blank variable for inputting response
    TR(this_tr).response_side = [];
    TR(this_tr).response_RT = [];
    
    TR(this_tr).response_outcome = [];
end

% Input saved trials and clear TR for building PHASE#3
phase(2).TR = TR; clear TR;

%% PHASE#3: FATIGUE TRIALS
% Present X trials at Y effort levels and Z reward levels (Y,Z = ~3)
% Original study used 234 trials total
% Original study used bottom 3 effort and top 3 rewards to incentivise work
% Tested on 100% of trials

% Defaults to effort levels (2,3,4) and rewards (6,8,10)
if lvl_fix
    % This uses the same process as PHASE#2 but for testing on every trial
    % and for a trial total of 234 (9 conds w/ 26reps)
    
    trial_repetitions = 26;
    
    % Counterbalance effort levels and reward levels
    % In the current code operations are rigidly coded for 3 levels each,
    % if we change this in the future then how operations are handled will
    % need some minor updates
    effort_labels = {'effort_2','effort_3','effort_4'}';
    reward_labels = {'reward_6','reward_8','reward_10'}';
    
    effort_conditions = length(effort_labels);
    reward_conditions = length(reward_labels);
    
    condition_order = repmat(randperm(effort_conditions * reward_conditions),...
        1,trial_repetitions);
    decision_order = Shuffle(condition_order);
    
    condition_labels = cell(effort_conditions * reward_conditions,2);
    
    count = 0;
    for eff = 1:effort_conditions
        for rew = 1:reward_conditions
            count = count+1;
            condition_labels{count,1} = effort_labels{eff};
            condition_labels{count,2} = reward_labels{rew};
        end
    end
    
    effort_reward = condition_labels(decision_order,:);
    
    % This is an inelegant way to track operation number but works
    % Digits refer to effort & reward level
    % (eg, op_count_26 is operations for effort level 2 with reward of 6)
    op_count_26 = 0; op_count_28 = 0; op_count_210 = 0;
    op_count_36 = 0; op_count_38 = 0; op_count_310 = 0;
    op_count_46 = 0; op_count_48 = 0; op_count_410 = 0;
    
    % Operation order, randomised for each subject
    % Length determined by call to previously saved temp table
    % This is 10 in current exp and assumes equal number of operations per
    % condition (which should be the case)
    op_order = randperm(height(temp));
    
    for tr = 1:length(effort_reward)
        
        TR(tr).phase = 'fatigue';
        
        TR(tr).test_flag = 'decision_tested';
        
        % Find the reward and effort conditions
        TR(tr).effort_level = effort_reward{tr,1};
        TR(tr).reward_level = effort_reward{tr,2};
        
        TR(tr).reward = [];
        
        % REST or WORK response (order determined by subj.selection_side)
        TR(tr).work_decision = []; % 'work' or 'rest'
        TR(tr).work_decision_RT = [];
        
        %% SELECT OPERATION
        
        % Select operations from list corresponding to effort & reward levels
        temp = stimuli(stimuli.EffortDegree == (str2double(...
            TR(tr).effort_level(end))-1) & ...
            stimuli.Reward == (str2double(...
            TR(tr).reward_level(8:end))),...
            stimuli.Properties.VariableNames);
        
        % This is an embarrassingly inefficient way to do this but it gets
        % the job done. Could be achieved with field calls/etc but
        % hey, I've got deadlines!  \(^O^)/
        switch TR(tr).effort_level
            case 'effort_2'
                switch TR(tr).reward_level
                    case 'reward_6'
                        op_count_26 = op_count_26 + 1;
                        if op_count_26 > length(op_order)
                            op_count_26 = 1;
                        end
                        this_op = op_count_26;
                    case 'reward_8'
                        op_count_28 = op_count_28 + 1;
                        if op_count_28 > length(op_order)
                            op_count_28 = 1;
                        end
                        this_op = op_count_28;
                    case 'reward_10'
                        op_count_210 = op_count_210 + 1;
                        if op_count_210 > length(op_order)
                            op_count_210 = 1;
                        end
                        this_op = op_count_210;
                end
                
            case 'effort_3'
                switch TR(tr).reward_level
                    case 'reward_6'
                        op_count_36 = op_count_36 + 1;
                        if op_count_36 > length(op_order)
                            op_count_36 = 1;
                        end
                        this_op = op_count_36;
                    case 'reward_8'
                        op_count_38 = op_count_38 + 1;
                        if op_count_38 > length(op_order)
                            op_count_38 = 1;
                        end
                        this_op = op_count_38;
                    case 'reward_10'
                        op_count_310 = op_count_310 + 1;
                        if op_count_310 > length(op_order)
                            op_count_310 = 1;
                        end
                        this_op = op_count_310;
                end
                
            case 'effort_4'
                switch TR(tr).reward_level
                    case 'reward_6'
                        op_count_46 = op_count_46 + 1;
                        if op_count_46 > length(op_order)
                            op_count_46 = 1;
                        end
                        this_op = op_count_46;
                    case 'reward_8'
                        op_count_48 = op_count_48 + 1;
                        if op_count_48 > length(op_order)
                            op_count_48 = 1;
                        end
                        this_op = op_count_48;
                    case 'reward_10'
                        op_count_410 = op_count_410 + 1;
                        if op_count_410 > length(op_order)
                            op_count_410 = 1;
                        end
                        this_op = op_count_410;
                end
                
        end
        
        % Pick operation
        line_pick = op_order(this_op);
        
        TR(tr).operations_vector = {num2str(temp.Num1(line_pick)),...
            num2str(temp.Num2(line_pick)),...
            num2str(temp.Num3(line_pick)),...
            num2str(temp.Num4(line_pick)),...
            num2str(temp.Num5(line_pick)),...
            num2str(temp.Num6(line_pick))};
        
        TR(tr).correct_num = num2str(temp.CorrectResult(line_pick));
        TR(tr).incorrect_num1 = num2str(temp.WrongResult1(line_pick));
        TR(tr).incorrect_num2 = num2str(temp.WrongResult2(line_pick));
        
        % Save some other details about the operation
        TR(tr).difference1 = temp.Difference1(line_pick);
        TR(tr).difference2 = temp.Difference2(line_pick);
        TR(tr).operationID = temp.ID(line_pick);
        
        % For maths problem:
        % Randomise side that is correct
        TR(tr).correct_side = randi(3,1);
        
        % Blank variable for inputting response
        TR(tr).response_side = [];
        TR(tr).response_RT = [];
        
        TR(tr).response_outcome = [];
        
        % Number from 0 to 100 on visual analogue scale
        % See: Krupp, Alvarez, Larocca, & Scheinberg, 1988
        TR(tr).subjective_fatigue = [];
        TR(tr).subjective_fatigue_RT = [];
        
        % Anything else I require here
        
    end
    
else
    
    % Placeholder for the moment but including this flag in case we add an
    % adaptive effort/reward component
    
    % This will require a fair amount of work to work cleanly with the
    % operations while also ensuring no double-ups
    
end

% Input saved trials
phase(3).TR = TR; clear TR; %#ok<*STRNU>

%% SAVE TRIALS AND SETTINGS

trial_file = [subj.ID '_' subj.initials '_trials'];
save([subj.save_location trial_file '.mat'],'phase')

settings_file = [subj.ID '_' subj.initials '_settings'];
save([subj.save_location settings_file '.mat'],'subj','cfg')

end