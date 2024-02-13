function [subj] = run_nofatigue(subj,cfg,USE_screenshots)
%% RUN_NOFATIGUE
% Present trials for PHASE#2 of COG FATIGUE study

% 2019-03-08: need to improve screenshot implementation

USE_stoppage = 1; % Forces pauses to make trials approx the same time length
USE_effort_visual = 0; % 1= effort level appears before operation

% Load trials: phase(2).TR from 'ID_initials_trials.mat'
filename = [subj.ID '_' subj.initials '_trials'];
load([subj.save_location filename '.mat'] ,'phase')
TR = phase(2).TR;  %#ok<*NODEF>

%% PRESENT INSTRUCTIONS

% Determine window size
[y,i] = min(cfg.win_rect(3:4));
instruct_window = [0 0 y y];
if i == 2
    instruct_window = instruct_window + (cfg.width-y)/2*[1 0 1 0];
elseif i == 1
    instruct_window = instruct_window + (cfg.height-y)/2*[0 1 0 1];
end

% Colour screen black
Screen('FillRect', cfg.win_ptr, cfg.black);
Screen('DrawTexture',cfg.win_ptr,cfg.instruct.nofatigue, ...
    [],instruct_window);
Screen('Flip', cfg.win_ptr);

% Screenshots for presentation
if USE_screenshots
    capture_count = 1; %#ok<*UNRCH>
    imageArray = Screen('GetImage', cfg.win_ptr);
    imwrite(imageArray, ['screenshot_phase2_' mat2str(capture_count) '.png'])
end

WaitSecs(1);

while (1)
    if KbCheck
        break;
    end
end

WaitSecs(0.5);

%% REMINDER ABOUT TIMING OF RESPONSE

timing_tex = sprintf(['You have %0.2g seconds to make each decision.'...
    '\nFailure to respond results in no reward.'],...
    cfg.response_time);

% Colour screen black
Screen('FillRect', cfg.win_ptr, cfg.black);
DrawFormattedText(cfg.win_ptr,timing_tex,...
                'center', 'center',cfg.white,50,[],[],1.1);
Screen('Flip', cfg.win_ptr);

WaitSecs(1);

while (1)
    if KbCheck
        break;
    end
end

WaitSecs(0.5);


%% PRESENT TRIALS

% Start clock to measure time for PHASE#3
nofatigue = tic;

