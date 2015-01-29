function [nlpc2use, fpreemph_cut2use] = run_formant_tracking_error_hist(outputdir, subjID, promptwords2use, test_block)

if nargin < 4, test_block = 2
end
cd(outputdir);

%Experiment settings
expt.snum = subjID;
expt.ntrials_per_block = length(promptwords2use);
expt.nblocks = 3;
feedback_level = 0;
noise_level = 0;

%Preemphasis and NLPC choices
test_nlpc = [9 11 13 15];
nnlpc = length(test_nlpc);
test_fpreemph_cut = [1200 1500 1800 2100];
npreemph = length(test_fpreemph_cut);

%Set directory of audio files and nlpc test files
datadir = [outputdir '/' subjID '/formant_baseline/block' num2str(test_block-1)];
cd(datadir);
vh_inbuffer4fakeaudio = get_vec_hist6('inbuffer',3);
cd(outputdir);
expt.type = 'nlpc_test';

for inlpc = 1:nnlpc
    hf(inlpc) = figure;
    set(hf(inlpc),'Position', [209          30        1351          945]);
    set(hf(inlpc),'Name',sprintf('nlpc(%d)',test_nlpc(inlpc)));
    clear p;
    cd(outputdir);
    
    %FUSP parameters
    p.fusp_datadir = outputdir;
    p.yes_running_fake_fusp = 1;
    p.yes_debug = 0;
    
    %IP
    p.fusp_init.expr_dir = expt.snum;
    p.fusp_init.expr_subdir = expt.name;
    p.fusp_init.nframes_per_trial = 600;
    p.fusp_init.ntrials_per_block = expt.ntrials_per_block;
    p.fusp_init.nlpc = test_nlpc(inlpc);
    
    %CP
    p.fusp_ctrl.outbuffer_scale_fact = feedback_level; 
    p.fusp_ctrl.noise_scale_fact = noise_level; 
    p.fusp_ctrl.process_inbuffer = 3;
    p.dir4fake_audio = datadir;
    p.startdir = pwd;
    
    %Start FUSP
    [p,ffd] = init_fusp_lite(p);
    
    %Experiment code
    for iblock = 1:npreemph 
        fusp_advance_block(p,iblock);
        p.fpreemph_cut_Hz = test_fpreemph_cut(iblock);
        write_filtcoffs(p);
        
        for itrial = 1:expt.ntrials_per_block
            vechist2rawrec(fullfile(outputdir,'fake_audio_input'),vh_inbuffer4fakeaudio,itrial,p.ichan4inbuffer);
            fusp_advance_trial(itrial);
            fusp_record_start;
            fusp_record_stop;
            send_command_to_fusp(ffd,'REWIND_AUDIO_INPUT[]');
        end
        
        fusp_save_vec_hists(ffd);
       
        %Plot data
        audio_data_vh = get_vec_hist6('inbuffer',3,iblock);
        formant_data_vh = get_vec_hist6('lpc_inbuf_formants_freq',3,iblock);
        for itrial= 1:expt.ntrials_per_block
            if iblock == 1;
                audio_sig = play_vec_hist6(audio_data_vh,itrial,[],0);
                subplot(npreemph+1,expt.ntrials_per_block,itrial);
                plot(audio_sig)
                xlim([0 p.fusp_init.nframes_per_trial.*p.fusp_init.data_size]);
                title(promptwords2use{itrial})
            end
            
            %Load formant data and plot it
            formant_sig = squeeze(formant_data_vh.data(itrial,:,:));
            subplot(npreemph+1,expt.ntrials_per_block,iblock.*3+itrial)
            plot(formant_sig)
            ylim([0 4000]);
            xlim([0 p.fusp_init.nframes_per_trial]);
            %Plot label if subplot is on left of figure
            if itrial == 1
                ylabel(num2str(test_fpreemph_cut(iblock)))
            end
        end
    end
        %Close fusp
    fusp_lite_finish(ffd,p);
