subjID=input('Enter participant ID number: ', 's');
case_number=input (' Case 1 or Case 2 ? : ','s');
outputdir = '/home/houde/data/error_hist';
  if ~exist(outputdir,'dir')
     mkdir(outputdir)
  end

% Set the fields for struct expt
expt.snum = subjID;
  

expt.case = case_number;




%Experiment specification parameters
cd(fullfile(outputdir, expt.snum,expt.case));
load('dataVals');

%Formant specification parameters
fspec.nformants2plot = 2;
fspec.formant_colors = {'b','r'};
% fspec.pick_method = 'mid_utt'; %Either 'mid_utt' or 'max_voice'
% fspec.ms_avg_win = 200; %Width of averaging window around center specified by pick_method
% fspec.avg_method = 'median'; %Either 'mean' or 'median'

% fspec.nframes_avg_win = round((fspec.ms_avg_win/1000)*espec.fs/espec.frame_size);
% if fspec.nframes_avg_win == 0
%     fspec.half_nframes_avg_win = 0;
% else
%     if ~rem(fspec.nframes_avg_win,2), fspec.nframes_avg_win = fspec.nframes_avg_win + 1; 
%     end
%     fspec.half_nframes_avg_win = (fspec.nframes_avg_win - 1)/2;
% end
savefile = fullfile(outputdir,expt.snum,expt.case,'fspec.mat');
save(savefile,'fspec');

load('exprparams');
load('expt');
espec.sample_rate = sample_rate;
espec.frame_size = data_size;
espec.nframes = nframes_per_trial;
espec.frame_taxis = (0:(espec.nframes-1))*espec.frame_size/espec.sample_rate;
espec.taxis = (0:(espec.nframes*espec.frame_size-1))/espec.sample_rate;
espec.nblocks = expt.nblocks;
savefile = fullfile(outputdir,expt.snum,expt.case,'espec.mat');
save(savefile,'espec');

% ntrials = 0;
% cd('speak');
% for iblock = 1:espec.nblocks
%   blockdir = sprintf('block%d',iblock-1);
%   fprintf('...getting data from %s...\n',blockdir);
%   curdir = cd;
%   cd(blockdir);
%   vhs = [];
%   vhs.inbuffer = get_vec_hist6('inbuffer',3);
%   vhs.outbuffer = get_vec_hist6('outbuffer',3);
%   vhs.weighted_mean_abs_inbuffer = get_vec_hist6('weighted_mean_abs_inbuffer',3);
%   vhs.pitch = get_vec_hist6('pitch',3);
%   vhs.pitch_strength = get_vec_hist6('pitch_strength',3);
%   vhs.lpc_inbuf_formants_freq = get_vec_hist6('lpc_inbuf_formants_freq',3);
%   vhs.lpc_outbuf_formants_freq = get_vec_hist6('lpc_outbuf_formants_freq',3);
%   vhs.lpc_inbuf_formants_npeaks = get_vec_hist6('lpc_inbuf_formants_npeaks',2);
%   vhs.lpc_outbuf_formants_npeaks = get_vec_hist6('lpc_outbuf_formants_npeaks',2);
%   ntrials_this_block = vhs.inbuffer.ntrials;
%  %ntrials_this_block = 9;
%   for itrial_in_block = 1:ntrials_this_block
%     ntrials = ntrials + 1;
%     
%     %the_trial = get_the_trial(vhs,ntrials,iblock,itrial_in_block,fspec);
%  the_trial.Fin_sig(ntrials,:,1:fspec.nformants2plot) = vhs.lpc_inbuf_formants_freq.data(itrial_in_block,:,1:fspec.nformants2plot);
%  the_trial.Fout_sig(ntrials,:,1:fspec.nformants2plot) = vhs.lpc_outbuf_formants_freq.data(itrial_in_block,:,1:fspec.nformants2plot);
%     savefile = fullfile(outputdir,expt.snum,expt.case,'the_trial.mat');
% save(savefile,'the_trial');
%   end
%   
%   cd(curdir);
% end
% cd(fullfile(outputdir,expt.snum,expt.case));
% savefile = fullfile(outputdir,expt.snum,expt.case,'the_trial.mat');
% save(savefile,'the_trial');




load('goodfiles');
figure_1 = figure;
% figure_2 = figure;
% figure_3 = figure;
load('espec');
% load('the_trial');

load('expt');
load('dataVals');
for i = 1: length(goodfiles)
%  taxis = dataVals(1,i).ftrack_taxis';   
%  first_index = taxis(1,1);
%  last_index = taxis(1,length(taxis));
%  trial_first_index = dsearchn(espec.frame_taxis',first_index);
%  trial_last_index = dsearchn(espec.frame_taxis',last_index);
%  Fin_1_dat(i) = mean(the_trial.Fin_sig(i,trial_first_index:trial_last_index,1));
%  Fin_2_dat(i) = mean(the_trial.Fin_sig(i,trial_first_index:trial_last_index,2));
%  Fout_1_dat(i) = mean(the_trial.Fout_sig(i,trial_first_index:trial_last_index,1));
%  Fout_2_dat(i) = mean(the_trial.Fout_sig(i,trial_first_index:trial_last_index,2));
 F1_dat(i) = mean((dataVals(1,i).f1));
 F2_dat(i) = mean((dataVals(1,i).f2));
 

  ifmt = fspec.nformants2plot;
  
  figure(figure_1);
  
 
  rem = mod(goodfiles(1,i),5);
  if rem == 0
      hpl = plot(goodfiles(1,i),F1_dat(1,i),['g*']);
  else
  hpl = plot(goodfiles(1,i),F1_dat(1,i),[fspec.formant_colors{1} '*']);
  end
  hold on
  if rem == 0
      hpl = plot(goodfiles(1,i),F2_dat(1,i),['go']);
  else
  hpl = plot(goodfiles(1,i),F2_dat(1,i),[fspec.formant_colors{2} 'o']);
  end
  
%   figure(figure_2);
%   hpl = plot(goodfiles(1,i),Fin_1_dat(i),[fspec.formant_colors{1} '*']);
%   hold on
%   hpl = plot(goodfiles(1,i),Fout_1_dat(i),[fspec.formant_colors{1} 'o']);
%   
%   figure(figure_3);
%   hpl = plot(goodfiles(1,i),Fin_2_dat(i),[fspec.formant_colors{2} '*']);
%   hold on
%   hpl = plot(goodfiles(1,i),Fout_2_dat(i),[fspec.formant_colors{2} 'o']);
 end
 print -dpdf results.pdf
