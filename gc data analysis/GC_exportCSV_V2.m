%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportCSV_V2(hfigure)
    filename = sprintf('%s.csv',hfigure.input.resultname);
    fileID = fopen(filename,'w');

    % print header
    fprintf(fileID,'%s,%s,%s','Name','Number','epoch[sec]');
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            fprintf(fileID,',%s_%s[raw]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name);
            fprintf(fileID,',%s_%s_err[raw]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name);
        end
	end
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            fprintf(fileID,',%s_%s[ppm]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name);
            fprintf(fileID,',%s_%s_err[ppm]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name);
        end
	end
    if(hfigure.input.GCandEC == 1) % GC and EC data present
        fprintf(fileID,',%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s',...
            'U[V]','Uerr[V]','U2RHE[V]','Ru[ohm]','comp','j[mA]','j_err[mA]','time[min]','charge[C]','flowrate[sccm]','flowrate_err[sccm]');
    end
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
                fprintf(fileID,',%f',hfigure.result.CH(jj).peak(ii).err(row));
            end
        end
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                fprintf(fileID,',%f',hfigure.result.CH(jj).peak(ii).ppm(row));
                fprintf(fileID,',%f',hfigure.result.CH(jj).peak(ii).ppm(row)*...
                    hfigure.result.CH(jj).peak(ii).err(row)/...
                    hfigure.result.CH(jj).peak(ii).area(row));
            end
        end
        if(hfigure.input.GCandEC == 1) % GC and EC data present
            fprintf(fileID,',%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s',...
                num2str(hfigure.result.GC_data.potential(row)),... % U
                num2str(hfigure.result.GC_data.potentialerr(row)),...
                num2str(hfigure.input.UtoRHE),...
                num2str(hfigure.result.GC_data.Ru(row)),...
                num2str(hfigure.input.compensation),...
                num2str(hfigure.result.GC_data.current(row)),... %current
                num2str(hfigure.result.GC_data.currenterr(row)),... %currenterr
                num2str(hfigure.result.GC_data.time(row)),... % time
                num2str(hfigure.result.GC_data.charge(row)),... % charge
                num2str(hfigure.result.GC_data.flowrate(row)),... % flowrateerr
                num2str(hfigure.result.GC_data.flowrateerr(row))); % flowrate
            fprintf(fileID,'\n');
        end
    end
    fclose(fileID);
end

