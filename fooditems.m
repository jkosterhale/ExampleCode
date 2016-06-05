function fooditems(subID, testing, therun)



keynums = [25:39 89:95]; %keyboard key numbers that correspond to 1~4 buttons and scanner buttons
esc=KbName('ESCAPE');  %set an escakbchpe key

warning off;
InitializePsychSound;
PsychJavaTrouble;
KbCheck

devices = PsychHID('devices');
[dev_names{1:length(devices)}] = deal(devices.usageName);
%kbd_devs = find(ismember(dev_names, 'Keyboard')==1);
kbd_devs  = 1:7;


%set up the screens

warning off;
InitializePsychSound;
PsychJavaTrouble;
KbCheck

devices = PsychHID('devices');
[dev_names{1:length(devices)}] = deal(devices.usageName);
kbd_devs = find(ismember(dev_names, 'Keyboard')==1);

% HideCursor;
displays = Screen('screens');
screenRect= Screen('rect', displays(end));
[x0,y0] = RectCenter(screenRect); %sets Center for screenRect (x,y)
window = Screen('OpenWindow', displays(end),[0 0 0], screenRect, 32);


%randomization seed:
[~, name] = strtok(subID,'_');
[~, name] = strtok(name,'_');
[randseed, ~] = strtok(name,'_');
IDnum = str2num(randseed);
rand('twister',IDnum);

ips = 300;

if testing == 0   %scannng times!
    resttime = 12;  %start and end of experiment loop
    breakBeforeTrial = 0;  %before each trial
    viewPreferenceTime = 2; %how long to see name and preference text
    viewQuestionTime = 2;  %how long to see "what will they choose?"
    viewItemTime = 2;  %how long to look at the items before mouse moves
    postTrialTime = 1;  %time after the first part of the trials ends (before repeat or next trial)
    viewRepeatName = 2;  %time for "two years later!"
    response_dur = 2; %how long to repond to questions
    
else %testing times!
    resttime = 0;  %start and end of experiment loop
    breakBeforeTrial = 0;  %before each trial
    viewPreferenceTime = 1; %how long to see name and preference text
    viewQuestionTime = 1;  %how long to see "what will they choose?"
    viewItemTime = 1;  %how long to look at the items before mouse moves
    postTrialTime = 0;  %time after the first part of the trials ends (before repeat or next trial)
    viewRepeatName = 1;  %time for "two years later!"
    response_dur = 1; %how long to repond to questions
end




%set the directories
rootdir = '~/Dropbox/Experiments/FoodItems';
stimdir = fullfile(rootdir, 'stimuli');
behavdir = fullfile(rootdir, 'behavioural');

addpath(genpath(rootdir));

femaledir = fullfile(rootdir, 'stimuli','Faces','Female');
maledir = fullfile(rootdir, 'stimuli','Faces','Male');
itemdir = fullfile(rootdir, 'stimuli','Items');
facedir = fullfile(rootdir, 'stimuli','Faces','All');

