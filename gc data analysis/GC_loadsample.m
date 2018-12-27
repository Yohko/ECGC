%Licence: GNU General Public License version 2 (GPLv2)
function retval = GC_loadsample(sample)
    global input
    retval = 1;
    sample_id = sample(10:end);
    sample_date = sample(1:8);
    ids = table2cell(input.samplelist(:,1));
    dates = cell2mat(table2cell(input.samplelist(:,2)));
	% first search for sample id
    idx_s = find(ismember(ids, sample_id));
    if(isempty(idx_s))
        disp('Sample ID not found.');
        retval = -1;
        return;
    end
    % now check for corresponding date
    idx_d = find(dates(idx_s) == str2num(sample_date));
    if(isempty(idx_d))
        disp('No matching sample date found.');
        retval = -1;
        return;
    end
    
    if(length(idx_d)>1)
        disp('Multiple entries found.');
        retval = -1;
        return;
    end
    
    id = idx_s(idx_d);
	input.resultname = sample;
    input.GCoffsettime = table2array(input.samplelist(id,6));
    input.GCinttime = table2array(input.samplelist(id,7));
    input.GC_binning = table2array(input.samplelist(id,8));
    input.area = table2array(input.samplelist(id,3));
    input.UtoRHE = table2array(input.samplelist(id,5));
    input.Ru = table2array(input.samplelist(id,9));
    input.compensation = table2array(input.samplelist(id,10));
    input.GCandEC = table2array(input.samplelist(id,11));
    
	try
        load(sprintf('CA_%s.mat',input.resultname));
	catch
        eval(sprintf('CA_%s = 0;',input.resultname));
        disp('Error loading EC data.');
        input.GCandEC = 0;
	end

    try
        load(sprintf('GC_%s.mat',input.resultname));
    catch
        eval(sprintf('GC_%s = 0;',input.resultname));
        disp('Error loading GC data.');
        retval = -1;
    end
    eval(sprintf('input.spectraEC = CA_%s;',input.resultname));
	eval(sprintf('input.spectra = GC_%s;',input.resultname));
end
