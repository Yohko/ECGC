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
            hfigure.input.CH(1).spectra(row).timecode+hfigure.input.GC_timezonecorr); % timezone correction
        
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                fprintf(fileID,',%f',hfigure.result.CH(jj).peak(ii).area(row));
            end
        end
        if(hfigure.input.GCandEC == 1) % GC and EC data present
            tmp = hfigure.result.GC_data.potential(row)+hfigure.input.UtoRHE+...
                (hfigure.result.GC_data.current(row)*1E-3)*hfigure.result.GC_data.Ru(row)*(1-hfigure.input.compensation);
            fprintf(fileID,',%s,%s,%s,%s,%s',...
                num2str(tmp),... % U_vs_RHE
                num2str(hfigure.result.GC_data.current(row)),... %current
                num2str(hfigure.result.GC_data.time(row)),... % time
                num2str(hfigure.result.GC_data.charge(row)),... % charge
                num2str(hfigure.result.GC_data.flowrate(row))); % flowrate
            fprintf(fileID,'\n');
        else % non flow experiment
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
