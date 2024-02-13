function [subj] = run_loadingindex( subj,cfg )
%% LOADING INDICES
% Determines task loading: 0 to 100

load_sensitivity = cfg.vas_sensitivity;

% Each effort level tested in counterbalanced order
% Let's make this one untimed

effort_levels = 6;

% Does the loading_indices field exist?
if ~isfield(subj, 'loading_indices')
    % No. Need to create
    subj.loading_indices = zeros(1,effort_levels);
    addto = 1;
else
    % Yes. Determine size and add to next row
    whatsize = size(subj.loading_indices);
    addto = whatsize(1)+1;
end

% Balanced latin square, select row on basis of participant
the_square = ballatsq(effort_levels);

row_wanted = mod(str2double(subj.ID),effort_levels);

if row_wanted == 0
    row_wanted = effort_levels;
end

this_order = the_square(row_wanted,:);

%% DRAW THE TEXTURE AT TOP OF SCREEN
% Determine dimensions of texture box (same as earlier)
box_dims = [-cfg.box_length, -2*cfg.box_length, cfg.box_length, 0];
box_dims = box_dims*1.1;
tex_box = box_dims+(cfg.xCentre*[1,0,1,0])+(cfg.yCentre*[0,0.85,0,0.85]);

for rating = 1:length(this_order)
    
    % If this is the second round of ratings, skip effort levels 5:6
    if addto == 1
        
        skip_flag = 0;
        switch this_order(rating)
            case 1
                tex = cfg.effort.l1;
            case 2
                tex = cfg.effort.l2;
            case 3
                tex = cfg.effort.l3;
            case 4
                tex = cfg.effort.l4;
            case 5
                tex = cfg.effort.l5;
            case 6
                tex = cfg.effort.l6;
            otherwise
                disp('effort level not specified')
        end
        
    elseif addto == 2
        
        skip_flag = 0;
        switch this_order(rating)
            case 1
                tex = cfg.effort.l1;
            case 2
                tex = cfg.effort.l2;
            case 3
                tex = cfg.effort.l3;
            case 4
                tex = cfg.effort.l4;
            case {5,6}
                
                % Save a null index and skip rating
                subj.loading_indices(addto,this_order(rating)) = NaN;
                skip_flag = 1;
            
            otherwise
                disp('effort level not specified')
        end
    end
    
    if skip_flag ~= 1
        
        
        Screen('TextFont', cfg.win_ptr, 'Arial');
        
        % Determine text size
        Screen('TextSize', cfg.win_ptr, cfg.minor_text);
        
        lo_text = 'Very Low';
        hi_text = 'Very High';
        
        [~,~,lo_texbounds] = DrawFormattedText(cfg.win_ptr,lo_text);
        [~,~,hi_texbounds] = DrawFormattedText(cfg.win_ptr,hi_text);
        
        % Define lines for VAS scale and loading cursor
        vas_dims = horzcat([-4*cfg.box_length 4*cfg.box_length; 0 0],...
            [-4*cfg.box_length -4*cfg.box_length;-0.125*cfg.box_length 0.125*cfg.box_length],...
            [4*cfg.box_length 4*cfg.box_length;-0.125*cfg.box_length 0.125*cfg.box_length]);
        
        tri_dims = horzcat([-0.125*cfg.box_length 0; 0.25*cfg.box_length 0],...
            [0 0.125*cfg.box_length; 0 0.25*cfg.box_length],...
            [-0.125*cfg.box_length 0.125*cfg.box_length; 0.25*cfg.box_length 0.25*cfg.box_length]);
        
        loading_score = 50;
        
        Screen('TextFont', cfg.win_ptr, 'Courier');
        Screen('TextSize', cfg.win_ptr, cfg.text_size);
        fa_text = num2str(loading_score);
        [~,~,fa_texbounds] = DrawFormattedText(cfg.win_ptr,fa_text);
        
        while 1
            
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            
            % Draw VAS
            Screen('DrawLines', cfg.win_ptr, vas_dims,...
                4, cfg.white,...
                [cfg.xCentre, cfg.yCentre]);
            
            % Draw triangle pointing to current loading level
            Screen('DrawLines', cfg.win_ptr, tri_dims,...
                2, cfg.white,...
                [(loading_score*0.08*cfg.box_length)+cfg.xCentre+(-4*cfg.box_length), ...
                cfg.yCentre+0.0625*cfg.box_length]);
            
            Screen('TextFont', cfg.win_ptr, 'Arial');
            
            % Draw texture to the screen
            Screen('DrawTexture',cfg.win_ptr,tex,[],tex_box);
            
            Screen('TextSize', cfg.win_ptr, cfg.text_size);
            DrawFormattedText(cfg.win_ptr,'How mentally demanding was this level?',...
                'center', cfg.yCentre+1.5*cfg.box_length,...
                cfg.white,50,[],[],1.1);
            
            % Draw text based upon parameters above
            Screen('TextSize', cfg.win_ptr, cfg.minor_text);
            DrawFormattedText(cfg.win_ptr,lo_text,...
                vas_dims(1,1)+cfg.xCentre-(0.5*lo_texbounds(3)),...
                cfg.yCentre-0.5*cfg.box_length,cfg.white,50,[],[],1.1);
            DrawFormattedText(cfg.win_ptr,hi_text,...
                vas_dims(1,2)+cfg.xCentre-(0.5*hi_texbounds(3)),...
                cfg.yCentre-0.5*cfg.box_length,cfg.white,50,[],[],1.1);
            
            DrawFormattedText(cfg.win_ptr,...
                'Use the arrow keys to move the cursor\n\nPress the control key to register your response',...
                'center', cfg.yCentre+2*cfg.box_length,...
                cfg.white,60,[],[],1.1);
            
            % Draw loading text to screen under triangle
            Screen('TextFont', cfg.win_ptr, 'Courier');
            Screen('TextSize', cfg.win_ptr, cfg.text_size);
            
            DrawFormattedText(cfg.win_ptr,fa_text,...
                (loading_score*0.08*cfg.box_length)+cfg.xCentre+(-4*cfg.box_length)-(0.5*fa_texbounds(3)),...
                cfg.yCentre+1*cfg.box_length,cfg.white,50,[],[],1.1);
            
            Screen('Flip', cfg.win_ptr);
            
            % Check for left or right arrow to update loading score
            [is_pressed, ~, is_key]=KbCheck;
            
            % Might need check to account for pressing more than 1 key
            
            if is_pressed
                
                if xor(is_key(cfg.leftKey),is_key(cfg.rightKey))
                    if is_key(cfg.leftKey)
                        loading_score = loading_score-1;
                        
                        if loading_score < 0
                            loading_score = 0;
                        end
                        
                    elseif is_key(cfg.rightKey)
                        loading_score = loading_score+1;
                        
                        if loading_score > 100
                            loading_score = 100;
                        end
                    end
                    
                    % Redefine location and number
                    
                    Screen('TextFont', cfg.win_ptr, 'Courier');
                    Screen('TextSize', cfg.win_ptr, cfg.text_size);
                    
                    fa_text = num2str(loading_score);
                    
                    [~,~,fa_texbounds] = DrawFormattedText(cfg.win_ptr,fa_text);
                    
                    WaitSecs(load_sensitivity);
                    
                    continue
                    
                elseif is_key(cfg.fatigueKey)
                    
                    % Terminate selection early
                    % Highlight text cfg.highlight
                    
                    Screen('FillRect', cfg.win_ptr, cfg.window_colour);
                    
                    % Draw VAS
                    Screen('DrawLines', cfg.win_ptr, vas_dims,...
                        4, cfg.white,...
                        [cfg.xCentre, cfg.yCentre]);
                    
                    % Draw triangle pointing to current loading level
                    Screen('DrawLines', cfg.win_ptr, tri_dims,...
                        2, cfg.highlight,...
                        [(loading_score*0.08*cfg.box_length)+cfg.xCentre+(-4*cfg.box_length), ...
                        cfg.yCentre+0.0625*cfg.box_length]);
                    
                    Screen('TextFont', cfg.win_ptr, 'Arial');
                    
                    % Draw texture to the screen
                    Screen('DrawTexture',cfg.win_ptr,tex,[],tex_box);
                    
                    Screen('TextSize', cfg.win_ptr, cfg.text_size);
                    DrawFormattedText(cfg.win_ptr,'How mentally demanding was this level?',...
                        'center', cfg.yCentre+1.5*cfg.box_length,...
                        cfg.white,50,[],[],1.1);
                    
                    % Draw text based upon parameters above
                    Screen('TextSize', cfg.win_ptr, cfg.minor_text);
                    DrawFormattedText(cfg.win_ptr,lo_text,...
                        vas_dims(1,1)+cfg.xCentre-(0.5*lo_texbounds(3)),...
                        cfg.yCentre-0.5*cfg.box_length,cfg.white,50,[],[],1.1);
                    DrawFormattedText(cfg.win_ptr,hi_text,...
                        vas_dims(1,2)+cfg.xCentre-(0.5*hi_texbounds(3)),...
                        cfg.yCentre-0.5*cfg.box_length,cfg.white,50,[],[],1.1);
                    
                    DrawFormattedText(cfg.win_ptr,...
                        'Use the arrow keys to move the cursor\n\nPress the control key to register your response',...
                        'center', cfg.yCentre+2*cfg.box_length,...
                        cfg.white,60,[],[],1.1);
                    
                    % Draw loading text to screen under triangle
                    Screen('TextFont', cfg.win_ptr, 'Courier');
                    Screen('TextSize', cfg.win_ptr, cfg.text_size);
                    
                    DrawFormattedText(cfg.win_ptr,fa_text,...
                        (loading_score*0.08*cfg.box_length)+cfg.xCentre+(-4*cfg.box_length)-(0.5*fa_texbounds(3)),...
                        cfg.yCentre+1*cfg.box_length,cfg.highlight,50,[],[],1.1);
                    
                    Screen('Flip', cfg.win_ptr);
                    
                    WaitSecs(0.4);
                    
                    break
                    
                else
                    continue
                end
            end
        end
        
        % Save the loading index
        subj.loading_indices(addto,this_order(rating)) = loading_score;
        
        % Present blank screen for 500ms
        time_elapsed = tic;
        while (toc(time_elapsed)-cfg.interstimulus_interval) < 0
            Screen('FillRect', cfg.win_ptr, cfg.window_colour);
            Screen('Flip', cfg.win_ptr);
        end
        
        %% TELL THE EXPERIMENTER
        
        disp(['Rating ' num2str(rating) ' @ Effort Level ' num2str(this_order(rating))...
            ': ' num2str(loading_score)]);
        
    else
        %% TELL THE EXPERIMENTER
        
        disp(['Rating ' num2str(rating) ' @ Effort Level ' num2str(this_order(rating))...
            ' was skipped']);
        
    end
    
end

settings_file = [subj.ID '_' subj.initials '_settings'];
save([subj.save_location settings_file '.mat'],'subj','cfg')

end
