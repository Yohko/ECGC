%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportCSV(hfigure)
    filename = sprintf('%s.csv',hfigure.input.resultname);
    fileID = fopen(filename,'w');
    % print header
    fprintf(fileID,'%s,%s,%s','Name','Number','timecode');
    for ii = 1:length(hfigure.result.peakCH1)
        fprintf(fileID,',%s',hfigure.result.peakCH1(ii).name);
    end    
	for ii = 1:length(hfigure.result.peakCH2)
        fprintf(fileID,',%s',hfigure.result.peakCH2(ii).name);
	end
    fprintf(fileID,'%s,%s,%s,%s,%','U_vs_RHE','current','time','charge','flowrate');
	fprintf(fileID,'\n');
    % print data
    for row = 1:size(hfigure.input.runname,1)
        fprintf(fileID,'%s,%s,%s',...
            hfigure.input.runname(row),...
            num2str(hfigure.input.runnum(row)),...
            hfigure.result.GCtimes(row));
        for ii = 1:length(hfigure.result.peakCH1)
            fprintf(fileID,',%s',hfigure.result.peakCH1(ii).area(row));
        end    
        for ii = 1:length(hfigure.result.peakCH2)
            fprintf(fileID,',%s',hfigure.result.peakCH2(ii).area(row));
        end
        tmp = hfigure.result.GCpotential(row)+hfigure.input.UtoRHE+...
            (hfigure.result.GCcurrent(row)*1E-3)*hfigure.result.GCRu(row)*(1-hfigure.input.compensation);
        fprintf(fileID,'%s,%s,%s,%s,%',...
            tmp,...            
            hfigure.result.GCcurrent(row),...
            hfigure.result.GCtime(row),...
            hfigure.result.GCcharge(row),...
            hfigure.result.GCflowrate(row));
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end
