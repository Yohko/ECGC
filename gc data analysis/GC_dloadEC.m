%Licence: GNU General Public License version 2 (GPLv2)
%load multiple EC-Lab ASCII files
function [spectraEC, area] = GC_dloadEC()
    [FileNamecell,PathName,Fileindex] = uigetfile({'*.mpt;*.MPT', 'EC-Lab ASCII'},'Select EC-Lab txt files','MultiSelect', 'on');
    FileName = char(FileNamecell); % convert from cell to string list
    spectraEC = struct([]);
    area = 0;
    areaunit = 'cm²';
    if(Fileindex == 0)
        return;
    end
    for i=1:size(FileName,1)
        [~,name,~] = fileparts(FileName(i,:));
        fid=fopen(stripstrfirstlastspaces(sprintf('%s%s',PathName,FileName(i,:))),'r');
        data = GC_EClabASCIIload(fid);
        fclose(fid);
        if(isempty(data{2})==0)
            area = data(4);
            areaunit = data(5);
%            areaunit = char(areaunit);
%            switch areaunit % convert to cm^2
%                case 'cm²'
%                    area = area * 1;
%                case 'mm²'
%                    area = area * 0.01;
%                case 'm²'
%                    area = area * 10000;
%                case 'dm²'
%                    area = area * 100;
%                case 'nm²'
%                    area = area * 1e-14;
%                case 'µm²'
%                    area = area * 1e-8;
%            end
            if i > 1
                spectraEC = [spectraEC, struct('name',name,'header',data(1),'spectrum',data(2),'timecode',data(3))];
            else
                spectraEC = struct('name',name,'header',data(1),'spectrum',data(2),'timecode',data(3));
            end
        end
    end    

end