if therun == 1
    %grab the stimuli
    run = therun;
    cd(stimdir);
    load('items.mat');  %loads item_list: item number, gender, preference text
    
    cd(femaledir)
    female_faces = adir('*');
    
    cd(maledir)
    male_faces = adir('*');
    
    cd(itemdir)
    all_items = adir('*');
    
    %we only need to get the stim set up once
    
    %make the whole stim list
    %item_master: trial, preferece (A or B), item number, gender, preference, expected, ratio, direction, faceimage
    ntotaltrials = 300;
    item_master = vertcat([repmat({'A'},ntotaltrials/2,1), item_list(1:ntotaltrials/2, [1,2, 3 , 4])]  ,[repmat({'B'},ntotaltrials/2,1), item_list(1:ntotaltrials/2, [1,2, 4, 3])]);
    
    %randomly sort the trials
    item_master = [Shuffle(num2cell(1:length(item_master)))' item_master];
    [A, index] = sort(cell2mat(item_master(:,1)));
    B = item_master(index,2);
    C = item_master(index,3);
    D = item_master(index,4);
    E = item_master(index,5);
    F = item_master(index,6);
    item_master = [num2cell(A) B C D E F];
    
    %conditions are done per run, so that each run has the same number
    nruns = 5;
    itemn = 1;
    trialsperrun = ntotaltrials/nruns;
    for thisRun = 1:nruns
        if mod(thisRun,2) == 0   %if even
            [conditions, index] = Shuffle(condition_list_even(:,1));
            directions = condition_list_even(index,2);
            ratios = condition_list_even(index,3);
            repeats = condition_list_even(index,4);
        else
            [conditions, index] = Shuffle(condition_list_odd(:,1));
            directions = condition_list_odd(index,2);
            ratios = condition_list_odd(index,3);
            repeats = condition_list_odd(index,4);
        end
        item_master(itemn:itemn+length(ratios)-1 ,7) = conditions;
        item_master(itemn:itemn+length(ratios)-1 ,8) = ratios;
        item_master(itemn:itemn+length(ratios)-1 ,9) = directions;
        item_master(itemn:itemn+length(ratios)-1 ,15) = repeats;
        
        itemn= itemn+length(ratios);
        
        
    end
    
    
    %randomize order of names and faces, by gender
    female_faces = Shuffle(female_faces);
    male_faces = Shuffle(male_faces);
    female_names = Shuffle(female_names);
    male_names = Shuffle(male_names);
    
    %assign faces and names to items, by gender
    fcount = 1;
    mcount = 1;
    for n = 1:length(item_master)
        if item_master{n,4}=='F'
            item_master(n,10) = female_faces(fcount);
            item_master(n,11) = female_names(fcount);
            fcount = fcount+1;
        elseif item_master{n,4}=='M'
            item_master(n,10) = male_faces(mcount);
            item_master(n,11) = male_names(mcount);
            mcount = mcount + 1 ;
        end
    end
    
    %redo for 10 runs 
    nruns = 10;
    itemn = 1;
    trialsperrun = ntotaltrials/nruns;
    
    %set up the catch trials
    catchtrialn = 5;  %how many catch trials of each type? (per run)
    startoff = 5;  %how many trials before a question is allowed?
    
    types = [];
    types = vertcat(repmat({'actionPrediction'}, catchtrialn,1),repmat({'itemRecall'}, catchtrialn,1),repmat({'prefRecall'}, catchtrialn,1));
    types = vertcat(types, repmat({'oneShot'}, ntotaltrials/nruns - length(types)-startoff,1));
    
    allTypes = [];
    for thisRun  = 1:nruns
        types = Shuffle(types);
        types_full = vertcat( repmat({'oneShot'},startoff,1), types);
        allTypes = vertcat(allTypes,types_full);
    end
    
    
    
    %pre-set items  (this is not the experimental loop!)
    for trial = 1:length(item_master)
        
        %which item?
        trialString = sprintf('%02d_',item_master{trial,3});
        
        %which pictures?
        theItems = all_items(strncmp(all_items,trialString,3));
        
        PrefA = Shuffle(theItems(1:3));
        PrefB = Shuffle(theItems(4:6));
        
        if strcmp(item_master{trial,7},'Expected')
            %if preference = prefA
            if strcmp(item_master{trial,2},'A')
                item_master{trial, 12}  = PrefA(1);
                if strcmp(item_master{trial,8},'1:3')
                    item_master{trial, 13} = PrefB;
                elseif strcmp(item_master{trial,8},'2:2')
                    item_master{trial, 13} = [PrefA(2) PrefB(1:2)];
                elseif strcmp(item_master{trial,8},'3:1')
                    item_master{trial, 13} = [PrefA(2:3) PrefB(1)];
                end
                %if preference = prefB
            elseif strcmp(item_master{trial,2},'B')
                item_master{trial, 12}  = PrefB(1);
                if strcmp(item_master{trial,8},'1:3')
                    item_master{trial, 13} = PrefA;
                elseif strcmp(item_master{trial,8},'2:2')
                    item_master{trial, 13} = [PrefB(2) PrefA(1:2)];
                elseif strcmp(item_master{trial,8},'3:1')
                    item_master{trial, 13} = [PrefB(2:3) PrefA(1)];
                end
            end
            
            %decide how to name the 3:1 for the unexpected
        elseif strcmp(item_master{trial,7},'Unexpected')
            if strcmp(item_master{trial,2},'B')
                item_master{trial, 12}  = PrefA(1);
                if strcmp(item_master{trial,8},'1:3')
                    item_master{trial, 13} = PrefB;
                elseif strcmp(item_master{trial,8},'2:2')
                    item_master{trial, 13} = [PrefA(2) PrefB(1:2)];
                elseif strcmp(item_master{trial,8},'3:1')
                    item_master{trial, 13} = [PrefA(2:3) PrefB(1)];
                end
                %if preference = prefB
            elseif strcmp(item_master{trial,2},'A')
                item_master{trial, 12} = PrefB(1);
                if strcmp(item_master{trial,8},'1:3')
                    item_master{trial, 13} = PrefA;
                elseif strcmp(item_master{trial,8},'2:2')
                    item_master{trial, 13} = [PrefB(2) PrefA(1:2)];
                elseif strcmp(item_master{trial,8},'3:1')
                    item_master{trial, 13} = [PrefB(2:3) PrefA(1)];
                end
            end
            
        end
        
        %add the catch trials
        item_master{trial, 14} = allTypes(trial);
        
    end
    
    
    %key presses
    item_master(:,16) = {NaN};  %RT
    item_master(:,17) = {NaN};  %key press
    item_master(:,18) = {NaN};  %trials for recall
    
    cd(behavdir);
    save([subID '.FI.1.mat']);
else cd(behavdir)
    load([subID '.FI.1.mat']);
    run = therun; %overwrite the loaded run
end


eventTimes = [];
eventTypes = {};
eventDurs = [];
eventTrial = [];

respStart = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  %actual trial loop  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen(window,'TextSize',40);
HideCursor;
DrawFormattedText(window,sprintf('Get ready!'),'center','center');

Screen('Flip',window);
waitPulse()

expStart = GetSecs;
trialStart = [];
trialstart = (run-1)*trialsperrun + 1;
Screen('Flip',window);
pause(resttime)
for trial = trialstart:trialstart+trialsperrun-1
    
    % for trial = trialstart:trialstart+10  %FOR TESTING ONLY
    
    sprintf('trial %d \n',trial)
    
    targetItem = item_master{trial,12};
    nonTargetItems = item_master{trial,13};
    
    %get the center of the items
    xoff = 300;
    yoff = 200;
    scale = 4;
    
    iLeft_center = [x0-xoff y0];
    iRight_center = [x0+xoff y0];
    iTop_center = [x0 y0-yoff];
    iBottom_center = [x0 y0+yoff];
    
    %assign the items to locations
    nonTargetItems = Shuffle(nonTargetItems);
    if strcmp(item_master{trial,9},'Left')
        iLeft = targetItem;
        iRight = nonTargetItems(1);
        iTop = nonTargetItems(2);
        iBottom = nonTargetItems(3);
        targetLocation = iLeft_center;
    elseif strcmp(item_master{trial,9},'Right')
        iRight = targetItem;
        iLeft = nonTargetItems(1);
        iTop = nonTargetItems(2);
        iBottom = nonTargetItems(3);
        targetLocation = iRight_center;
    elseif strcmp(item_master{trial,9},'Top')
        iTop = targetItem;
        iLeft = nonTargetItems(1);
        iRight = nonTargetItems(2);
        iBottom = nonTargetItems(3);
        targetLocation = iTop_center;
    elseif strcmp(item_master{trial,9},'Bottom')
        iBottom = targetItem;
        iLeft = nonTargetItems(1);
        iRight = nonTargetItems(2);
        iTop = nonTargetItems(3);
        targetLocation = iBottom_center;
    end
    
    
    %which text
    prefText = item_master{trial,5};
    nameText = item_master{trial,11};
    
    face_array = imread(sprintf(fullfile(facedir,item_master{trial,10})));
    iLeft_array = imread(sprintf(fullfile(itemdir,iLeft{1})));
    iRight_array = imread(sprintf(fullfile(itemdir,iRight{1})));
    iTop_array = imread(sprintf(fullfile(itemdir,iTop{1})));
    iBottom_array = imread(sprintf(fullfile(itemdir,iBottom{1})));
    
    face = Screen('MakeTexture',window,face_array);
    item1 = Screen('MakeTexture',window,iLeft_array);
    item2 = Screen('MakeTexture',window,iRight_array);
    item3 = Screen('MakeTexture',window,iTop_array);
    item4 = Screen('MakeTexture',window,iBottom_array);
    
    siLeft = size(iLeft_array);
    siRight = size(iRight_array);
    siTop = size(iTop_array);
    siBottom = size(iBottom_array);
    
    
    iLeftrect= [x0-xoff-siLeft(1)/scale y0-siLeft(2)/scale,x0-xoff+siLeft(1)/scale y0+siLeft(2)/scale]';
    iRightrect= [x0+xoff-siRight(1)/scale y0-siRight(2)/scale,x0+xoff+siRight(1)/scale y0+siRight(2)/scale]';
    iToprect= [x0-siTop(1)/scale y0-yoff-siTop(2)/scale,x0+siTop(1)/scale y0-yoff+siTop(2)/scale]';
    iBottomrect= [x0-siBottom(1)/scale y0+yoff-siBottom(2)/scale,x0+siBottom(1)/scale y0+yoff+siBottom(2)/scale]';
    
    rects = [iLeftrect iRightrect iToprect iBottomrect];
    
    %display things
    
    %face
    Screen('DrawTextures', window, [face], [], [iToprect]);
    item_master{trial,10} %print out for debugging
    
    %name
    Screen('TextSize',window, 30)
    DrawFormattedText(window, nameText,'center','center',[1,1,1],160);
    
    %preference
    Screen('TextSize',window, 30)
    DrawFormattedText(window, ['I ' prefText],'center',iBottomrect(2),[1,1,1],160);
    
    %take out after testing
    testText = [item_master{trial,7},'_', item_master{trial,8},'_', item_master{trial,9}];
    %DrawFormattedText(window, testText,0,0,[1,1,1],20);
    
    pause(breakBeforeTrial)
    while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
    trialStart(trial) = GetSecs-expStart;
    
    Screen('Flip', window);
    time = GetSecs - expStart;
    type = 'trial_start';
    eventTimes = vertcat(eventTimes, time);
    eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
    
    pause(viewPreferenceTime);
    eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
    
    if strcmp(item_master{trial, 14},'actionPrediction')
        sprintf('action prediction')
        questionText = 'Which do you think they will choose?';
        DrawFormattedText(window, questionText,'center','center',[1,1,1],20);
        
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'action_prediction_question';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        pause(viewQuestionTime);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        
        Screen('DrawTextures', window, [item1 item2 item3 item4], [], rects);
        DrawFormattedText(window, '?','center','center',[1,1,1],20);
        
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'action_prediction_items';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        respStart(trial) = GetSecs-expStart;
        response_start = GetSecs;
        
        getResponse;
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
    end
    
    Screen('DrawTextures', window, [item1 item2 item3 item4], [], rects);
    
    while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
    Screen('Flip', window);
    time = GetSecs - expStart;
    type = 'trial_items';
    eventTimes = vertcat(eventTimes, time);
    eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
    
    moveMouse;
    
    Screen('Flip', window);
    eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
    
    
    pause(postTrialTime);
    
    if strcmp(item_master{trial, 15},'repeat_expected')
        sprintf('%d \n',trial)
        sprintf('repeat expected')
        
        %put the character back on the screen
        Screen('DrawTextures', window, [face], [], [iToprect]);
        Screen('TextSize',window, 30);
        months = Randi(15);
        DrawFormattedText(window, [nameText ' ' num2str(months) ' months later!'],'center','center',[1,1,1],160);
        
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'two_years_later_text';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        
        pause(viewRepeatName);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        
        %assign the items to locations
        nonTargetItems = Shuffle(nonTargetItems);
        dir = randi(4);
        if dir == 1
            iLeft = targetItem;
            iRight = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iLeft_center;
        elseif dir == 2
            iRight = targetItem;
            iLeft = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iRight_center;
        elseif dir == 3
            iTop = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iTop_center;
        elseif dir == 4
            iBottom = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iTop = nonTargetItems(3);
            targetLocation = iBottom_center;
        end
        
        
        %which text
        
        face_array = imread(sprintf(fullfile(facedir,item_master{trial,10})));
        iLeft_array = imread(sprintf(fullfile(itemdir,iLeft{1})));
        iRight_array = imread(sprintf(fullfile(itemdir,iRight{1})));
        iTop_array = imread(sprintf(fullfile(itemdir,iTop{1})));
        iBottom_array = imread(sprintf(fullfile(itemdir,iBottom{1})));
        
        face = Screen('MakeTexture',window,face_array);
        item1 = Screen('MakeTexture',window,iLeft_array);
        item2 = Screen('MakeTexture',window,iRight_array);
        item3 = Screen('MakeTexture',window,iTop_array);
        item4 = Screen('MakeTexture',window,iBottom_array);
        
        siLeft = size(iLeft_array);
        siRight = size(iRight_array);
        siTop = size(iTop_array);
        siBottom = size(iBottom_array);
        sca
        iLeftrect= [x0-xoff-siLeft(1)/scale y0-siLeft(2)/scale,x0-xoff+siLeft(1)/scale y0+siLeft(2)/scale]';
        iRightrect= [x0+xoff-siRight(1)/scale y0-siRight(2)/scale,x0+xoff+siRight(1)/scale y0+siRight(2)/scale]';
        iToprect= [x0-siTop(1)/scale y0-yoff-siTop(2)/scale,x0+siTop(1)/scale y0-yoff+siTop(2)/scale]';
        iBottomrect= [x0-siBottom(1)/scale y0+yoff-siBottom(2)/scale,x0+siBottom(1)/scale y0+yoff+siBottom(2)/scale]';
        
        rects = [iLeftrect iRightrect iToprect iBottomrect];
        
        %display things
        
        Screen('DrawTextures', window, [item1 item2 item3 item4], [], rects);
        %DrawFormattedText(window, testText,0,0,[1,1,1],20);
        
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'repeat_items';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        moveMouse;
        
        Screen('Flip', window);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        pause(postTrialTime);
        
    elseif strcmp(item_master{trial, 15},'repeat_unexpected')
        sprintf('%d \n',trial)
        sprintf('repeat expected')
        
        %put the character back on the screen
        months = Randi(15);
        Screen('DrawTextures', window, [face], [], [iToprect]);
        Screen('TextSize',window, 30);
        DrawFormattedText(window, [nameText ' ' num2str(months) ' months later!'],'center','center',[1,1,1],160);        
        
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'two_years_later_text';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        
        pause(viewRepeatName);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        
        %assign the items to locations  (picks opposite of target)
        nonTargetItems = Shuffle(nonTargetItems);
        dir = randi(4);
        if dir == 1
            iLeft = targetItem;
            iRight = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iRight_center;
        elseif dir == 2
            iRight = targetItem;
            iLeft = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iBottom_center;
        elseif dir == 3
            iTop = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation =  iLeft_center;
        elseif dir == 4
            iBottom = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iTop = nonTargetItems(3);
            targetLocation = iTop_center;
        end
        
        
        %which text
        
        face_array = imread(sprintf(fullfile(facedir,item_master{trial,10})));
        iLeft_array = imread(sprintf(fullfile(itemdir,iLeft{1})));
        iRight_array = imread(sprintf(fullfile(itemdir,iRight{1})));
        iTop_array = imread(sprintf(fullfile(itemdir,iTop{1})));
        iBottom_array = imread(sprintf(fullfile(itemdir,iBottom{1})));
        
        face = Screen('MakeTexture',window,face_array);
        item1 = Screen('MakeTexture',window,iLeft_array);
        item2 = Screen('MakeTexture',window,iRight_array);
        item3 = Screen('MakeTexture',window,iTop_array);
        item4 = Screen('MakeTexture',window,iBottom_array);
        
        siLeft = size(iLeft_array);
        siRight = size(iRight_array);
        siTop = size(iTop_array);
        siBottom = size(iBottom_array);
        
        iLeftrect= [x0-xoff-siLeft(1)/scale y0-siLeft(2)/scale,x0-xoff+siLeft(1)/scale y0+siLeft(2)/scale]';
        iRightrect= [x0+xoff-siRight(1)/scale y0-siRight(2)/scale,x0+xoff+siRight(1)/scale y0+siRight(2)/scale]';
        iToprect= [x0-siTop(1)/scale y0-yoff-siTop(2)/scale,x0+siTop(1)/scale y0-yoff+siTop(2)/scale]';
        iBottomrect= [x0-siBottom(1)/scale y0+yoff-siBottom(2)/scale,x0+siBottom(1)/scale y0+yoff+siBottom(2)/scale]';
        
        rects = [iLeftrect iRightrect iToprect iBottomrect];
        
        %display things
        
        Screen('DrawTextures', window, [item1 item2 item3 item4], [], rects);
        %DrawFormattedText(window, testText,0,0,[1,1,1],20);
        
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'repeat_items';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        moveMouse;
        
        Screen('Flip', window);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        pause(postTrialTime);
        
        
    elseif strcmp(item_master{trial, 14},'prefRecall')
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        tempTarget = randi([trial-10 trial-1]);
        if tempTarget < 1
            tempTarget = 1;
        end
        
        item_master{trial,18} = tempTarget;
        
        sprintf('recall target %d', tempTarget)
        
        %match or no match?
        coin = randi(2)
        if coin == 1
            prefText = item_master{tempTarget ,5};
        else
            prefText = item_master{tempTarget ,6};
        end
        nameText = item_master{tempTarget ,11};
        
        face_array = imread(sprintf(fullfile(facedir,item_master{tempTarget ,10})));
        face = Screen('MakeTexture',window,face_array);
        
        Screen('DrawTextures', window, [face], [], [iToprect]);
        Screen('TextSize',window, 30);
        predictionText = [nameText ' said'  '\n' '"I '  prefText '"'];
        DrawFormattedText(window, predictionText,'center','center',[1,1,1],160);
        DrawFormattedText(window, 'TRUE',iLeftrect(3),iBottomrect(2),[1,1,1],160);
        DrawFormattedText(window, 'FALSE',iRightrect(1),iBottomrect(2),[1,1,1],160);
        
        
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'pref question';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        respStart(trial) = GetSecs-expStart;
        response_start = GetSecs;
        
        getResponse;
        Screen('Flip', window);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        
        
    elseif strcmp(item_master{trial, 14},'itemRecall')
        while mod(GetSecs - expStart,2)>.0001; end %get back on the TR
        
        tempTarget = randi([trial-10 trial-1]);
        if tempTarget < 1
            tempTarget = 1;
        end
        
        sprintf('recall target %d', tempTarget)
        
        item_master{trial,18} = tempTarget;
        
        prefText = item_master{tempTarget ,5};
        nameText = item_master{tempTarget ,11};
        
        face_array = imread(sprintf(fullfile(facedir,item_master{tempTarget ,10})));
        face = Screen('MakeTexture',window,face_array);
        
        
        Screen('DrawTextures', window, [face], [], [iToprect]);
        Screen('TextSize',window, 30);
        predictionText = ['What did ' nameText ' pick?'];
        DrawFormattedText(window, predictionText,'center','center',[1,1,1],160);
        
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'item question';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        pause(viewQuestionTime);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
        
        
        targetItem = item_master{tempTarget,12};
        nonTargetItems = item_master{tempTarget,13};
        
        %get the center of the items
        %get the center of the items
        xoff = 300;
        yoff = 200;
        scale = 4;
        
        iLeft_center = [x0-xoff y0];
        iRight_center = [x0+xoff y0];
        iTop_center = [x0 y0-yoff];
        iBottom_center = [x0 y0+yoff];
        
        %assign the items to locations
        nonTargetItems = Shuffle(nonTargetItems);
        if strcmp(item_master{tempTarget,9},'Left')
            iLeft = targetItem;
            iRight = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iLeft_center;
        elseif strcmp(item_master{tempTarget,9},'Right')
            iRight = targetItem;
            iLeft = nonTargetItems(1);
            iTop = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iRight_center;
        elseif strcmp(item_master{tempTarget,9},'Top')
            iTop = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iBottom = nonTargetItems(3);
            targetLocation = iTop_center;
        elseif strcmp(item_master{tempTarget,9},'Bottom')
            iBottom = targetItem;
            iLeft = nonTargetItems(1);
            iRight = nonTargetItems(2);
            iTop = nonTargetItems(3);
            targetLocation = iBottom_center;
        end
        
        
        %which text
        prefText = item_master{tempTarget,5};
        nameText = item_master{tempTarget,11};
        
        face_array = imread(sprintf(fullfile(facedir,item_master{tempTarget,10})));
        iLeft_array = imread(sprintf(fullfile(itemdir,iLeft{1})));
        iRight_array = imread(sprintf(fullfile(itemdir,iRight{1})));
        iTop_array = imread(sprintf(fullfile(itemdir,iTop{1})));
        iBottom_array = imread(sprintf(fullfile(itemdir,iBottom{1})));
        
        face = Screen('MakeTexture',window,face_array);
        item1 = Screen('MakeTexture',window,iLeft_array);
        item2 = Screen('MakeTexture',window,iRight_array);
        item3 = Screen('MakeTexture',window,iTop_array);
        item4 = Screen('MakeTexture',window,iBottom_array);
        
        siLeft = size(iLeft_array);
        siRight = size(iRight_array);
        siTop = size(iTop_array);
        siBottom = size(iBottom_array);
        
        
        iLeftrect= [x0-xoff-siLeft(1)/scale y0-siLeft(2)/scale,x0-xoff+siLeft(1)/scale y0+siLeft(2)/scale]';
        iRightrect= [x0+xoff-siRight(1)/scale y0-siRight(2)/scale,x0+xoff+siRight(1)/scale y0+siRight(2)/scale]';
        iToprect= [x0-siTop(1)/scale y0-yoff-siTop(2)/scale,x0+siTop(1)/scale y0-yoff+siTop(2)/scale]';
        iBottomrect= [x0-siBottom(1)/scale y0+yoff-siBottom(2)/scale,x0+siBottom(1)/scale y0+yoff+siBottom(2)/scale]';
        
        rects = [iLeftrect iRightrect iToprect iBottomrect];
        
        DrawFormattedText(window, '?','center','center',[1,1,1],160);
        Screen('DrawTextures', window, [item1 item2 item3 item4], [], rects);
        Screen('Flip', window);
        time = GetSecs - expStart;
        type = 'item question items';
        eventTimes = vertcat(eventTimes, time);
        eventTypes{end+1} = type; eventTrial = vertcat(eventTrial, trial);
        
        respStart(trial) = GetSecs-expStart;
        response_start = GetSecs;
        
        getResponse;
        Screen('Flip', window);
        eventDurs = vertcat(eventDurs, (GetSecs-expStart)-time);
    end
    
    expEnd(trial) = GetSecs-expStart;
    ips_calc = max(expEnd);
    save ([subID '.FI.' num2str(run) '.mat'], 'item_master', 'all_items','IDnum','ips','item_list','item_master','nruns', 'ntotaltrials','randseed',...
        'subID','run','expStart', 'trialstart', 'respStart', 'expEnd', 'eventTimes', 'eventTypes', 'eventDurs', 'eventTrial','trialsperrun','trial', 'ips_calc')
    if mod(trial,20)==0
        pause(resttime)
    end
end
Screen('Flip', window);
pause(resttime)

expEnd(trial) = GetSecs-expStart;
ips_calc = max(expEnd);
save ([subID '.FI.' num2str(run) '.mat'], 'item_master', 'all_items','IDnum','ips','item_list','item_master','nruns', 'ntotaltrials','randseed',...
    'subID','run','expStart', 'trialstart', 'respStart', 'expEnd', 'eventTimes', 'eventTypes', 'eventDurs', 'eventTrial','trialsperrun','trial', 'ips_calc')


cd(behavdir);

ShowCursor;
cd(rootdir);
warning on;
sca;
Screen('CloseAll');
%clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% HELPER FUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function waitDuration = waitPulse()

%startTime = getSecs;
noTTLpulse = 1;
back = KbName('=+');
%back = KbName('+');
while (noTTLpulse)
    [keyIsDown,secs,keyCode] = KbCheck(-3);
    if (keyIsDown)
        if (keyCode(back))
            sprintf('Pulse detected.\n');
            noTTLpulse = 0;
            stopTime = GetSecs;
        end
    end
end

%waitDuration = stopTime - startTime;
return;









