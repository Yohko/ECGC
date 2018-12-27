%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_new(expname)
    disp('Loading new data!');
    GCandEC = 1;
    if nargin == 0
    	expname = '';
    end
	data = '';
    s_id = '';
    s_date = 0;
    if(isempty(expname))
        prompt = {'Sample ID','Date'};
        title = 'Name for Data';
        dims = [1 35];
        definput = {'C',datestr(now(),'yyyymmdd')};
        answer = inputdlg(prompt,title,dims,definput);
        if(isempty(answer))
            return
        end
        s_id = answer{1};
        s_date = str2double(answer{2});
        expname=sprintf('%s_%s',answer{2},answer{1});    
    end
    
    disp('Step (1/3): Loading EC data.');
    [datatmp, area] = GC_dloadEC();
    if(isempty(datatmp))
        data = '';
        GCandEC = 0;
        Rcmp = 0;
        area = 1;
    else
        eval(sprintf('CA_%s = datatmp;',expname));
        save(sprintf('CA_%s.mat',expname),sprintf('CA_%s',expname));
        Rcmpcol = strmatch('Rcmp/Ohm', datatmp(1).header,'exact');% potential col 17 in Coulomb,
        if(isempty(Rcmpcol))
            Rcmpcol = -1;
            Rcmp = 0;
        else
            Rcmp = datatmp(1).spectrum(1,Rcmpcol);
            Rcmp = Rcmp/0.85;
        end
        area = cell2mat(area);
    end    
    clear('datatmp');

    disp('Step (2/3): Loading GC data.');
    datatmp = GC_dloadgc();
    if(isempty(datatmp))
        data = '';
        return;
    else
        % checking for TCD and FID ...
        TCDi = 1;
        FIDi = 1;
        TCDnums = [];
        FIDnums = [];        
        for i = 1:size(datatmp,2)
            index = strfind(datatmp(i).name,'_');
            strtmp = datatmp(i).name(index(end)+1:end);
            type = strtmp(1:3);
            num = strtmp(4:end);
            if(strcmpi(type,'TCD') == 1)
                TCDnums(TCDi) = str2double(num);
                TCDi = TCDi+1;
            elseif(strcmpi(type,'FID') == 1)
                FIDnums(FIDi) = str2double(num);
                FIDi = FIDi+1;
            end
        end
        if(TCDi ~= FIDi)
            disp('#FID != #TCD');
            data = '';
            return;
        else
            % check if spectra numbers are correct 
            % (each TCD file should have a corresponding FID file)
            for i=1:TCDi-1
                if(find(TCDnums(i) == FIDnums))
                else
                    TCDnums(i)
                    disp('FID# != TCD#');
                    data = '';
                    return;
                end
            end
        end
        eval(sprintf('GC_%s = datatmp;',expname));
        save(sprintf('GC_%s.mat',expname),sprintf('GC_%s',expname));
    end
    clear('datatmp');
    
    disp('Step (3/3): Getting additional parameters.');
    prompt = {'Area [cm2]','UtoRHE [V]','Ru [ohm]','Comp. [-]',...
        'Offset time [min]','Int time [min]','Continous Flow (1, 0)'};
    title = 'Parameters for Data';
    dims = [1 35];
    definput = {num2str(area),'0.5978',num2str(Rcmp),'0.85','2','2','1'};    
    answer = inputdlg(prompt,title,dims,definput);
    if(isempty(answer))
        data = '';
    else
        data = {s_id,s_date,str2double(answer(1)),'-',str2double(answer(2)), ...
            str2double(answer(5)),str2double(answer(6)),str2double(answer(7)),...
            str2double(answer(3)),str2double(answer(4)),GCandEC};
    end
end
