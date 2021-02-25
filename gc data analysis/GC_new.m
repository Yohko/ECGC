%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_new(hfigure, expname)
	eval(hfigure.GC_usersetting); % load settings
    disp('Loading new data!');
    GCandEC = 1;
    if nargin == 1
    	expname = '';
    end
	data = '';
    s_id = '';
    s_date = 0;
    UIprog = uiprogressdlg(hfigure.figure,'Title','Please Wait');
    UIprog.Value = 0.0; 
    if(isempty(expname))
        UIprog.Value = 0.0; 
        UIprog.Message = 'Getting Name for Entry.';
        prompt = {'Sample ID','Date'};
        title = 'Name for Data';
        dims = [1 35];
        definput = {'C',datestr(now(),'yyyymmdd')};
        answer = inputdlg(prompt,title,dims,definput);
        if(isempty(answer))
            figure(hfigure.figure);
            UIprog.Value = 1;
            close(UIprog);
            return;
        end
        s_id = answer{1};
        s_id = strrep(s_id, '/', '');
        s_id = strrep(s_id, '\', '');        
        s_date = str2double(answer{2});
        expname=sprintf('%s_%s',answer{2},answer{1});    
    end
    
    disp('Step (1/3): Loading EC data.');
    figure(hfigure.figure);
    UIprog.Value = 0.1; 
    UIprog.Message = 'Loading EC data.';
    [datatmp, area] = GC_dloadEC();
    if(isempty(datatmp))
        data = '';
        GCandEC = 0;
        Rcmp = 0;
        area = 1;
    else
        eval(sprintf('CA_%s = datatmp;',expname));
        save(sprintf('CA_%s.mat',expname),sprintf('CA_%s',expname),'-v7.3');
        Rcmpcol = strmatch('Rcmp/Ohm', datatmp(1).header,'exact');% potential col 17 in Coulomb,
        if(isempty(Rcmpcol))
            Rcmp = 0;
        else
            Rcmp = datatmp(1).spectrum(1,Rcmpcol);
            Rcmp = Rcmp/0.85;
        end
    end
    clear('datatmp');

    disp('Step (2/3): Loading GC data.');
    figure(hfigure.figure);
    UIprog.Value = 0.5;
    
	tmpstr = {};
    for ii = 1:length(GCset)
        tmpstr(ii) = {GCset(ii).name};
    end
    
    typeID = listdlg('ListString', ...
            tmpstr,'SelectionMode','single');
    if isempty(typeID)
        figure(hfigure.figure);
        UIprog.Value = 1;
        close(UIprog);
        return;
    end
    
    UIprog.Message = 'Loading GC data.';
    switch GCset(typeID).type
        case 'Agilent'
            datatmp = GC_dloadAgilent;
        case 'SRI'
            datatmp = GC_dloadgc();  
        otherwise
            datatmp = GC_dloadgc();
    end
    
    if(isempty(datatmp))
        data = '';
        figure(hfigure.figure);
        UIprog.Value = 1;
        close(UIprog);
        return;
    else
        % checking for CH2 and CH1 ...
        CH2i = 1;
        CH1i = 1;
        CH2nums = [];
        CH1nums = [];        
        for i = 1:size(datatmp,2)
            index = strfind(datatmp(i).name,'_');
            strtmp = datatmp(i).name(index(end)+1:end);            
            idxnum = find(~isletter(strtmp));
            idxtype = find(isletter(strtmp));
            type = strtmp(idxtype);
            num = strtmp(idxnum);
            if(strcmpi(type,GCset(typeID).CH(2).name) == 1)
                CH2nums(CH2i) = str2double(num);
                CH2i = CH2i+1;
            elseif(strcmpi(type,GCset(typeID).CH(1).name) == 1)
                CH1nums(CH1i) = str2double(num);
                CH1i = CH1i+1;
            end
        end
        if(CH2i ~= CH1i)
            disp('#CH1 != #CH2');
            data = '';
            figure(hfigure.figure);
            UIprog.Value = 1;
            close(UIprog);
            return;
        else
            % check if spectra numbers are correct 
            % (each CH2 file should have a corresponding CH1 file)
            for i=1:CH2i-1
                if(find(CH2nums(i) == CH1nums))
                else
                    disp('CH1# != CH2#');
                    data = '';
                    figure(hfigure.figure);
                    UIprog.Value = 1;
                    close(UIprog);
                    return;
                end
            end
        end
        eval(sprintf('GC_%s = datatmp;',expname));
        save(sprintf('GC_%s.mat',expname),sprintf('GC_%s',expname),'-v7.3');
    end
    clear('datatmp');
    
    disp('Step (3/3): Getting additional parameters.');
    figure(hfigure.figure);
    UIprog.Value = 0.9; 
    UIprog.Message = 'Getting additional parameters.';
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
            str2double(answer(3)),str2double(answer(4)),GCandEC,GCset(typeID).type,typeID};
    end
    figure(hfigure.figure);
    UIprog.Value = 1;
    close(UIprog);
end
