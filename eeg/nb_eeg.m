cedpath = 'C:\CEDMATLAB\CEDS64ML'; % if no environment variable (NOT recommended) 
cedpath = getenv('CEDS64ML');         % if you have set this up (this is the recommende 
addpath( cedpath );                   % so CEDS64LoadLib.m is found 
CEDS64LoadLib( cedpath );             % load ceds64int.dll 

fhand1 = CEDS64Open( 'E:\jzhao electrophysiology\151020 CSD FLCT topic\mech-Oct-20-15-14-36-1058.smr' ); 
if (fhand1 <= 0); unloadlibrary ceds64int; return; end


maxTimeTicks = CEDS64ChanMaxTime( fhand1, 1 )+1; % +1 so the read gets the last point 
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 1000000, 0, maxTimeTicks );


rootpath = 'C:\Users\Levylab\jun\';
gap = 100 *60 * 1; % I stop use it

% set load data parameter.
p = struct();
p.length = 1000 * 60 * 30;
p.piece_length = 1000 * 60 * 30;
p.scanrate = 1000;

test = {[rootpath,'aaaaa.csv'],1};
testmx = load_data(test,p);
test1 = downsample(testmx(1:900000,1), 10);
params = struct();
params.tapers = [0.5,10,9];%unit is s and hz for two paras, the third para is 2TW-1
params.Fs = 100;
params.fpass = [0,50];
params.err = [1, 0.05];
movingwin=[1,1];
[S,t,f,Serr] = mtspecgramc( 1000*test1, movingwin, params );
S = flip(S',1);
heatmap(log(S),'GridVisible','off','Colormap', jet);

params = struct();
params.tapers = [0.5,10,9];%unit is s and hz for two paras, the third para is 2TW-1
params.Fs = 1000;
params.fpass = [0,100];
params.err = [1, 0.05];
movingwin=[1,1];
a = V201216_afterCSD_Ch4.values;
aa = downsample(a, 10);
[S,t,f,Serr] = mtspecgramc( aa, movingwin, params );
S = flip(S',1);
h = heatmap(log(S),'GridVisible','off','Colormap', jet);
xticks = repmat(true, 1, size(S,2));
h.XDisplayLabels(xticks) = {''};
label = [5,10,15,20,25];
xticks = repmat(false, 1, size(S,2));
xticks([1,label * 60]) = true;
h.XDisplayLabels(xticks) = {-5, 0, 5,10,15,20};
h.YDisplayLabels(repmat(true, 1, size(S,1))) = {''};


mx = [1,2,3,4;4,5,6,7;1,2,3,4;4,5,6,7;];
h = heatmap(mx);
h.XDisplayLabels([true, false, true, false]) = {5,3};
h.XDisplayLabels([false, true, false, true]) = {''};

control = {[rootpath,'lfp2018040401.csv'], 180300; [rootpath,'lfp2018042701.csv'], 569693;};
flct = {[rootpath,'lfp2018041001.csv'], 364690; [rootpath,'lfp2018042401.csv'], 390036; [rootpath,'lfp2018061301.csv'], 636192; [rootpath,'lfp2018042501.csv'], 749580;};

controlmx = load_data(control, p);
flctmx = load_data(flct, p);
    

% set analysis parameters.
params = struct();
params.tapers = [3,5];
params.Fs = 100;
params.fpass = [0,50];
params.pad = 0; % Increase this will make f more precisely seperated. But it won't change the distribution. For now I think default 0 
result = eeg_analysis(flctmx, params);


[sflct,f,err] = mtspectrumc( flctmx, params );
[scontrol,f,err] = mtspectrumc( controlmx, params );

mx = cat(2,scontrol, sflct);

plotp = struct();
plotp.freq_range = [0,30];
plotp.exclude_beginning_points = 5;
plot_psd(mx, f, [], plotp);


params = struct();
params.tapers = [1000,5,1];
params.Fs = 100;
params.fpass = [0,50];
params.err = [1, 0.05];
movingwin=[1000,10];

[S,t,f,Serr] = mtspecgramc( fVals, movingwin, params );


sigma = 5;
y = normrnd(0,sigma,100,1);
m = jackknife(@var,y,1);