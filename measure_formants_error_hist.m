cd(fullfile(outputdir,expt.snum));
load(p);

fs = fusp_init.sample_rate;
frame_size = fusp_init.data_size;
nframes = fusp_init.nframes_per_trial;
frame_taxis = (0:(nframes-1))*frame_size/fs;
magspec_size = fusp_init.magspec_size;
faxis = linspace(0,fs/2,magspec_size);

vhs = [];
vhs = add2vechists(vhs,'inbuffer');
vhs = add2vechists(vhs,'outbuffer');
if frame_size ~= vhs.inbuffer.vec_size, error('ipset:frame_size(%d) != inbuffer:frame_size(%d)', frame_size, vhs.inbuffer.vec_size); end
if nframes ~= vhs.inbuffer.nvecs, error('ipset:nframes(%d) != inbuffer:nframes(%d)', nframes, vhs.inbuffer.nvecs); end

vhs = add2vechists(vhs,'weighted_mean_abs_inbuffer');
vhs = add2vechists(vhs,'pitch');
vhs = add2vechists(vhs, 'pitch_strength');
vhs = add2vechists(vhs, 'lpc_inbuf_formants', 'peaklist');

ntrials_show = 9;
nformants_show = 2;

formant_color = {'b','r','g'};
hf = figure;
set(hf,'Position',[209          30          1351            945]);

for itrial_show = 1:ntrials_show
    clf
    nspl = 4;
    ispl = 0;
    [ispl,hax] = make_subplots(nspl,ispl,frame_taxis,squeeze(vhs.weighted_mean_abs_inbuffer.data(itrial_show,:)),[],[],'ampl',sprintf('trial(%d)',itrial_show)); spl_hax(ispl) = hax;
    [ispl,hax] = make_subplots(nspl,ispl,frame_taxis,squeeze(vhs.pitch.data(itrial_show,:)),[],[],'pitch',[]); spl_hax(ispl) = hax;
    [ispl,hax] = make_subplots(nspl,ispl,frame_taxis,squeeze(vhs.pitch_strength.data(itrial_show,:)),[],[],'pstrength',[]); spl_hax(ispl) = hax;
    [ispl,hax] = make_subplots(nspl,ispl,frame_taxis,squeeze(vhs.lpc_inbuf_formants_freq.data(itrial_show,:,1:nformants_show))',formant_color,'time (sec)','formants',[]); spl_hax(ispl) = hax;
    [itime_show,duh] = ginput(1); % seconds
    a = axis;
    if (itime_show > a(2)) || (itime_show < a(1))
      yes_bad_trial = 1;
    else
      yes_bad_trial = 0;
    end
    if yes_bad_trial
      vowelspace(itrial_show,:) = NaN*ones(1,nformants_show);
    else
    for i = 1:nspl
      axes(spl_hax(i)); hl = vline(itime_show,'r'); set(hl,'LineWidth',3); move2back([],hl);
    end
    iframe_show = dsearchn(frame_taxis',itime_show);
    fprintf('%.0f ',vhs.lpc_inbuf_formants_freq.data(itrial_show,iframe_show,1:nformants_show));
    fprintf('\n');
    vowelspace(itrial_show,:) = vhs.lpc_inbuf_formants_freq.data(itrial_show,iframe_show,1:nformants_show);
  end
end

close all

cd(fullfile(outputdir,expt.snum));
load(exprparams);
saystrings = expt.words;
save(fullfile(outputdir,expt.snum,sprintf('vowelspace_%s',expt.snum)),'vowelspace','saystrings');