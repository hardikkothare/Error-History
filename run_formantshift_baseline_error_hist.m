function run_formantshift_baseline_error_hist(subjID, outputdir)

if nargin < 2
    outputdir = '/home/houde/data/error_hist';
    if nargin < 1
        subjID = input('Enter participant ID number: ');
    end
end
if ~exist(fullfile(outputdir, subjID))
    mkdir(fullfile(outputdir, subjID))
end

cd([outputdir '/' subjID])
if ~exist('ftrackparams2use.mat') 
    disp('No nlpc data available, using defaults')
    nlpc2use = 11;
    fpreemph_cut2use = 1500;   
else
    load ftrackparams2use
end
cd(outputdir);

% Experiment settings
%promptwords2use = {'
expt.baselinevowels = {'EH', 'I', 'AH'};
nreps = 3;
expt.snum = subjID;
expt.type = 'formant_baseline';
expt.ntrials_per_block= length(promptwords2use);
expt.nblocks = nreps;
feedback_level = 0;
noise_level = 0;

%FUSP settings
p.fusp_datadir = outputdir;
p.yes_running_fake_fusp = 0;
p.yes_debug = 0;
p.fpreemph_cut_Hz = fpreemph_cut2use;

%IP
p.fusp_init.expr_dir = expt.snum;
p.fusp_init.expr_subdir = expt.name;
p.fusp_init.nframes_per_trial = 600;
p.fusp_init.ntrials_per_block = expt.ntrials_per_block;

%CP
p.fusp_ctrl.outbuffer_scale_fact = feedback_level;
p.fusp_ctrl.noise_scale_fact = noise_level;
%p.fusp_ctrl.process_inbuffer = 

%Start FUSP Lite
[p,ffd] = init_fusp_lite(p);

%Experiment code
h_fig = figure;
axis off;

for iblock=1:expt.nblocks
    fusp_advance_block(p,iblock);
    if iblock == 1
        write_filtcoffs(p);
    end
    
    for itrial = 1:expt.ntrials_per_block
        fusp_advance_trial(itrial);
        text(.5,.5,promptwords2use{itrial},'FontSize',32,'HorizontalAlignment','center')
        fusp_record_start;
        fusp_record_stop;
        pause(1);
    end
     fusp_save_vec_hists(ffd);
end

close(h_fig)

%Close FUSP
fusp_lite_finish(ffdp);

%Save parameters
savedir = fullfile(outputdir, expt.snum, expt.type);
exprparams = p.fusp_init;
save(fullfile(savedir,'exprparams.mat'), '-struct', 'exprparams');
save(fullfile(savedir, 'expt.mat'), 'expt');
      
pause

[nlpc2use, fpreemph_cut2use] = run_format_tracking_error_hist(outputdir, subjID, promptwords2use, 2);
save(fullfile(outputdir, subjID, 'ftrackparams2use.mat'),'nlpc2use','fpreemph_cut2use')