end 
%Add a title to plot
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,['nlpc n = ' num2str(test_nlpc(inlpc))],'HorizontalAlignment','center','VerticalAlignment', 'top')
  
%Chose preemphasis and nlpc parameters to use 
nlpc_choice_str = ['LPC order? [' sprintf('%d/',test_nlpc(1:(end-1))) num2str(test_nlpc(end)) ']: '];
while 1
  reply = input(nlpc_choice_str,'s');
  nlpc_choice = str2num(reply);
  if ~isempty(nlpc_choice) && any(nlpc_choice == test_nlpc)
    break;
  end
end  
nlpc2use = nlpc_choice;

fpreemph_cut_choice_str = ['formant preemphasis filter cutoff? [' sprintf('%d/',test_fpreemph_cut(1:(end-1))) num2str(test_fpreemph_cut(end)) ']: '];
while 1
  reply = input(fpreemph_cut_choice_str,'s');
  fpreemph_cut_choice = str2num(reply);
  if ~isempty(fpreemph_cut_choice) && any(fpreemph_cut_choice == test_fpreemph_cut)
    break;
  end
end  
fpreemph_cut2use = fpreemph_cut_choice;    

%Close all figures
close(hf(:));

function vec_hist = get_vec_hist(name,file_type)
set_vec_types;

switch(file_type)
 case SHORT_VEC
  file_suffix = '_hist.sht';
  item_bytes = 2;
  fread_fmt = 'int16';
 case INT_VEC
  file_suffix = '_hist.int';
  item_bytes = 4;
  fread_fmt = 'int32';
 case FLOAT_VEC
  file_suffix = '_hist.flt';
  item_bytes = 4;
  fread_fmt = 'float32';
 otherwise
  error(sprintf('unrecognized file_suffix(%s)\n',file_suffix));
end
hist_file = [name file_suffix];

if ~exist(hist_file,'file')
    vec_hist = [];
    warning('%s not found',name);
    return
end

[fpt,vec_type,vec_size,nvecs,expt.ntrials_per_block,playable] = fopen_vec_hist_file(hist_file);

if file_type ~= vec_type
  error(sprintf('expected file_type(%d) ~= vec_type(%d) in header of file(%s)', ...
		file_type,vec_type,hist_file));
end
pos_header = ftell(fpt);
fseek(fpt,0,'eof');
pos_end = ftell(fpt);
fseek(fpt,pos_header,'bof');
nbytes = pos_end - pos_header;
bytes_per_frame = 4 + vec_size*item_bytes; % the '+ 4' is for the iframe
frames_in_file = nvecs*expt.ntrials;
expected_nbytes = frames_in_file * bytes_per_frame;
if nbytes ~= expected_nbytes
  error(sprintf('nbytes(%d) in file(%s) after header ~= expected_nbytes(%d) from header info', ...
		nbytes, hist_file, expected_nbytes));
end

vec_hist.name = name;
vec_hist.file = hist_file;
vec_hist.vec_type = vec_type;
vec_hist.vec_size = vec_size;
vec_hist.nvecs = nvecs;
vec_hist.expt.ntrials = expt.ntrials;
vec_hist.playable = playable;

hist_data = zeros(expt.ntrials_per_block,nvecs,vec_size);
hist_iframe = zeros(expt.ntrials_per_block,nvecs);

for i = 1:expt.ntrials
    [hist_iframe(i,:), count] = my_fread(fpt,nvecs,'int32');
    h_errchk(count,nvecs,sprintf('hist_iframe(%d,%d)',i,j),hist_file);
    [hist_data_read, count] = my_fread(fpt,nvecs*vec_size,fread_fmt);
    hist_data(i,:,:) = reshape(hist_data_read,vec_size,nvecs)';
    h_errchk(count,nvecs*vec_size,sprintf('hist_data(%d,%d)',i,j),hist_file);
end

vec_hist.iframe = hist_iframe;
vec_hist.data = hist_data;

fclose(fpt);   