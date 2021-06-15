%Licence: GNU General Public License version 2 (GPLv2)
function GC_exportXLS_V2(hfigure)
    eval(hfigure.GC_usersetting); % load settings

    fileName = sprintf('%s.xlsx',hfigure.input.resultname);
    
    % somehow the new office does something to the files 
    % when they are edited so they cannot be edited by this program anymore
    % and need to be deleted
    if exist(fileName, 'file')==2
        delete(fileName);
    end
    rows = length(hfigure.input.CH(1).spectra);
   
    % set sequence of worksheets
    xlsData = {};
    writecell(xlsData,  fileName, 'Sheet', 'PLOTS', 'Range', 'A1','UseExcel',true);
    writecell(xlsData,  fileName, 'Sheet', 'RESULTS', 'Range', 'A1','UseExcel',true);
    writecell(xlsData,  fileName, 'Sheet', 'GC_DATA', 'Range', 'A1','UseExcel',true);
    writecell(xlsData,  fileName, 'Sheet', 'CA_DATA', 'Range', 'A1','UseExcel',true);
    writecell(xlsData,  fileName, 'Sheet', 'CAL_DATA', 'Range', 'A1','UseExcel',true);
    
    
    %% calibration sheet
    coloffset = 1;
    % header
    xlsData = {'name', 'factor', 'offset'};
    % data

    
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            xlsData = [xlsData;...
                {sprintf('%s_%s',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name), ...
                 hfigure.result.CH(jj).peak(ii).factor,...
                 hfigure.result.CH(jj).peak(ii).offset...
                }];
        end
	end
    writecell(xlsData,  fileName, 'Sheet', 'CAL_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);


    %% GC_DATA sheet
    coloffset = 1;
    % header
    xlsData = {'Name', 'Number', 'epoch [sec]'};
    % data
    for i=1:rows
        xlsData = [xlsData;{hfigure.input.CH(1).spectra(i).runname, hfigure.input.CH(1).spectra(i).runnum, hfigure.result.GC_data.times(i)}];
    end
    writecell(xlsData,  fileName, 'Sheet', 'GC_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);
    % rawdata
    rawoffset = coloffset;
    xlsData = {};
    % header
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            xlsData = [xlsData,...
                {sprintf('%s_%s [raw]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name), ...
                sprintf('%s_%s_err [raw]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name)}];
        end
	end
    %data
    for i=1:rows
        xlsDataline = {};
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                xlsDataline = [xlsDataline,...
                    {hfigure.result.CH(jj).peak(ii).area(i), ...
                    hfigure.result.CH(jj).peak(ii).err(i)}];
            end
        end
        xlsData = [xlsData;xlsDataline];
    end
    writecell(xlsData,  fileName, 'Sheet', 'GC_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);

    % ppm data
    ppmoffset = coloffset;
    xlsData = {};
    % header
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            xlsData = [xlsData,...
                {sprintf('%s_%s [ppm]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name), ...
                sprintf('%s_%s_err [ppm]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name)}];
        end
	end
    %data
    for i=1:rows
        peaknum = 2;
        xlsDataline = {};
        datanum = 0;
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                xlsDataline = [xlsDataline,...
                    {sprintf('=%s%d*CAL_DATA!B%d+CAL_DATA!C%d',GC_getXLScolumn(rawoffset+datanum),i+1,peaknum,peaknum), ...
                    sprintf('=%s%d*CAL_DATA!B%d+CAL_DATA!C%d',GC_getXLScolumn(rawoffset+1+datanum),i+1,peaknum,peaknum)}];
                datanum = datanum+2;
                peaknum = peaknum+1;
            end
        end
        xlsData = [xlsData;xlsDataline];
    end
    writecell(xlsData,  fileName, 'Sheet', 'GC_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);


    %% CA_DATA sheet
    coloffset = 1;
    % header
    xlsData = {'GC_Name', 'Number', 'epoch [sec]'};
    % data
    for i=1:rows
        xlsData = [xlsData;{hfigure.input.CH(1).spectra(i).runname, hfigure.input.CH(1).spectra(i).runnum, hfigure.result.GC_data.times(i)}];
    end
    writecell(xlsData,  fileName, 'Sheet', 'CA_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);

    
    % header
    xlsData = {'U[V]','Uerr[V]','U2RHE[V]','Ru[ohm]','comp','j[mA]','j_err[mA]','time[min]','charge[C]','flowrate[sccm]','flowrate_err[sccm]'};
    % data
    for i=1:rows
        xlsData = [xlsData;{...
                   hfigure.result.GC_data.potential(i),... % U
                   hfigure.result.GC_data.potentialerr(i),...
                   hfigure.input.UtoRHE,...
                   hfigure.result.GC_data.Ru(i),...
                   hfigure.input.compensation,...
                   hfigure.result.GC_data.current(i),... %current
                   hfigure.result.GC_data.currenterr(i),... %currenterr
                   hfigure.result.GC_data.time(i),... % time
                   hfigure.result.GC_data.charge(i),... % charge
                   hfigure.result.GC_data.flowrate(i),... % flowrateerr
                   hfigure.result.GC_data.flowrateerr(i)... % flowrate
            }];
    end
    writecell(xlsData,  fileName, 'Sheet', 'CA_DATA', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);


    
    %% RESULTS sheet
    coloffset = 1;
    % header
    xlsData = {'selector', 'Name', 'Number', 'epoch [sec]', 't [sec]', 'U vs RHE [V]','U_err [V]', 'j [mA]','j_err [mA]'};
    % data
    for i=1:rows
        xlsData = [xlsData;{...
            'x', ... %A
            hfigure.input.CH(1).spectra(i).runname, ... %B
            hfigure.input.CH(1).spectra(i).runnum, ... %C
            hfigure.result.GC_data.times(i),... %D
            sprintf('=$D%d-$D$2',i+1),... %E
             sprintf('=CA_DATA!$D%d+CA_DATA!$F%d+(CA_DATA!$I%d*1E-3)*CA_DATA!$G%d*(1-CA_DATA!$H%d)',...
                i+1,i+1,i+1,i+1,i+1),... %F
            sprintf('=ABS($F%d)*ABS(CA_DATA!$J%d/CA_DATA!$I%d)',i+1,i+1,i+1),...
            sprintf('=CA_DATA!$I%d',i+1),...
            sprintf('=CA_DATA!$J%d',i+1)...
            }];
    end
    writecell(xlsData,  fileName, 'Sheet', 'RESULTS', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);

    % header
    FEoffset = coloffset;
    xlsData = {};
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            xlsData = [xlsData,...
                {sprintf('%s_%s [%%]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name), ...
                sprintf('%s_%s_err [%%]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name)}];
        end
	end
    %data
    Faraday = 96500;
    %FE = n*ppm*1E-6/24.5[L]*F/j[mA]*flow[sccm]/60*100
    %FE_err = FE*(dj/j+dppm/ppm+dflow/flow)
    for i=1:rows
        xlsDataline = {};
        datanum = 0;
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                xlsDataline = [xlsDataline,...
                    {sprintf('=IFERROR(%d*GC_DATA!$%s%d*1E-6/24.5*%f/ABS(CA_DATA!$I%d)*CA_DATA!$M%d/60*100,0)',...
                            hfigure.result.CH(jj).peak(ii).n, ...
                            GC_getXLScolumn(ppmoffset+datanum),i+1,...
                            Faraday,i+1,i+1),...
                    sprintf('=IFERROR(ABS($%s%d)*(ABS(CA_DATA!$J%d/CA_DATA!$I%d)+ABS(GC_DATA!$%s%d/GC_DATA!$%s%d)+ABS(CA_DATA!$N%d/CA_DATA!$M%d)),0)',...
                                GC_getXLScolumn(coloffset+datanum),i+1, ...
                                i+1,i+1,... %dj/j
                                GC_getXLScolumn(ppmoffset+datanum+1),i+1,... %dppm
                                GC_getXLScolumn(ppmoffset+datanum),i+1,... %ppm
                                i+1,i+1 ... %dflow/flow
                            )}];
                datanum = datanum+2;
            end
        end
        xlsData = [xlsData;xlsDataline];
    end
    writecell(xlsData,  fileName, 'Sheet', 'RESULTS', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);
    
    %% PLOT sheet
    coloffset = 1;
    % header
    xlsData = {'INDEX', 'Sorted INDEX', 't [sec]', 'U vs RHE [V]', 'U_err [V]', 'j [mA]','j_err [mA]'};
    % data
    for i=1:rows
        xlsData = [xlsData;{...
                sprintf('=IFERROR(IF(ISBLANK(RESULTS!$A%d),"",1)*ROW(),"")',i+1),... % A
                sprintf('=SMALL($A$2:$A$%d,ROW()-1)',rows+1),... %B
                sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$E$2:$E$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,rows+1,...
                        i+1,rows+1),...
                sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$F$2:$F$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,rows+1,...
                        i+1,rows+1),...
                sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$G$2:$G$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,rows+1,...
                        i+1,rows+1),...
                sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$H$2:$H$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,rows+1,...
                        i+1,rows+1),...
                sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$I$2:$I$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,rows+1,...
                        i+1,rows+1),...
                }];
    end
    writecell(xlsData,  fileName, 'Sheet', 'PLOTS', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);

    
    selFEoffset = coloffset;
   % header
    xlsData = {};
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            if (isfield(hfigure.input.CH(jj).peak(ii),'XLS') && ~isempty(hfigure.input.CH(jj).peak(ii).XLS))
                usepeak = hfigure.input.CH(jj).peak(ii).XLS;
            else
                usepeak = 0;
            end
            if (usepeak == 1)
                xlsData = [xlsData,...
                    {sprintf('%s_%s [%%]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name), ...
                    sprintf('%s_%s_err [%%]',hfigure.result.CH(jj).name, hfigure.result.CH(jj).peak(ii).name)}];
            end
        end
	end
    xlsData = [xlsData,{'total [%]', 'total_err [%]'}];
    % DATA
    for i=1:rows
        strTotal = '';
        strTotalerr = '';
        xlsDataline = {};
        datanum = 0;
        addednum = 0;
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                if (isfield(hfigure.input.CH(jj).peak(ii),'XLS') && ~isempty(hfigure.input.CH(jj).peak(ii).XLS))
                    usepeak = hfigure.input.CH(jj).peak(ii).XLS;
                else
                    usepeak = 0;
                end
                if (usepeak == 1)
                    strTotal = sprintf('%s+$%s%d',strTotal,GC_getXLScolumn(coloffset+addednum),i+1);
                    strTotalerr = sprintf('%s+$%s%d',strTotalerr,GC_getXLScolumn(coloffset+addednum+1),i+1);
                    xlsDataline = [xlsDataline,{...
                    sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$%s$2:$%s$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,...
                            GC_getXLScolumn(FEoffset+datanum),GC_getXLScolumn(FEoffset+datanum),...
                            rows+1,...
                            i+1,rows+1),...
                    sprintf('=IF(ISNUMBER($B%d),INDEX(RESULTS!$%s$2:$%s$%d,MATCH($B%d,$A$2:$A$%d,0)),NA())',i+1,...
                            GC_getXLScolumn(FEoffset+datanum+1),GC_getXLScolumn(FEoffset+datanum+1),...
                            rows+1,...
                            i+1,rows+1)...                        
                        }];
                    addednum = addednum+2;
                end
                datanum = datanum+2;
            end
        end
        strTotal(1) = '=';
        strTotalerr(1) = '=';
        xlsDataline = [xlsDataline,{strTotal, strTotalerr}];
        xlsData = [xlsData;xlsDataline];
    end
    writecell(xlsData,  fileName, 'Sheet', 'PLOTS', 'Range', sprintf('%s1',GC_getXLScolumn(coloffset)),'UseExcel',true);
    coloffset = coloffset+size(xlsData,2);

    %% open
    try
        % open new datafile in Excel
%        if ispc
%            winopen(fileName);
%        else         
%            uiopen(fileName);
%        end
        if ispc
            % Open excel
            xl = actxserver('Excel.Application');
            % Make excel visible
            set(xl,'Visible',1);
            % Open document
            xls = xl.Workbooks.Open(fullfile(pwd,fileName));
            % Define worksheet variable
            xlss = xls.Worksheets;
            % Select plots worksheet
            xlssl = xlss.get('Item',1);
            % Activate selected worksheet
            xlssl.Activate;
            
            %%
            % Create a chart in a defined location and size
            FEchart = xlssl.ChartObjects.Add(50, 40, 300, 200);
            % Set chart type
            FEchart.Chart.Charttype = 'xlXYScatterSmooth';
            for i=1:addednum/2
                FEchart.Chart.SeriesCollection.NewSeries;
                tmpname = sprintf('=PLOTS!$%s$1',GC_getXLScolumn(selFEoffset+2*(i-1)));
                FEchart.Chart.SeriesCollection(i).Name = tmpname;
                FEchart.Chart.SeriesCollection(i).XValues = xlssl.Range(sprintf('C2:C%i',rows+1)); % time
                FEchart.Chart.SeriesCollection(i).Values = xlssl.Range(sprintf('%s2:%s%i',GC_getXLScolumn(selFEoffset+2*(i-1)),GC_getXLScolumn(selFEoffset+2*(i-1)),rows+1));
            end

            FEchart.Chart.HasTitle = 0;
            FEchart.Chart.Axes(1).HasTitle = 1;
            FEchart.Chart.Axes(2).HasTitle = 1;
            FEchart.Chart.Axes(1).AxisTitle.Text = 'time [sec]';
            FEchart.Chart.Axes(2).AxisTitle.Text = 'F.E. [%]';
            FEchart.Chart.Axes(1).MajorTickMark = 2;%'xlInside'
            %FEchart.Chart.Axes(1).MinorTickMark = 2;%'xlInside'
            FEchart.Chart.Axes(2).MajorTickMark = 2;%'xlInside'
            %FEchart.Chart.Axes(2).MinorTickMark = 2;%'xlInside'

            %FEchart.Chart.Axes(1).Border.Color = 1;
            %FEchart.Chart.Axes(2).Border.Color = 1;


            FEchart.Chart.Axes(1).Crosses = 4;%xlMinimum
            FEchart.Chart.Axes(2).Crosses = 4;%xlMinimum
            FEchart.Chart.Axes(1).TickLabels.Font.Size = 12;
            FEchart.Chart.Axes(1).TickLabels.Font.Name = "Times New Roman";
            FEchart.Chart.Axes(2).TickLabels.Font.Size = 12;
            FEchart.Chart.Axes(2).TickLabels.Font.Name = "Times New Roman";

            %%
            JTchart = xlssl.ChartObjects.Add(360, 40, 300, 200);
            JTchart.Chart.Charttype = 'xlXYScatterSmooth';
            JTchart.Chart.SeriesCollection.NewSeries;
            JTchart.Chart.SeriesCollection(1).Name = 'j';
            JTchart.Chart.SeriesCollection(1).XValues = xlssl.Range(sprintf('C2:C%i',rows+1)); % time
            JTchart.Chart.SeriesCollection(1).Values = xlssl.Range(sprintf('F2:F%i',rows+1));
            
            %JTchart.Chart.PlotArea.Border.Color = 1
            JTchart.Chart.HasTitle = 0;
            JTchart.Chart.Axes(1).HasTitle = 1;
            JTchart.Chart.Axes(2).HasTitle = 1;
            JTchart.Chart.Axes(1).AxisTitle.Text = 'time [sec]';
            JTchart.Chart.Axes(2).AxisTitle.Text = 'j [mA]';
            JTchart.Chart.Axes(1).MajorTickMark = 2;%'xlInside'
            %JTchart.Chart.Axes(1).MinorTickMark = 2;%'xlInside'
            JTchart.Chart.Axes(2).MajorTickMark = 2;%'xlInside'
            %JTchart.Chart.Axes(2).MinorTickMark = 2;%'xlInside'

            %JTchart.Chart.Axes(1).Border.Color = 1;
            %JTchart.Chart.Axes(2).Border.Color = 1;

            JTchart.Chart.Axes(1).Crosses = 4;%xlMinimum
            JTchart.Chart.Axes(2).Crosses = 4;%xlMinimum
            JTchart.Chart.Axes(1).TickLabels.Font.Size = 12;
            JTchart.Chart.Axes(1).TickLabels.Font.Name = "Times New Roman";
            JTchart.Chart.Axes(2).TickLabels.Font.Size = 12;
            JTchart.Chart.Axes(2).TickLabels.Font.Name = "Times New Roman";
            

            xls.Save
            xl.Quit
            xl.delete
            winopen(fileName);
        end
    catch
    end
end