for tr = 1:length(TR)
    
    Screen('TextFont', cfg.win_ptr, 'Courier');
    
    % Determine work texture
    switch TR(tr).effort_level
        case 'effort_2'
            work_tex = cfg.effort.l2;
        case 'effort_3'
            work_tex = cfg.effort.l3;
        case 'effort_4'
            work_tex = cfg.effort.l4;
        case 'effort_5'
            work_tex = cfg.effort.l5;
        case 'effort_6'
            work_tex = cfg.effort.l6;
        otherwise
            disp('effort level not specified')
    end
    
    switch TR(tr).reward_level
        case 'reward_2'
            work_reward = '2 credits';
        case 'reward_4'
            work_reward = '4 credits';
        case 'reward_6'
            work_reward = '6 credits';
        case 'reward_8'
            work_reward = '8 credits';
        case 'reward_10'
            work_reward = '10 credits';
        otherwise
            disp('reward level not specified')
    end
    
    % Rest texture
    rest_tex = cfg.effort.l1;
    
    % Work and rest rewards
    rest_reward = '1 credit';
    
    %% PRESENT WORK vs. REST DECISION
    % The side of the decision is fixed throughout the experiment but is
    % counterbalanced between participants on the basis of their study ID
    % subj.selection_side is either {'WORK','REST'} or {'REST','WORK'}
    
    box_dims = [-cfg.box_length, -2*cfg.box_length, cfg.box_length, 0];
    box_dims = box_dims*1.25;
    tex_box = box_dims+(cfg.xCentre*[1,0,1,0])+(cfg.yCentre*[0,1,0,1]);
    
    % Determine precise location of decision text
    if strcmp(subj.selection_side{1},'WORK')
        % work_tex on left
        work_box = tex_box-2.5*cfg.box_length*[1,0,1,0];
        rest_box = tex_box+2.5*cfg.box_length*[1,0,1,0];
    else
        % work_tex on right
        work_box = tex_box+2.5*cfg.box_length*[1,0,1,0];
        rest_box = tex_box-2.5*cfg.box_length*[1,0,1,0];
    end
    
    % Compute offset required to centre text on image
    [~,~,workbounds] = DrawFormattedText(cfg.win_ptr,work_reward,...
        'center', 'center',...
        cfg.white,50,[],[],1.1);
    [~,~,restbounds] = DrawFormattedText(cfg.win_ptr,rest_reward,...
        'center', 'center',...
        cfg.white,50,[],[],1.1);
    work_width = round(workbounds(3)-workbounds(1));
    rest_width = round(restbounds(3)-restbounds(1));
    img_width = round(work_box(3)-work_box(1));
    
    % Determine xcoords as distance from image
    x_work = work_box(1)+((img_width-work_width)/2);
    x_rest = rest_box(1)+((img_width-rest_width)/2);
    
    y_location = cfg.yCentre+0.5*cfg.box_length;
    
    %% DRAW RESPONSE ALTERNATIVES AND INPUT NUMBERS
    
    Screen('FillRect', cfg.win_ptr, cfg.window_colour);
    
    % work & rest tex
    Screen('DrawTexture',cfg.win_ptr,work_tex,[],...
        work_box);
    Screen('DrawTexture',cfg.win_ptr,cfg.effort.l1,[],...
        rest_box);
    
    % work reward (figuring out x-coord might require trial&error)
    DrawFormattedText(cfg.win_ptr,work_reward,...
        x_work, y_location,...
        cfg.white,50,[],[],1.1);
    
    % rest reward
    DrawFormattedText(cfg.win_ptr,rest_reward,...
        x_rest, y_location,...
        cfg.white,50,[],[],1.1);
    
    Screen('Flip', cfg.win_ptr);
    
    start_timer = GetSecs;
    time_elapsed = tic;
    while 1
        
        [is_pressed, this_time, is_key]=KbCheck;
        
        if is_pressed
            if xor(is_key(cfg.leftKey),is_key(cfg.rightKey))
                
                Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                
                if is_key(cfg.leftKey)
                    if strcmp(subj.selection_side{1},'WORK')
                        TR(tr).work_decision = 'work';
                        left_tex = work_tex;
                        left_box = work_box;
                        
                        DrawFormattedText(cfg.win_ptr,work_reward,...
                            x_work, ...
                            y_location,...
                            cfg.white,50,[],[],1.1);
                        
                    else
                        TR(tr).work_decision = 'rest';
                        left_tex = rest_tex;
                        left_box = rest_box;
                        
                        DrawFormattedText(cfg.win_ptr,rest_reward,...
                            x_rest, ...
                            y_location,...
                            cfg.white,50,[],[],1.1);
                    end
                    
                    % Left tex
                    Screen('DrawTexture',cfg.win_ptr,left_tex,[],...
                        left_box);
                    
                    
                elseif is_key(cfg.rightKey)
                    if strcmp(subj.selection_side{1},'WORK')
                        TR(tr).work_decision = 'rest';
                        right_tex = rest_tex;
                        right_box = rest_box;
                        
                        DrawFormattedText(cfg.win_ptr,rest_reward,...
                            x_rest, ...
                            y_location,...
                            cfg.white,50,[],[],1.1);
                        
                    else
                        TR(tr).work_decision = 'work';
                        right_tex = work_tex;
                        right_box = work_box;
                        
                        DrawFormattedText(cfg.win_ptr,work_reward,...
                            x_work, ...
                            y_location,...
                            cfg.white,50,[],[],1.1);
                    end
                    
                    % Right tex
                    Screen('DrawTexture',cfg.win_ptr,right_tex,[],...
                        right_box);
                    
                end
                
                Screen('Flip', cfg.win_ptr);
                
                WaitSecs(0.4);
                
                TR(tr).work_decision_RT = this_time-start_timer;
                break
            else
                continue
            end
        end
        if (toc(time_elapsed)-cfg.work_decision_time) > 0
            TR(tr).work_decision = 'too slow';
            TR(tr).work_decision_RT = NaN;
            
            TR(tr).reward = 0;
            
            TR(tr).response_side = NaN;
            TR(tr).response_RT = NaN;
            TR(tr).response_outcome = 'decision missed';
            
            feedback_script = ...
                'Decision missed!\n\nTry to respond more quickly\nYou receive 0 credits';
            
            Screen('TextFont', cfg.win_ptr, 'Arial');
            
            time_elapsed = tic;
            while (toc(time_elapsed)-cfg.feedback_time) < 0
                Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                DrawFormattedText(cfg.win_ptr,feedback_script,...
                    'center', 'center',cfg.white,50,[],[],1.1);
                Screen('Flip', cfg.win_ptr);
            end
            
            %% PAUSE
            if USE_stoppage
                
                time_elapsed = tic;
                while (toc(time_elapsed)-(cfg.stoppage+cfg.response_time)) < 0
                                    
                    Screen('TextFont', cfg.win_ptr, 'Courier');
                    Screen('TextSize', cfg.win_ptr, cfg.text_size);
                    
                    % Countdown dots
                    dot_counter = round((cfg.stoppage+cfg.response_time)-toc(time_elapsed));
                    build_dots = repmat('.',1,dot_counter);
                    
                    Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                    DrawFormattedText(cfg.win_ptr,build_dots,...
                        'center', 'center',cfg.white,50,[],[],1.1);
                    Screen('Flip', cfg.win_ptr);
                    
                end
            end
            
            break
        end
    end
    
    %% PERFORM OPERATION IF TESTED
    
    if strcmp(TR(tr).test_flag,'decision_tested') && ...
            ~strcmp(TR(tr).work_decision,'too slow')
        % Determine which operation on the basis of decision
        
        if strcmp(TR(tr).work_decision,'work')
            
            effort_tex = work_tex; %#ok<*NASGU>
            
        elseif strcmp(TR(tr).work_decision,'rest')

            % From Eliana's spreadsheet, a zeroes vector
            TR(tr).operations_vector = {'0','0','0','0','0','0'};
            TR(tr).correct_num = '0';
            TR(tr).incorrect_num1 = '1';
            TR(tr).incorrect_num2 = '2';
            
            effort_tex = cfg.effort.l1;
        end
        
        %% Present effort texture
        
        if USE_effort_visual
            time_elapsed = tic;
            while (toc(time_elapsed)-cfg.effort_time) < 0
                Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                Screen('DrawTexture',cfg.win_ptr,effort_tex);
                Screen('Flip', cfg.win_ptr);
            end
        end
        
        %% Present blank screen for interstimulus_interval
        time_elapsed = tic;
        while (toc(time_elapsed)-cfg.interstimulus_interval) < 0
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            Screen('Flip', cfg.win_ptr);
        end
        
        %% Present operation in Courier font
        Screen('TextFont', cfg.win_ptr, 'Courier');
        Screen('TextSize', cfg.win_ptr, cfg.operation_text);
        
        for operation = 1:length(TR(tr).operations_vector)
            
            operation_text = TR(tr).operations_vector{operation};
            
            if str2double(operation_text) > -1
                operation_text = ['+' operation_text]; %#ok<AGROW>
            end
            
            time_elapsed = tic;
            while (toc(time_elapsed)-cfg.operation_time) < 0
                Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                DrawFormattedText(cfg.win_ptr,operation_text,...
                    'center', 'center',cfg.white,50,[],[],1.1);
                Screen('Flip', cfg.win_ptr);
                
            end
            
            % ISI for all but final operand
            if operation ~= length(TR(tr).operations_vector)
                time_elapsed = tic;
                while (toc(time_elapsed)-cfg.interstimulus_interval) < 0
                    Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                    Screen('Flip', cfg.win_ptr);
                end
            end
        end
        
        %% Makes operation response
        
        % Determine precise locations of response box and text
        switch TR(tr).correct_side
            case 1
                % Left side
                x_text_correct = -2;
                x_text_incorrect1 = 0;
                x_text_incorrect2 = 2;
                
            case 2
                % Middle
                x_text_incorrect1 = -2;
                x_text_correct = 0;
                x_text_incorrect2 = 2;
                
            case 3
                % Right side
                x_text_incorrect1 = -2;
                x_text_incorrect2 = 0;
                x_text_correct = 2;
        end
        
        correct_box = CenterRectOnPoint(cfg.box_size,...
            (cfg.xCentre + (cfg.box_length * x_text_correct)), cfg.yCentre);
        
        incorrect_box1 = CenterRectOnPoint(cfg.box_size,...
            (cfg.xCentre + (cfg.box_length * x_text_incorrect1)), cfg.yCentre);
        
        incorrect_box2 = CenterRectOnPoint(cfg.box_size,...
            (cfg.xCentre + (cfg.box_length * x_text_incorrect2)), cfg.yCentre);
        
        Screen('TextSize', cfg.win_ptr, cfg.text_size);
        
        % Clear the screen
        Screen('FillRect', cfg.win_ptr, cfg.window_colour);
        
        %% DRAW RESPONSE ALTERNATIVES AND INPUT NUMBERS
        
        % Draw boxes
        % order doesn't matter here because it's determined above
        Screen('FrameRect', cfg.win_ptr, cfg.white,...
            [correct_box', incorrect_box1', incorrect_box2'],...
            cfg.box_width);
        
        % Put answers in the appropriate boxes
        DrawFormattedText(cfg.win_ptr,TR(tr).correct_num,...
            'center','center',cfg.white,[],[],[],[],[],correct_box);
        
        DrawFormattedText(cfg.win_ptr,TR(tr).incorrect_num1,...
            'center','center',cfg.white,[],[],[],[],[],incorrect_box1);
        
        DrawFormattedText(cfg.win_ptr,TR(tr).incorrect_num2,...
            'center','center',cfg.white,[],[],[],[],[],incorrect_box2);
        
        Screen('Flip', cfg.win_ptr);
        
        start_timer = GetSecs;
        time_elapsed = tic;
        while 1
            
            [is_pressed, this_time, is_key]=KbCheck;
            
            if is_pressed
                
                flag_it = 0;
                if is_key(cfg.leftKey)
                    flag_it = 1;
                    TR(tr).response_side = 1;
                elseif is_key(cfg.upKey)
                    flag_it = 1;
                    TR(tr).response_side = 2;
                elseif is_key(cfg.rightKey)
                    flag_it = 1;
                    TR(tr).response_side = 3;
                end
                
                if flag_it
                    
                    % Highlight the selected box
                    switch TR(tr).response_side
                        case 1
                            % Left selected
                            lit = -2;
                            unlit1 = 0;
                            unlit2 = 2;
                            
                        case 2
                            % Middle selected
                            unlit1 = -2;
                            lit = 0;
                            unlit2 = 2;
                            
                        case 3
                            % Right selected
                            unlit1 = -2;
                            unlit2 = 0;
                            lit = 2;
                    end
                    
                    % Determine new boxes
                    lit_box = CenterRectOnPoint(cfg.box_size,...
                        (cfg.xCentre + (cfg.box_length * lit)), cfg.yCentre);
                    
                    unlit_box1 = CenterRectOnPoint(cfg.box_size,...
                        (cfg.xCentre + (cfg.box_length * unlit1)), cfg.yCentre);
                    
                    unlit_box2 = CenterRectOnPoint(cfg.box_size,...
                        (cfg.xCentre + (cfg.box_length * unlit2)), cfg.yCentre);
                    
                    %% HIGHLIGHT CORRECT BOX
                    
                    % Draw unlit boxes
                    Screen('FrameRect', cfg.win_ptr, cfg.white,...
                        [unlit_box1', unlit_box2'],cfg.box_width);
                    
                    % Draw highlighted box
                    Screen('FrameRect', cfg.win_ptr, cfg.highlight,...
                        lit_box,cfg.box_width);
                    
                    % Draw text in the appropriate boxes
                    DrawFormattedText(cfg.win_ptr,TR(tr).correct_num,...
                        'center','center',cfg.white,[],[],[],[],[],correct_box);
                    
                    DrawFormattedText(cfg.win_ptr,TR(tr).incorrect_num1,...
                        'center','center',cfg.white,[],[],[],[],[],incorrect_box1);
                    
                    DrawFormattedText(cfg.win_ptr,TR(tr).incorrect_num2,...
                        'center','center',cfg.white,[],[],[],[],[],incorrect_box2);
                    
                    Screen('Flip', cfg.win_ptr);
                    
                    WaitSecs(0.4);
                    
                    TR(tr).response_RT = this_time-start_timer;
                    break
                else
                    continue
                end
            end
            if (toc(time_elapsed)-cfg.response_time) > 0
                TR(tr).response_side = NaN;
                TR(tr).response_RT = NaN;
                break
            end
        end
        
        %% FEEDBACK SCREEN
        
        % Determine correctness or miss
        if isequal(TR(tr).response_side,TR(tr).correct_side)
            
            TR(tr).response_outcome = 'correct';
            
            % Detemine reward
            if strcmp(TR(tr).work_decision,'work')
                feedback_script = ['Correct!\nYou receive ' work_reward];
                TR(tr).reward = str2double(TR(tr).reward_level(8:end));
            elseif strcmp(TR(tr).work_decision,'rest')
                feedback_script = ['Correct!\nYou receive ' rest_reward];
                TR(tr).reward = str2double(rest_reward(1));
            end
            
        elseif isnan(TR(tr).response_side)
            
            TR(tr).response_outcome = 'too slow';
            
            feedback_script = ...
                'Too slow\nTry to respond to the maths problem more quickly\n\nYou receive 0 credits';
            TR(tr).reward = 0;
        else
            TR(tr).response_outcome = 'incorrect';
            
            feedback_script = 'Incorrect\nYou receive 0 credits';
            TR(tr).reward = 0;
        end
        
        Screen('TextFont', cfg.win_ptr, 'Arial');
        
        time_elapsed = tic;
        while (toc(time_elapsed)-cfg.feedback_time) < 0
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            DrawFormattedText(cfg.win_ptr,feedback_script,...
                'center', 'center',cfg.white,50,[],[],1.1);
            Screen('Flip', cfg.win_ptr);
        end
        
    elseif strcmp(TR(tr).test_flag,'decision_only')
        
        % Decision not tested, code NaNs for response variables
        TR(tr).operations_vector = NaN;
        TR(tr).correct_num = NaN;
        TR(tr).incorrect_num1 = NaN;
        TR(tr).incorrect_num2 = NaN;
        TR(tr).correct_side = NaN;
        TR(tr).response_side = NaN;
        TR(tr).response_RT = NaN;
        TR(tr).response_outcome = NaN;
        
        % Detemine reward
        if strcmp(TR(tr).work_decision,'work')
            TR(tr).reward = str2double(TR(tr).reward_level(8:end));
        elseif strcmp(TR(tr).work_decision,'rest')
            TR(tr).reward = str2double(rest_reward(1));
        end
        
        %% PAUSE
        if USE_stoppage && ~strcmp(TR(tr).work_decision, 'too slow')
            
            time_elapsed = tic;
            while (toc(time_elapsed)-(cfg.stoppage+cfg.response_time)) < 0
                
                Screen('TextFont', cfg.win_ptr, 'Courier');
                Screen('TextSize', cfg.win_ptr, cfg.text_size);
                
                % Countdown dots
                dot_counter = round((cfg.stoppage+cfg.response_time)-toc(time_elapsed));
                build_dots = repmat('.',1,dot_counter);
                
                Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                DrawFormattedText(cfg.win_ptr,build_dots,...
                    'center', 'center',cfg.white,50,[],[],1.1);
                Screen('Flip', cfg.win_ptr);
                
            end
        end
        
    end
    
    %% SAVE TEMP FILE
    % Saved data up to the latest trial of the current block
    trial_file = [subj.ID '_' subj.initials '_temp'];
    save([subj.save_location trial_file '.mat'],'TR')
    
    %% INTERBLOCK REST
    % 2 intervals of rest during the block
    
    if tr == round(length(TR)/3)
        
        time_elapsed = tic;
        while (toc(time_elapsed)-cfg.intertrial_time) < 0
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            Screen('Flip', cfg.win_ptr);
        end
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        DrawFormattedText(cfg.win_ptr,...
            'First 3rd complete, take a short break',...
            'center', 'center',...
            cfg.white,50,[],[],1.1);
        Screen('Flip', cfg.win_ptr);
        
        WaitSecs(2);
        
        while (1)
            if KbCheck
                break;
            end
        end
        
    elseif tr == round(length(TR)/1.5)
        
        time_elapsed = tic;
        while (toc(time_elapsed)-cfg.intertrial_time) < 0
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            Screen('Flip', cfg.win_ptr);
        end
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        DrawFormattedText(cfg.win_ptr,...
            'Second 3rd complete, take a short break',...
            'center', 'center',...
            cfg.white,50,[],[],1.1);
        Screen('Flip', cfg.win_ptr);
        
        WaitSecs(2);
        
        while (1)
            if KbCheck
                break;
            end
        end
        
    end
    
    %% INTERTRIAL SCREEN
    time_elapsed = tic;
    while (toc(time_elapsed)-cfg.intertrial_time) < 0
        Screen('FillRect', cfg.win_ptr, cfg.window_colour);
        Screen('Flip', cfg.win_ptr);
    end
    
    %% STUFF VISUALISED FOR THE EXPERIMENTER
    
    % Display the trial number, decision and if tested
    disp(['Trial ' num2str(tr) ' of ' num2str(length(TR)) ': '...
        TR(tr).work_decision ' w/ ' TR(tr).test_flag]);
    
    if strcmp('decision_tested',TR(tr).test_flag)
        if strcmp('work',TR(tr).work_decision)
            disp([TR(tr).work_decision ', ' ...
                TR(tr).response_outcome ', reward_' ...
                num2str(TR(tr).reward) ', ' ...
                TR(tr).effort_level]);
        else
            disp([TR(tr).work_decision ', ' ...
                TR(tr).response_outcome ', reward_' ...
                num2str(TR(tr).reward) ' vs. ' ...
                TR(tr).effort_level ' & ' ...
                TR(tr).reward_level]);
        end
    end
    
end

%% SAVE TRIALS AND SETTINGS

subj.timing_phase2 = toc(nofatigue);
phase(2).TR = TR;

disp(['Phase#2 score: ' num2str(sum([TR(:).reward]))]);

trial_file = [subj.ID '_' subj.initials '_trials'];
save([subj.save_location trial_file '.mat'],'phase')

settings_file = [subj.ID '_' subj.initials '_settings'];
save([subj.save_location settings_file '.mat'],'subj','cfg')

end

