%% Single trial bv analysis
animal = 'WT0120';   % <====================== File your exp info
date = '201209';     % <====================== File your exp info
run = 6;             % <====================== File your exp info
pmt = 0;             % <====================== File your exp info
layers = 'all';      % <====================== File your exp info [11]
%smooth = 0;

% don't change code below ==========================================
bvfilesys = bv_file_system();
[mx,folder] = diameter_prepare_mx(animal, date, run, pmt, 'layer',layers, 'smooth', 0, 'output_mov',false);
diameter_build_refmask(folder, mx, 'rebuildRef', false, 'rebuildRoi', true);
set_scanrate(animal, date, run, 'bv');
diameter_analysis(folder, mx);
set_vessel_type(folder);
input_vessel_id(folder);

%% If you want to edit some roi, run code here ======================
roiid = '5.0'  % <======== Need to set a roi id.
editRoi(folder, mx, roiid);
diameter_analysis(folder, mx); % <======When editted all rois, run this function again to update the pdf.

%% If the output response file is pdf, use this function to change it to jpg and run diameter_analysis again
change_pdf_2_jpg(folder)
diameter_analysis(folder, mx);

%% correlation with running.
running_analysis(animal, date, run); % If you didn't do running analysis, do it here!!!
%diameter_calculate_baseline(folder);
%layername = [num2str(layers(1)), 'to', num2str(layers(end))];
%diameter_running_corAnalysis(animal, date, run, 'bvfolder', '6to7');
%result2csv([folder, '\',bvfilesys.bv_running_correlation_resultpath], {'bvarray'});














%% Old steps. Ignore it.
list = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP02','201117',1;'CGRP02','201117',2;'CGRP02','201117',3;'CGRP02','201117',4;...
    'CGRP02','201119',1;'CGRP02','201119',2;'CGRP02','201119',3;...
    
    'CGRP03','201109',1;'CGRP03','201109',2;...
    'CGRP03','201116',1;'CGRP03','201116',2;'CGRP03','201116',3;'CGRP03','201116',4;'CGRP03','201116',5;'CGRP03','201116',6;...
    'CGRP03','201118',1;'CGRP03','201118',2;'CGRP03','201118',3;'CGRP03','201118',4;'CGRP03','201118',5;'CGRP03','201118',6;'CGRP03','201118',7;...
    'CGRP03','201120',1;...
    
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    %'WT01','201117',1;...
    'WT01','201117',2;'WT01','201117',3;'WT01','201117',4;'WT01','201117',5;'WT01','201117',6;...
    'WT01','201119',1;'WT01','201119',2;'WT01','201119',3;'WT01','201119',4;'WT01','201119',5;...
    %'WT01','201124',1;'WT01','201124',2;'WT01','201124',3;'WT01','201124',4;...
    %'WT01','201125',1;'WT01','201125',2;...
    }

list = {
    'WT0118','201123',1;'WT0118','201123',2;'WT0118','201123',3;...
    'WT0118','201125',1;'WT0118','201125',2;'WT0118','201125',3;'WT0118','201125',4;'WT0118','201125',5;'WT0118','201125',6;...
    'WT0118','201201',1;'WT0118','201201',2;'WT0118','201201',3;'WT0118','201201',4;'WT0118','201201',5;'WT0118','201201',6;...
    'WT0118','201208',1;'WT0118','201208',2;'WT0118','201208',3;'WT0118','201208',4;'WT0118','201208',5;'WT0118','201208',6;'WT0118','201208',7;...
    }
    'WT0119','201123',1;'WT0119','201123',2;'WT0119','201123',3;'WT0119','201123',4;...
    'WT0119','201125',1;'WT0119','201125',2;'WT0119','201125',3;'WT0119','201125',4;'WT0119','201125',5;'WT0119','201125',6;...
    'WT0119','201201',1;'WT0119','201201',2;'WT0119','201201',3;'WT0119','201201',4;'WT0119','201201',5;...
    'WT0119','201208',1;'WT0119','201208',2;'WT0119','201208',3;'WT0119','201208',4;'WT0119','201208',5;'WT0119','201208',6;'WT0119','201208',7;'WT0119','201208',8;...
    
    'WT0120','201209',1;'WT0120','201209',2;'WT0120','201209',3;'WT0120','201209',4;'WT0120','201209',5;'WT0120','201209',6;'WT0120','201209',7;'WT0120','201209',8;'WT0120','201209',9;'WT0120','201209',10;...
}

list = {
    'CGRP03','201109',3;'CGRP03','201109',4;
}

for st = 1:size(list,1)
    root = sbxDir(list{st,1}, list{st,2},list{st,3});
    info = load([root.runs{1}.base, '.mat']);
    info = info.info;
    root = root.runs{1}.path;
    disp(list{st,1});
    disp(list{st,2});
    disp(list{st,3});
    if info.scanmode == 1
        tmpscanrate = 15;
    elseif info.scanmode == 2
        tmpscanrate = 31;
    end
    tmplayers = check_scan_layers(info);
    bvroot = [root, 'bv\'];
    bvsub = dir(bvroot);
    bvsub = bvsub(~ismember({bvsub.name},{'.','..'}));
    for i = 1:length(bvsub)
        result = load([bvsub(i).folder, '\',bvsub(i).name,'\result.mat']);
        result = result.result;
        result.scanrate = tmpscanrate / tmplayers;
        save([bvsub(i).folder, '\',bvsub(i).name,'\result.mat'], 'result');
        
    end
end
