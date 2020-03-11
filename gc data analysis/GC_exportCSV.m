%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportCSV()
    global input result
    
    filename = sprintf('%s.csv',input.resultname);
    fileID = fopen(filename,'w');
    % print header
    fprintf(fileID,'%s,%s','Name','Number');
    for ii = 1:length(result.peakFID)
        fprintf(fileID,',%s',result.peakFID(ii).name);
    end    
	for ii = 1:length(result.peakTCD)
        fprintf(fileID,',%s',result.peakTCD(ii).name);
	end
	fprintf(fileID,'\n');
    % print data
    for row = 1:size(input.runname,1)
        fprintf(fileID,'%s,%s',input.runname(row),num2str(input.runnum(row)));
        for ii = 1:length(result.peakFID)
            fprintf(fileID,',%s',result.peakFID(ii).area(row));
        end    
        for ii = 1:length(result.peakTCD)
            fprintf(fileID,',%s',result.peakTCD(ii).area(row));
        end
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end
