%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportXLS()
    global GC_usersetting
    eval(GC_usersetting); % load settings
    global input result cal
    warning('off','MATLAB:xlswrite:AddSheet');

    % Add Java POI Libs to matlab javapath
    path = mfilename('fullpath');
    path = path(1:end-length('GC_exportXLS'));
    tmp = strfind(javaclasspath(),'poi'); % check if already loaded
    if(isempty(tmp))
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-ooxml-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-ooxml-schemas-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/xmlbeans-2.3.0.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/dom4j-1.6.1.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/stax-api-1.0.1.jar'));   
    elseif(isempty(tmp{1}))
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-ooxml-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/poi-ooxml-schemas-3.8-20120326.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/xmlbeans-2.3.0.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/dom4j-1.6.1.jar'));
        javaaddpath(sprintf('%s%s',path,'poi_library/stax-api-1.0.1.jar'));   
    end
    

    fileName = sprintf('%s.xlsx',input.resultname);
    sheetName = input.resultname;
    coloffset = 1;
    
    % somehow the new office does something to the files 
    % when they are edited so they cannot be edited by this program anymore
    % and need to be deleted
    if exist(fileName, 'file')==2
        delete(fileName);
    end
    
    
    % write the raw area data
    xlsData = {'Name' 'Number' 'CO [raw]' 'CH4 [raw]' 'CO 2nd [raw]' 'CH4 2nd [raw]' 'C2H4 [raw]' 'C2H6 [raw]' 'O2 [raw]' 'H2 [raw]'};
    rawoffset = 3;
    xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
    xlwrite(fileName, cellstr(input.runname), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset)));
    xlwrite(fileName, num2cell(input.runnum), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+1)));
    xlwrite(fileName, num2cell(result.FID_CO), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+2)));
    xlwrite(fileName, num2cell(result.FID_CH4), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+3)));
    xlwrite(fileName, num2cell(result.FID_CO_2nd), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+4)));
    xlwrite(fileName, num2cell(result.FID_CH4_2nd), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+5)));
    xlwrite(fileName, num2cell(result.FID_C2H4), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+6)));
    xlwrite(fileName, num2cell(result.FID_C2H6), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+7)));
    xlwrite(fileName, num2cell(result.TCD_O2), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+8)));
    xlwrite(fileName, num2cell(result.TCD_H2), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+9)));
    coloffset = coloffset+11;
    
    % area converted to ppm
    ppmoffset = coloffset;
    xlsData = {'CO [ppm]' 'CH4 [ppm]' 'CO_M [ppm]' 'CH4_M [ppm]' 'C2H4 [ppm]' 'C2H6 [ppm]' 'O2 [ppm]' 'H2 [ppm]'};
    xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
    for i=2:length(input.runnum)+1
        xlsData = {
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset),i,cal.CO_offset,GC_getXLScolumn(rawoffset),i,cal.CO_offset,cal.CO_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+1),i,cal.CH4_offset,GC_getXLScolumn(rawoffset+1),i,cal.CH4_offset,cal.CH4_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+2),i,cal.CO_M_offset,GC_getXLScolumn(rawoffset+2),i,cal.CO_M_offset,cal.CO_M_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+3),i,cal.CH4_M_offset,GC_getXLScolumn(rawoffset+3),i,cal.CH4_M_offset,cal.CH4_M_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+4),i,cal.C2H4_offset,GC_getXLScolumn(rawoffset+4),i,cal.C2H4_offset,cal.C2H4_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+5),i,cal.C2H6_offset,GC_getXLScolumn(rawoffset+5),i,cal.C2H6_offset,cal.C2H6_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+6),i,cal.O2_offset,GC_getXLScolumn(rawoffset+6),i,cal.O2_offset,cal.O2_factor) ...
            sprintf('=IF(%s%d+%d<0,0,(%s%d+%d)/%d)',GC_getXLScolumn(rawoffset+7),i,cal.H2_offset,GC_getXLScolumn(rawoffset+7),i,cal.H2_offset,cal.H2_factor) ...
            };
        xlwrite(fileName, xlsData, sheetName, sprintf('%s%d',GC_getXLScolumn(coloffset),i));
    end
    coloffset = coloffset+9;
    

    % ppm converted to µM
    xlsData = {'CO [µM]' 'CH4 [µM]' 'C2H4 [µM]' 'C2H6 [µM]' 'O2 [µM]' 'H2 [µM]'};
    xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
    uMoffset = coloffset;
    for i=2:length(input.runnum)+1
        xlsData = { ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset),  i) ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset+1), i) ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset+4), i) ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset+5), i) ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset+6), i) ...
            sprintf('=%s%d/24.5', GC_getXLScolumn(ppmoffset+7), i) ...
            };
        xlwrite(fileName, xlsData, sheetName, sprintf('%s%d',GC_getXLScolumn(coloffset),i));
    end
    coloffset = coloffset+7;
    
    headspaceoffset = coloffset;
    xlwrite(fileName, {'headspace [L]'}, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
    for i=2:length(input.runnum)+1
        xlwrite(fileName, {input.headspacevol}, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
    end
    coloffset = coloffset+1;
    
    % µM converted zo µmol
    umoloffset = coloffset;
    xlsData = {'CO [µmol]' 'CH4 [µmol]' 'C2H4 [µmol]' 'C2H6 [µmol]' 'O2 [µmol]' 'H2 [µmol]'};
    xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
    for i=2:length(input.runnum)+1
        xlsData = {
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset), i, GC_getXLScolumn(headspaceoffset), i) ...
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset+1), i, GC_getXLScolumn(headspaceoffset), i) ...
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset+2), i, GC_getXLScolumn(headspaceoffset), i) ...
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset+3), i, GC_getXLScolumn(headspaceoffset), i) ...
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset+4), i, GC_getXLScolumn(headspaceoffset), i) ...
            sprintf('=%s%d*%s%d', GC_getXLScolumn(uMoffset+5), i, GC_getXLScolumn(headspaceoffset), i) ...
            };
        xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
    end
    coloffset = coloffset+7;

    if(input.GCandEC == 1)    
        flowrateoffset = coloffset;
        xlwrite(fileName, {'flowrate [sccm]'}, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlwrite(fileName, {result.GCflowrate(i-1)}, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        coloffset = coloffset+1;

        % µmol converted to µmol/hr
        umolhroffset = coloffset;
        xlsData = {'CO [µmol/hr]' 'CH4 [µmol/hr]' 'C2H4 [µmol/hr]' 'C2H6 [µmol/hr]' 'O2 [µmol/hr]' 'H2 [µmol/hr]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlsData = {
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset+1), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset+2), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset+3), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset+4), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                sprintf('=%s%d/(%s%d/%s%d/60*1000)', GC_getXLScolumn(umoloffset+5), i, GC_getXLScolumn(headspaceoffset), i, GC_getXLScolumn(flowrateoffset), i) ...
                };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        coloffset = coloffset+7;

        currentoffset = coloffset-1;
        potentialoffset = coloffset;
        chargeoffset = coloffset+1;
        timeoffset = coloffset+2;
        factoroffset = coloffset+3;
        xlsData = {'Current [mA/cm^2]' 'U vs. RHE [V]' 'charge [C]' 'time [min]' 'factor'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset-1)));
        % calculate current density
        for i=2:length(input.runnum)+1
            xlwrite(fileName, {sprintf('=%d/%d',result.GCcurrent(i-1),input.area)}, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset-1),i));    
        end
        % correct potential for RHE and do IR compensation to 100%
        for i=2:length(input.runnum)+1
            xlwrite(fileName, {sprintf('=%d+%d+%d*%d*%d',result.GCpotential(i-1),input.UtoRHE,(result.GCcurrent(i-1)*1E-3),input.Ru,(1-input.compensation))}, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset),i));    
        end

        xlwrite(fileName, num2cell(result.GCcharge), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+1)));
        xlwrite(fileName, num2cell(result.GCtime), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+2)));
        for i=2:length(input.runnum)+1
            xlwrite(fileName, {sprintf('=(1/(%s%d/96500*1E6)*%s%d/60*100)',GC_getXLScolumn(chargeoffset), i, GC_getXLScolumn(timeoffset), i)}, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset+3),i));
        end
        coloffset = coloffset+4;

        effoffset = coloffset;
        xlsData = {'CO [%]' 'CH4 [%]' 'C2H4 [%]' 'C2H6 [%]' 'O2 [%]' 'H2 [%]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlsData = {
                sprintf('=%s%d*2*%s%d', GC_getXLScolumn(umolhroffset), i, GC_getXLScolumn(factoroffset), i) ...
                sprintf('=%s%d*8*%s%d', GC_getXLScolumn(umolhroffset+1), i, GC_getXLScolumn(factoroffset), i) ...
                sprintf('=%s%d*12*%s%d', GC_getXLScolumn(umolhroffset+2), i, GC_getXLScolumn(factoroffset), i) ...
                sprintf('=%s%d*14*%s%d', GC_getXLScolumn(umolhroffset+3), i, GC_getXLScolumn(factoroffset), i) ...
                sprintf('=%s%d*4*%s%d', GC_getXLScolumn(umolhroffset+4), i, GC_getXLScolumn(factoroffset), i) ...
                sprintf('=%s%d*2*%s%d', GC_getXLScolumn(umolhroffset+5), i, GC_getXLScolumn(factoroffset), i) ...
                };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        coloffset = coloffset+6;
        xlsData = {'Total [%]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=sum(%s%d:%s%d)', GC_getXLScolumn(effoffset),i, GC_getXLScolumn(effoffset+5), i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        coloffset = coloffset+2;

        xlsData = {'timecode'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset-1)));
        xlwrite(fileName, num2cell(result.GCtimes'), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset-1)));

        selectoroffset = coloffset;
        xlsData = {'Selector'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlwrite(fileName, 'x', sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end

        errorcurrentoffset = coloffset+1;
        xlsData = {'Error Current [mA]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+1)));
        xlwrite(fileName, num2cell(result.GCcurrenterr), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+1)));

        xlsData = {'Error CO [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+2)));
        xlwrite(fileName, num2cell(result.FID_COerr), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+2)));

        xlsData = {'Error CH4 [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+3)));
        xlwrite(fileName, num2cell(result.FID_CH4err), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+3)));

        xlsData = {'Error CO 2nd [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+4)));
        xlwrite(fileName, num2cell(result.FID_CO_2nderr), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+4)));

        xlsData = {'Error CH4 2nd [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+5)));
        xlwrite(fileName, num2cell(result.FID_CH4_2nderr), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+5)));

        xlsData = {'Error C2H4 [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+6)));
        xlwrite(fileName, num2cell(result.FID_C2H4err), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+6)));

        xlsData = {'Error C2H6 [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+7)));
        xlwrite(fileName, num2cell(result.FID_C2H6err), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+7)));

        xlsData = {'Error O2 [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+8)));
        xlwrite(fileName, num2cell(result.TCD_O2err), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+8)));

        xlsData = {'Error H2 [raw]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset+9)));
        xlwrite(fileName, num2cell(result.TCD_H2err), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset+9)));

        
        Erroroffset = coloffset+10;
        xlsData = {'Error CO'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.FID_COerr(i-1)), abs(result.FID_CO(i-1)), GC_getXLScolumn(effoffset),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset), i));
        end

        xlsData = {'Error CH4'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset+1)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.FID_CH4err(i-1)), abs(result.FID_CH4(i-1)), GC_getXLScolumn(effoffset+1),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset+1), i));
        end

        xlsData = {'Error C2H4'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset+2)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.FID_C2H4err(i-1)), abs(result.FID_C2H4(i-1)), GC_getXLScolumn(effoffset+2),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset+2), i));
        end

        xlsData = {'Error C2H6'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset+3)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.FID_C2H6err(i-1)), abs(result.FID_C2H6(i-1)), GC_getXLScolumn(effoffset+3),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset+3), i));
        end

        xlsData = {'Error O2'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset+4)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.TCD_O2err(i-1)), abs(result.TCD_O2(i-1)), GC_getXLScolumn(effoffset+4),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset+4), i));
        end

        xlsData = {'Error H2'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(Erroroffset+5)));
        for i=2:length(input.runnum)+1
            xlsData = {sprintf('=IFERROR((%d/%d+%d/%d)*%s%d,0)', abs(result.GCcurrenterr(i-1)),abs(result.GCcurrent(i-1)), abs(result.TCD_H2err(i-1)), abs(result.TCD_H2(i-1)), GC_getXLScolumn(effoffset+5),i)};
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(Erroroffset+5), i));
        end

