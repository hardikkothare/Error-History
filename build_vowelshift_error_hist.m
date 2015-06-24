function [] = build_vowelshift_error_hist()

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
load('exprparams');
%load('p');
load('expt');

%Load vowelspace file
disp('Select subject vowelspace file ');
[vowelspace_file, vowelspace_filepath] = uigetfile;
load([vowelspace_filepath vowelspace_file]);

%Get vowel list
vowels = expt.baselinevowels;
colors = {'r' 'g' 'b' 'c' 'm'};
while length(colors) < length(vowels)
    colors = repmat(colors,1,2);
end

%Get formants
for v = 1:length(vowels)
    FAll.(vowels{v}) = vowelspace(v,:);
    %FMean. (vowels{v}) = nanmean(FAll.(vowels{v}));
end

%Plot vowels
figure('Position',[33 125 939 548]);
for v = 1:length(vowels)
    plot(FAll.(vowels{v})(:,1),FAll.(vowels{v})(:,2),'.' ,'Color', colors{v});
    hold on;
   % plot(FMean.(vowels{v})(:,1),FMean.(vowels{v})(:,2),'*');
    text(FAll.(vowels{v})(:,1),FAll.(vowels{v})(:,2),vowels{v});
end
xlabel('F1 (hz)');
ylabel('F2 (hz)');

%Compute shifts
allpairs = nchoosek(1:length(vowels),2);
allperms = [allpairs; [allpairs(:,2) allpairs(:,1)]];
allperms = sortrows(allperms);

for i=1:size(allperms,1)
    vowel1 = vowels{allperms(i,1)};
    vowel2 = vowels{allperms(i,2)};
    ehtoi = sprintf('%s2%s', vowel1, vowel2);
    shifts.(ehtoi) = FAll.(vowel2) - FAll.(vowel1);
      
%    Plot the shift from vowel1 to vowel2
    plot([FAll.(vowel1)(1) FAll.(vowel1)(1)+shifts.(ehtoi)(1)], ...
        [FAll.(vowel1)(2) FAll.(vowel1)(2)+shifts.(ehtoi)(2)],'--','Color',colors{allperms(i,1)})
    
end

reply = input('looks good? [y]/n: ','s');
if ~isempty(reply) && ~strcmp(reply,'y')
    error('Bad vowel formants');
end

savefile = fullfile(outputdir, expt.snum, 'vowelshift_params.mat');
save(savefile,'shifts');    