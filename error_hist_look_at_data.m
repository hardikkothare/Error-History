%Formant specification parameters
fspec.nformants_to_plot = 2;
fspec.formant_colors = {'b','r'};
fspec.pick_method = 'mid_utt'; %Either 'mid_utt' or 'max_voice'
fspec.ms_avg_win = 200; %Width of averaging window around center specified by pick_method
fspec.avg_method = 'median'; %Either 'mean' or 'median'

%Voicing specification parameters
vspec.ms_smooth = 50;
vspec.voicing_thresh = 5.0;
vspec.ms_before_vonset = 30;
vspec.ms_after_vonset = 30;
vspec.ms_voice_gap_max = 30;
vspec.ms_voicing_min = 300;

%Experiment specification parameters
cd(fullfile(outputdir, expt.snum));
cd('speak');
load('p');
espec.fs = fusp_init.sample_rate;
espec.frame_size = fusp_init.data_size;
espec.nframes = fusp_init.nframes_per_trial;
espec.frame_taxis = (0:(espec.nframes-1))*espec.frame_size/espec.fs;
espec.taxis = (0:(espec.nframes*espec.frame_size-1))/espec.fs;
espec.nblocks = fusp_init.nblocks;

fspec.nframes_avg_win = round((fspec.ms_avg_win/1000)*espec.fs/espec.frame_size);
if fspec.nframes_avg_win == 0
    fspec.half_nframes_avg_win = 0;
else
    if ~rem(fspec.nframes_avg_win,2), fspec.nframes_avg_win = fspec.nframes_avg_win + 1; 
    end
    fspec.half_nframes_avg_win = (fspec.nframes_avg_win - 1)/2;
end

hf_utt = [];
hf_voice = [];

ntrials = 0;
curexprdir = cd(fullfile(outputdir, expt.snum));
curspeakdir = cd('speak');
for iblock = 1:espec.nblocks
    blockdir = sprintf('block%d', iblock-1);
    fprintf('...getting data from %s...\n',blockdir);
    cd(blockdir);
    vhs = [];
    vhs = add2vechists(vhs,'inbuffer');
    vhs = add2vechists(vhs,'outbuffer');
    vhs = add2vechists(vhs,'weighted_mean_abs_inbuffer');
    vhs = add2vechists(vhs,'pitch');
    vhs = add2vechists(vhs,'pitch_strength');
    vhs = add2vechists(vhs,'lpc_inbuf_formants','peaklist');
    vhs = add2vechists(vhs,'lpc_outbuf_formants','peaklist');
    ntrials_this_block = vhs.inbuffer.ntrials;
    for itrial_in_block = 1:ntrials_this_block
        ntrials = ntrials + 1;
        the_trial = get_the_trial(vhs,ntrials,iblock,itrial_in_block,fspec);
        utt(ntrials) = get_the_utt(the_trial,vspec,fspec,espec,hf_utt,hf_voice);
    end
    cd(curspeakdir);
end
cd(curexprdir);

[bcbl_data_dir,bcbl_expr,duh] = fileparts(curexprdir);

figure
good_trials = find([utt.good] == 1);
baseline_trials = find(good_trials <= 20);
Fin_dat = [utt.Fin];
Fout_dat = [utt.Fout];
Fin_baseline = mean(Fin_dat(:,baseline_trials),2);
for ifmt = 1:fspec.nformants_to_plot
  ispl = 2 - ifmt + 1;
  subplot(2,1,ispl);
  hpl = plot(good_trials,Fin_dat(ifmt,:),[fspec.formant_colors{ifmt} '*']);
  hold on
  hpl = plot(good_trials,Fout_dat(ifmt,:),[fspec.formant_colors{ifmt} 'o']);
  hl = hline(Fin_baseline(ifmt),'k');
  ylabel(sprintf('F%d',ifmt));
  switch ifmt
    case 1, legend('in','out','Location','NorthEast'); xlabel('trial #');
    case 2, legend('in','out','Location','SouthEast'); ht = title(error_hist); set(ht,'Interpreter','none');
  end
end
print -dpdf results.pdf
