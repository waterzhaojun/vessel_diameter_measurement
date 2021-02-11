function df = extractRunningData(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal' );
addRequired(parser, 'date');
addRequired(parser, 'run');
addOptional(parser, 'preBoutSec', 3);
addOptional(parser, 'postBoutSec', 10);
addParameter(parser, 'excludeField', {});
parse(parser,animal, date, run, varargin{:});

preBoutSec = parser.Results.preBoutSec;
postBoutSec = parser.Results.postBoutSec;

exp = sbxDir(animal, date, run);
res = load(exp.runs{1}.running.resultpath);
res = res.result;
scanrate = res.scanrate;
% organize bout df
for i = 1:length(res.bout)
    tmp = res.bout{i};
    tmp.scanrate = res.scanrate;
    if tmp.startidx-ceil(preBoutSec*scanrate) < 1
        continue
    else
        tmp.baselineIdx = [tmp.startidx-ceil(preBoutSec*scanrate), tmp.startidx - 1];
    end
    
    if tmp.startidx+ceil(postBoutSec*scanrate)-1 > length(res.array)
        continue
    else
        tmp.responseIdx = [tmp.startidx, tmp.startidx+ceil(postBoutSec*scanrate)-1];
    end
    
    tmp.corArray = res.array_treated(tmp.baselineIdx(1) : tmp.responseIdx(2));
    tmp.boutID = [animal, '_', date, '_', num2str(run), '_', num2str(i)];
    for k = 1:length(parser.Results.excludeField)
        if isfield(tmp, parser.Results.excludeField{k})
            tmp = rmfield(tmp, parser.Results.excludeField{k});
        end
    end
    
    if i == 1
        df = [tmp];
    else
        df = [df;tmp];
    end
end

end