%         % for Sophia and her plots
%         xlsData = {'U vs. RHE [V]' 'CO [%]' 'CH4 [%]' 'C2H4 [%]' 'H2 [%]' 'Total [%]' 'Selector'};
%         xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
%         for i=2:length(input.runnum)+1
%             xlsData = {
%                 sprintf('=%s%d', GC_getXLScolumn(potentialoffset), i) ...
%                 sprintf('=%s%d', GC_getXLScolumn(effoffset), i) ...
%                 sprintf('=%s%d', GC_getXLScolumn(effoffset+1), i) ...
%                 sprintf('=%s%d', GC_getXLScolumn(effoffset+2), i) ...
%                 sprintf('=%s%d', GC_getXLScolumn(effoffset+5), i) ...
%                 sprintf('=sum(%s%d:%s%d)', GC_getXLScolumn(coloffset+1), i, GC_getXLScolumn(coloffset+4), i) ...
%                 sprintf('x') ...
%                 };
%             xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
%         end
%         coloffset = coloffset+7;
% 
% 
%         xlsData = {'CO_M f' 'CH4_M f' };
%         xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
%         for i=2:length(input.runnum)+1
%             xlsData = { % ppm = raw/f --> f = raw/ppm
%                 sprintf('=%s%d/%s%d', GC_getXLScolumn(rawoffset+2), i, GC_getXLScolumn(ppmoffset), i) ...
%                 sprintf('=%s%d/%s%d', GC_getXLScolumn(rawoffset+3), i, GC_getXLScolumn(ppmoffset+1), i) ...
%                 };
%             xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
%         end
        
        coloffset = coloffset+12+5;
        xlsData = {'INDEX' 'Sorted INDEX' 'U vs. RHE' 'CO' 'CH4' 'C2H4' 'C2H6' 'H2' 'Total' 'current' 'charge' 'Err current' 'Err CO' 'Err CH4' 'Err C2H4' 'Err C2H6' 'Err H2'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        maxrows = length(input.runnum)+1;
        for i=2:maxrows
            xlsData = {
                sprintf('=IFERROR(IF(ISBLANK($%s%d),"",1)*ROW(),"")',GC_getXLScolumn(selectoroffset), i) ... % index
                sprintf('=SMALL($%s$%d:$%s$%d,ROW()-1)',GC_getXLScolumn(coloffset),2, GC_getXLScolumn(coloffset), maxrows) ... % sorted index
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % U vs. RHE
                GC_getXLScolumn(potentialoffset),2,GC_getXLScolumn(potentialoffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % CO
                GC_getXLScolumn(effoffset),2,GC_getXLScolumn(effoffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % CH4
                GC_getXLScolumn(effoffset+1),2,GC_getXLScolumn(effoffset+1),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % C2H4
                GC_getXLScolumn(effoffset+2),2,GC_getXLScolumn(effoffset+2),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % C2H6
                GC_getXLScolumn(effoffset+3),2,GC_getXLScolumn(effoffset+3),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...                
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % H2
                GC_getXLScolumn(effoffset+5),2,GC_getXLScolumn(effoffset+5),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Total
                GC_getXLScolumn(effoffset+6),2,GC_getXLScolumn(effoffset+6),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % current
                GC_getXLScolumn(currentoffset),2,GC_getXLScolumn(currentoffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % charge
                GC_getXLScolumn(chargeoffset),2,GC_getXLScolumn(chargeoffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err current
                GC_getXLScolumn(errorcurrentoffset),2,GC_getXLScolumn(errorcurrentoffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err CO
                GC_getXLScolumn(Erroroffset),2,GC_getXLScolumn(Erroroffset),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err CH4
                GC_getXLScolumn(Erroroffset+1),2,GC_getXLScolumn(Erroroffset+1),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err C2H4
                GC_getXLScolumn(Erroroffset+2),2,GC_getXLScolumn(Erroroffset+2),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err C2H6
                GC_getXLScolumn(Erroroffset+3),2,GC_getXLScolumn(Erroroffset+3),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...                
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Err H2
                GC_getXLScolumn(Erroroffset+5),2,GC_getXLScolumn(Erroroffset+5),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
            };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
    end
    % open new datafile in Excel
    system(sprintf('open /Applications/Microsoft\\ Excel.app %s',fileName));
    %system(sprintf('open %s %s',path_to_EXCEL,fileName));
end
