%Licence: GNU General Public License version 2 (GPLv2)
%load multiple EC-Lab ASCII files
function [spectraEC, area] = GC_dloadEC()
    [FileNamecell,PathName,Fileindex] = uigetfile({'*.mpt;*.MPT', 'EC-Lab ASCII'},'Select EC-Lab txt files','MultiSelect', 'on');
    spectraEC = [];
    area = 0;
    if(Fileindex == 0)
        return;
    end
    if ~iscell(FileNamecell)
        FileNamecell = {FileNamecell};
    end
    for i=1:length(FileNamecell)
        [~,name,~] = fileparts(FileNamecell{i});
        fid=fopen(sprintf('%s%s',PathName,FileNamecell{i}),'r');
        data = GC_EClabASCIIload(fid);
        fclose(fid);
        if(isempty(data{2})==0)
            area = cell2mat(data(4));
            areaunit = data(5);
            try
                areaunit = char(areaunit{1});
            catch
                areaunit = 'cm�';
            end
            
            switch areaunit % convert to cm^2
                case 'cm�'
                    area = area * 1;
                case 'mm�'
                    area = area * 0.01;
                case 'm�'
                    area = area * 10000;
                case 'dm�'
                    area = area * 100;
                case 'nm�'
                    area = area * 1e-14;
                case '�m�'
                    area = area * 1e-8;
            end
            spectraEC = [spectraEC, struct('name',name,'header',data(1),'spectrum',data(2),'timecode',data(3))];
        end
    end
end
