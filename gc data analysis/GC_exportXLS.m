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
    xlsData = {'Name' 'Number' 'CO' 'CH4' 'CO 2nd' 'CH4 2nd' 'C2H4' 'C2H6' 'O2' 'H2'};
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

        xlsData = {'time [min]'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset-1)));
        xlwrite(fileName, num2cell(result.GCtimes'), sheetName, sprintf('%s2',GC_getXLScolumn(coloffset-1)));


        % for Sophia and her plots
        xlsData = {'U vs. RHE [V]' 'CO [%]' 'CH4 [%]' 'C2H4 [%]' 'H2 [%]' 'Total [%]' 'Selector'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlsData = {
                sprintf('=%s%d', GC_getXLScolumn(potentialoffset), i) ...
                sprintf('=%s%d', GC_getXLScolumn(effoffset), i) ...
                sprintf('=%s%d', GC_getXLScolumn(effoffset+1), i) ...
                sprintf('=%s%d', GC_getXLScolumn(effoffset+2), i) ...
                sprintf('=%s%d', GC_getXLScolumn(effoffset+5), i) ...
                sprintf('=sum(%s%d:%s%d)', GC_getXLScolumn(coloffset+1), i, GC_getXLScolumn(coloffset+4), i) ...
                sprintf('x') ...
                };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        coloffset = coloffset+7;


        xlsData = {'CO_M f' 'CH4_M f' };
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        for i=2:length(input.runnum)+1
            xlsData = { % ppm = raw/f --> f = raw/ppm
                sprintf('=%s%d/%s%d', GC_getXLScolumn(rawoffset+2), i, GC_getXLScolumn(ppmoffset), i) ...
                sprintf('=%s%d/%s%d', GC_getXLScolumn(rawoffset+3), i, GC_getXLScolumn(ppmoffset+1), i) ...
                };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
        
        coloffset = coloffset+12;
        xlsData = {'INDEX' 'Sorted INDEX' 'U vs. RHE' 'CO' 'CH4' 'C2H4' 'C2H6' 'H2' 'Total' 'current' 'charge'};
        xlwrite(fileName, xlsData, sheetName, sprintf('%s1',GC_getXLScolumn(coloffset)));
        maxrows = length(input.runnum)+1;
        for i=2:maxrows
            xlsData = {
                sprintf('=IFERROR(IF(ISBLANK($%s%d),"",1)*ROW(),"")',GC_getXLScolumn(coloffset-13), i) ... % index
                sprintf('=SMALL($%s$%d:$%s$%d,ROW()-1)',GC_getXLScolumn(coloffset),2, GC_getXLScolumn(coloffset), maxrows) ... % sorted index
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % U vs. RHE
                GC_getXLScolumn(coloffset-19),2,GC_getXLScolumn(coloffset-19),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % CO
                GC_getXLScolumn(coloffset-18),2,GC_getXLScolumn(coloffset-18),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % CH4
                GC_getXLScolumn(coloffset-17),2,GC_getXLScolumn(coloffset-17),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % C2H4
                GC_getXLScolumn(coloffset-16),2,GC_getXLScolumn(coloffset-16),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % C2H6
                GC_getXLScolumn(coloffset-24),2,GC_getXLScolumn(coloffset-24),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...                
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % H2
                GC_getXLScolumn(coloffset-15),2,GC_getXLScolumn(coloffset-15),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % Total
                GC_getXLScolumn(coloffset-14),2,GC_getXLScolumn(coloffset-14),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % current
                GC_getXLScolumn(coloffset-32),2,GC_getXLScolumn(coloffset-32),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                sprintf('=IF(ISNUMBER(%s%d),INDEX(%s$%d:%s$%d,MATCH(%s%d,%s$%d:%s$%d,0)),NA())',GC_getXLScolumn(coloffset+1),i, ... % charge
                GC_getXLScolumn(coloffset-30),2,GC_getXLScolumn(coloffset-30),maxrows, ...
                GC_getXLScolumn(coloffset+1),i,GC_getXLScolumn(coloffset),2,GC_getXLScolumn(coloffset),maxrows) ...
                };
            xlwrite(fileName, xlsData, sheetName, sprintf('%s%d', GC_getXLScolumn(coloffset), i));
        end
    end
    % open new datafile in Excel
    system(sprintf('open /Applications/Microsoft\\ Excel.app %s',fileName));
    %system(sprintf('open %s %s',path_to_EXCEL,fileName));
end
