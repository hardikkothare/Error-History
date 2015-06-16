function [ ] = run_fusp_error_hist(subjID)

    if nargin<1
        subjID=input('Enter participant ID number: ', 's');
    end


  outputdir = '/home/houde/data/error_hist';
  if ~exist(outputdir,'dir')
     mkdir(outputdir)
  end

% Set the fields for struct expt
expt.snum = subjID;
 
cd(fullfile(outputdir, expt.snum));
load('vowelshift_params.mat');
expt.words = {'bed','pet','gem','peg','ten'};
expt.vowels = {'EH','EH','EH','EH','EH'};
expt.shift.F1 = shifts.EH2I(1);
expt.shift.F2 = shifts.EH2I(2);
savedir = fullfile(outputdir, expt.snum);
save(fullfile(savedir, 'expt.mat'), 'expt');
% Load predetermined lpc
if ~exist(fullfile(outputdir,expt.snum),'dir')
    mkdir(fullfile(outputdir,expt.snum))
end
cd(fullfile(outputdir,expt.snum))
if ~exist('ftrackparams2use.mat')
    disp('No LPC data available, run baseline code')
else
    load ftrackparams2use
    disp('LPC data loaded')
end
cd(outputdir)

% Set number of trials per phase and per block
baseline_n = 30;
shift1_n = 30;
hold_n = 70;
baseline2_n = 60;
shift2_n = 50;
washout_n = 30;
expt.ntrials = baseline_n + shift1_n + hold_n + baseline2_n + shift2_n + washout_n;
expt.ntrials_per_block = 9;
expt.nblocks = expt.ntrials ./ expt.ntrials_per_block;

% Set up word list
expt.allWords = ceil(randperm(expt.ntrials)/(expt.ntrials/length(expt.words)));
expt.listWords = expt.words(expt.allWords);
expt.listVowels = expt.vowels(expt.allWords);

%Experiment conditions   
expt.case=input (' Case 1 or Case 2 ? : ');
switch (expt.case)
    case 1
      expt.conds = {'baseline' 'shift1' 'hold' 'baseline2' 'shift2' 'washout'};
      expt.allConds = [ones(1,baseline_n) 2.*ones(1,shift1_n) 3.*ones(1,hold_n) 4.*ones(1,baseline2_n) 5.*ones(1,shift2_n) 6.*ones(1,washout_n)];
      ramp_F1 = linspace(0,expt.shift.F1,shift1_n);
      ramp_F2 = linspace(0,expt.shift.F2,shift1_n);
      expt.condValues.F1 = [zeros(1,baseline_n) ramp_F1 repmat(expt.shift.F1,1,hold_n) zeros(1,baseline2_n) repmat(expt.shift.F1,1,shift2_n) zeros(1,washout_n)];
      expt.condValues.F2 = [zeros(1,baseline_n) ramp_F2 repmat(expt.shift.F2,1,hold_n) zeros(1,baseline2_n) repmat(expt.shift.F2,1,shift2_n) zeros(1,washout_n)];   
    case 2
      expt.conds = {'baseline' 'hold' 'shift1' 'baseline2' 'shift2' 'washout'};
      expt.allConds = [ones(1,baseline_n) 2.*ones(1,hold_n) 3.*ones(1,shift1_n)  4.*ones(1,baseline2_n) 5.*ones(1,shift2_n) 6.*ones(1,washout_n)];
      ramp_F1 = linspace(expt.shift.F1,0,shift1_n);
      ramp_F2 = linspace(expt.shift.F2,0,shift1_n);
      expt.condValues.F1 = [zeros(1,baseline_n) repmat(expt.shift.F1,1,hold_n) ramp_F1  zeros(1,baseline2_n) repmat(expt.shift.F1,1,shift2_n) zeros(1,washout_n)];
      expt.condValues.F2 = [zeros(1,baseline_n) repmat(expt.shift.F2,1,hold_n) ramp_F2  zeros(1,baseline2_n) repmat(expt.shift.F2,1,shift2_n) zeros(1,washout_n)]; 
end
% Set experiment-specific FUSP parameters
p.fusp_datadir = outputdir;
p.yes_running_fake_fusp = 0;
p.yes_debug = 0;

% init parameters
p.fusp_init.expr_dir = sprintf('%s', expt.snum);
p.fusp_init.nframes_per_trial = 600;
p_fusp_init.ntrials_per_block = expt.ntrials_per_block;
p.fusp_init.nblocks = expt.nblocks;

% Control parameters
  p.fusp_ctrl.outbuffer_scale_fact = 10;
  p.fusp_ctrl.noise_scale_fact = 0;
% fusp_ctrl.inbuffer_source =
% fusp_ctrl.process_inbuffer =

% Start FUSP
[p,ffd] = init_fusp_lite(p);

% Save initial FUSP params
savefile = fullfile(outputdir,expt.snum,'p.mat');
save(savefile,'p');

% Experiment Code
h = figure;
axis off;
n_trial = 1;
for iblock=1:expt.nblocks
    fusp_advance_block(p,iblock);	% Tell FUSP what block it is
    for itrial = 1:expt.ntrials_per_block
        fusp_advance_trial(itrial);	% Tell FUSP what trial it is 
        figure(h);
        text(.5,.5,expt.listWords{n_trial},'FontSize',32,'HorizontalAlignment','center') % Display the word to be spoken
        send_fusp_cpset('F1shift_Hz',expt.condValues.F1(n_trial)); % Tell fusp to shift F1
        send_fusp_cpset('F2shift_Hz',expt.condValues.F2(n_trial)); % Tell fusp to shift F2
        rem = mod (n_trial,5);
        if rem == 0
            send_fusp_cpset('noise_scale_fact', 2000);
                
        end
        fusp_record_start;          % Record for nframes_per_trial (init parameter, set above)
        fusp_record_stop;           % Stop recording
        send_fusp_cpset('noise_scale_fact', 0);
        pause(0.5);
        cla
        pause(0.5);
        n_trial = n_trial +1;
    end
    fusp_save_vec_hists(ffd); % Save data at end of each block
    % Take a break
    text(.5,.5,'Take a break! Press space to continue.','FontSize',32,'HorizontalAlignment','center')
    waitforbuttonpress
    cla ;
    pause(0.5);
end
close(h);

% Close FUSP
fusp_lite_finish(ffd,p);

% Save data
savedir = fullfile(outputdir, expt.snum);
exprparams = p.fusp_init;
save(fullfile(savedir, 'exprparams.mat'), '-struct', 'exprparams')
save(fullfile(savedir, 'expt.mat'), 'expt')