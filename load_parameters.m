function p = load_parameters(animalid, date, run, pmt)
    
    
    p = {};
    p.animal = animalid;
    p.date = date;
    p.run = run;
    
    if nargin<4, pmt = 0; end
    
    p.pmt = pmt;
    path = sbxPath(animalid, date, run, 'sbx'); 
    inf = sbxInfo(path, true);
    tmp = sbxDir(animalid, date, run);
    p.dirname = tmp.runs{1}.path;
    p.basicname = strtok(path, '.');
    
    p.config_path = tmp.runs{1}.config;
    p.config = ReadYaml(p.config_path);

    % the following part need to define based on each person's code.
    
    p.refname = [p.basicname, p.config.registration_ref_ext, '.tif'];
    p.pretreated_mov = [p.basicname, '_pretreated.tif'];
    p.scanrate = 15;
    p.keep_frames = floor((inf.max_idx+1)/(inf.scanmode*15.5)/60)*60*floor(inf.scanmode*15.5);
    p.keep_frames_start = floor((inf.max_idx+1-p.keep_frames)/2/(inf.volscan+1))*(inf.volscan+1)+1;
    
    p.downsample_t = floor(inf.scanmode * 15.5  / p.config.output_fq);

end