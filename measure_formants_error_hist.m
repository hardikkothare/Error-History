function [ ] = measure_formants_error_hist(subjID)

    if nargin<1
        subjID=input('Enter participant ID number: ', 's');
    end


  outputdir = '/home/houde/data/error_hist';
  if ~exist(outputdir,'dir')
     mkdir(outputdir)
  end

% Set the fields for struct expt
expt.snum = subjID;

cd(fullfile(outputdir,expt.snum,'baseline'));
load('p');

fs = p.fusp_init.sample_rate;
frame_size = p.fusp_init.data_size;
nframes = p.fusp_init.nframes_per_trial;
frame_taxis = (0:(nframes-1))*frame_size/fs;
magspec_size = p.fusp_init.magspec_size;
faxis = linspace(0,fs/2,magspec_size);

file_type = 3;
for iblock = 1:3
   blockdir = sprintf('block%d',iblock-1);
   fprintf('...getting data from %s...\n',blockdir);
   curdir = cd;
   cd(blockdir);


vhs = [];
vhs.inbuffer = get_vec_hist6('inbuffer', file_type);
vhs.outbuffer = get_vec_hist6('outbuffer', file_type);
if frame_size ~= vhs.inbuffer.vec_size, error('ipset:frame_size(%d) != inbuffer:frame_size(%d)', frame_size, vhs.inbuffer.vec_size); end
if nframes ~= vhs.inbuffer.nvecs, error('ipset:nframes(%d) != inbuffer:nframes(%d)', nframes, vhs.inbuffer.nvecs); end

vhs.weighted_mean_abs_inbuffer = get_vec_hist6('weighted_mean_abs_inbuffer', file_type);
vhs.pitch = get_vec_hist6('pitch',file_type);
vhs.pitch_strength = get_vec_hist6('pitch_strength',file_type);
vhs.lpc_inbuf_formants_freq = get_vec_hist6( 'lpc_inbuf_formants_freq',file_type);

ntrials_show = 10;
nformants_show = 3;

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
      vowelspace_all(itrial_show,:) = NaN*ones(1,nformants_show);
    else
    for i = 1:nspl
      axes(spl_hax(i)); hl = vline(itime_show,'r'); set(hl,'LineWidth',3); move2back([],hl);
    end
    iframe_show = dsearchn(frame_taxis',itime_show);
    fprintf('%.0f ',vhs.lpc_inbuf_formants_freq.data(itrial_show,iframe_show,1:nformants_show));
    fprintf('\n');
    vowelspace_all(itrial_show,:,iblock) = vhs.lpc_inbuf_formants_freq.data(itrial_show,iframe_show,1:nformants_show);
    end
  cd(curdir);
end
end
close all

vowelspace = mean(vowelspace_all,3);
cd(fullfile(outputdir,expt.snum));
load('expt');
saystrings = expt.words;
save(fullfile(outputdir,expt.snum,sprintf('vowelspace_%s',expt.snum)),'vowelspace','saystrings');