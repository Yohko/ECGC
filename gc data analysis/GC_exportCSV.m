%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportCSV()
    global input result
    
    filename = sprintf('%s.csv',input.resultname);
    fileID = fopen(filename,'w');
    fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','Name','Number','CO','CH4','CO 2nd','CH4 2nd','C2H4','C2H6','O2','H2', 'H2O2', 'PG');
    for row = 1:size(input.runname,1)
        fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',input.runname(row),num2str(input.runnum(row)), ...
        num2str(result.FID_CO(row)),num2str(result.FID_CH4(row)),...
        num2str(result.FID_CO_2nd(row)),num2str(result.FID_CH4_2nd(row)), ...
        num2str(result.FID_C2H4(row)),num2str(result.FID_C2H6(row)), ...
        num2str(result.TCD_O2(row)),num2str(result.TCD_H2(row)), ...
        num2str(result.TCD_H2O2(row)),num2str(result.TCD_PG(row)));
    end
    fclose(fileID);
end
