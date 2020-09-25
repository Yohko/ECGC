%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportCSV(hfigure)
    filename = sprintf('%s.csv',hfigure.input.resultname);
    fileID = fopen(filename,'w');

    % print header
    fprintf(fileID,'%s,%s,%s','Name','Number','timecode');
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            fprintf(fileID,',%s_%s',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name);
        end
	end
    fprintf(fileID,',%s,%s,%s,%s,%s','U_vs_RHE','current','time','charge','flowrate');
	fprintf(fileID,'\n');

    % print data
    for row = 1:length(hfigure.input.CH(1).spectra)
        fprintf(fileID,'%s,%s,%s',...
            hfigure.input.CH(1).spectra(row).runname,...
            num2str(hfigure.input.CH(1).spectra(row).runnum),...
            hfigure.input.CH(1).spectra(row).timecode+8*60*60); % timezone correction
        
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                fprintf(fileID,',%s',hfigure.result.CH(jj).peak(ii).area(row));
            end
        end
        if(hfigure.input.GCandEC == 1)
            tmp = hfigure.result.GCpotential(row)+hfigure.input.UtoRHE+...
                (hfigure.result.GCcurrent(row)*1E-3)*hfigure.result.GCRu(row)*(1-hfigure.input.compensation);
            fprintf(fileID,',%s,%s,%s,%s,%s',...
                num2str(tmp),...
                num2str(hfigure.result.GCcurrent(row)),...
                num2str(hfigure.result.GCtime(row)),...
                num2str(hfigure.result.GCcharge(row)),...
                num2str(hfigure.result.GCflowrate(row)));
            fprintf(fileID,'\n');
        else
            fprintf(fileID,',%s,%s,%s,%s,%s',...
                '',...            
                '',...
                '',...
                '',...
                '');
            fprintf(fileID,'\n');
        end
    end
    fclose(fileID);
end
