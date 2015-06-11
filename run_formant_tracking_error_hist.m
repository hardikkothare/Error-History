function [nlpc2use, fpreemph_cut2use] = run_formant_tracking_error_hist(outputdir, subjID, promptwords2use, test_block)

if nargin < 4, test_block = 2
end
cd(outputdir);

%Experiment settings
expt.snum = subjID;
expt.name = 'baseline';
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
datadir = [outputdir '/' subjID '/baseline/block' num2str(test_block-1)];
cd(datadir);
vh_inbuffer4fakeaudio = get_vec_hist6('inbuffer',3);
cd(outputdir);

for inlpc = 1:nnlpc
    hf(inlpc) = figure;
    set(hf(inlpc),'Position', [209          30        1351          945]);
    set(hf(inlpc),'Name',sprintf('nlpc(%d)',test_nlpc(inlpc)));
    clear p;
    cd(outputdir);
    
    %FUSP parameters
    p.fusp_datadir = outputdir;
    p.yes_running_fake_fusp = 1;
    p.yes_debug = 1;
    p.dir4fake_audio = datadir;
    p.startdir = pwd;
    p.ichan4inbuffer = 1;
   % p.block0dir = [outputdir '/' subjID '/baseline/block0'];
    
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
    
    
    %Start FUSP
    [p,ffd] = init_fusp_lite(p);
    
    
    %Experiment code
    for iblock = 1:npreemph 
        iblock2load = fusp_advance_block(p,iblock);
        p.block0dir = [outputdir '/' subjID '/' 'baseline' '/' iblock2load];
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