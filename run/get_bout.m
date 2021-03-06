function [bout, secarray_treat, array_treat, restbout, restidx] = get_bout(array, scanrate, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumeric ); % This array must be deshaked.
addRequired(parser, 'scanrate', @(x) isnumeric(x) && (x>0));
% addParameter(parser, 'gap', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds of gap to be considered as the end of the bout.
% addParameter(parser, 'duration', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds at least to be considered as a bout.
% addParameter(parser, 'threshold', 1, @(x) isnumeric(x) && isscalar(x) && (x>0)); % The threshold of blocks ran in one sec to be considered as running.

parse(parser,array, scanrate, varargin{:});

config = run_config();
array_treat = gaussfilt(1:length(array), abs(array), config.gaussfilt_std);
%array_treat1 = abs(lowpass(array, 1, scanrate)); % To make it more smooth, change 1 to 0.5. Lowpass suppose the signal has negative. better abs afterwards.
% 
% hold on
% %plot(abs(array))
% plot(array_treat)
% %plot(array_treat1)
% plot(abs(array))
% hold off

secarray_treat = bint1D(array_treat, floor(scanrate));
array_treat_binary = heaviside(array_treat - config.speed_threshold);

array_treat_binary = positiveConcentrationFilter1D(array_treat_binary, floor(scanrate), config.positiveConcentrationThreshold);
rest_binary = logical(1-array_treat_binary);
bout = findPosPiece(logical(array_treat_binary));
restbout = findPosPiece(rest_binary);

%==================================================================
% add some filter for bout ========================================
%==================================================================
lastidx = 1;
wantedIdx = [];
for i = 1:length(bout)
    if bout{i}.startidx - lastidx > config.bout_gap_duration_threshold*scanrate &&...
            ((bout{i}.endidx - bout{i}.startidx) >= config.bout_duration_threshold*scanrate)
        wantedIdx = [wantedIdx, i];
        lastidx = bout{i}.endidx; % This line avoid some fake bout effect the rest period gap length.
    end
end
bout = bout(wantedIdx);
        
for i = 1:length(bout)
    bout{i}.array = array(bout{i}.startidx : bout{i}.endidx);
    bout{i}.array_treat = array_treat(bout{i}.startidx : bout{i}.endidx);
    
    % startsec and endsec can't be used as idx for bv idx as even bv is 15
    % layers, its scanrate is 1.03, not 1. So startsec, endsec,
    % secarray_treat is just for view, can't for analysis.
    bout{i}.startsec = translateIdx(bout{i}.startidx, scanrate, scanrate/floor(scanrate)); 
    bout{i}.endsec = translateIdx(bout{i}.endidx, scanrate, scanrate/floor(scanrate));
    bout{i}.secarray_treat = secarray_treat(bout{i}.startsec : bout{i}.endsec);
    
    bout{i}.duration = (bout{i}.endidx - bout{i}.startidx + 1) * scanrate;
    bout{i}.speed = mean(bout{i}.array_treat);
    bout{i}.distance = bout{i}.duration * bout{i}.speed;
    [bout{i}.maxspeed, tmp] = max(bout{i}.array_treat);
    bout{i}.maxspeed_delay = tmp/scanrate;
    bout{i}.acceleration = bout{i}.maxspeed / bout{i}.maxspeed_delay;
end
%==================================================================
% add some filter for rest bout ===================================
%==================================================================

wantedIdx = [];
restidx = [];
for i = 1:length(restbout)
    if restbout{i}.endidx - restbout{i}.startidx >= config.rest_period_length_threshold*scanrate
        wantedIdx = [wantedIdx, i];
        restbout{i}.startidx = restbout{i}.startidx + config.rest_period_ending_kickout(1) * floor(scanrate);
        restbout{i}.endidx = restbout{i}.endidx - config.rest_period_ending_kickout(2) * floor(scanrate);
        restidx = [restidx, restbout{i}.startidx : restbout{i}.endidx];
    end
end
restbout = restbout(wantedIdx);
% Same as bout, startsec and endsec is just for plot view, can't used for
% analysis
for i = 1:length(restbout)
    restbout{i}.startsec = translateIdx(restbout{i}.startidx, scanrate, scanrate/floor(scanrate));
    restbout{i}.endsec = translateIdx(restbout{i}.endidx, scanrate, scanrate/floor(scanrate));
end

end