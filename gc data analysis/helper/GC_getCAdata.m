%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_getCAdata(hfigure)
    % for CA ECLab data:
    potcol = find(strcmp('Ewe/V', hfigure.input.spectraEC(1).header));
    chargecol = find(strcmp('(Q-Qo)/C', hfigure.input.spectraEC(1).header));
    timecol = find(strcmp('time/s', hfigure.input.spectraEC(1).header));
    flowincol = find(strcmp('Analog IN 1/V', hfigure.input.spectraEC(1).header));
    if(isempty(flowincol))
        flowincol = -1;
    end
    flowoutcol = find(strcmp('Analog IN 2/V', hfigure.input.spectraEC(1).header));
    if(isempty(flowoutcol))
        flowoutcol = -1;
    end
    Rcmpcol = find(strcmp('Rcmp/Ohm', hfigure.input.spectraEC(1).header));
    if(isempty(Rcmpcol))
        Rcmpcol = -1;
    end
    Icol = find(strcmp('I/mA', hfigure.input.spectraEC(1).header));
    if(isempty(Icol))
        Icol = find(strcmp('<I>/mA', hfigure.input.spectraEC(1).header));
        if(isempty(Icol))
            Icol = -1;
        end
    end
    
    % need to check that all CA contain the information needed
    % todo: add support for mixed data files
    for i = 1:size(hfigure.input.spectraEC,1)
        if(potcol ~= find(strcmp('Ewe/V', hfigure.input.spectraEC(1).header)))
            potcol = -1; 
        end
        if(chargecol ~= find(strcmp('(Q-Qo)/C', hfigure.input.spectraEC(1).header)))
            chargecol = -1;
        end
        if(timecol ~= find(strcmp('time/s', hfigure.input.spectraEC(1).header)))
            timecol = -1;
        end
        if(flowincol ~= find(strcmp('Analog IN 1/V', hfigure.input.spectraEC(1).header)))
            flowincol = -1;
        end
        if(flowoutcol ~= find(strcmp('Analog IN 2/V', hfigure.input.spectraEC(1).header)))
            flowoutcol = -1;
        end
        if(Rcmpcol ~= find(strcmp('Rcmp/Ohm', hfigure.input.spectraEC(1).header)))
            Rcmpcol = -1;
        end
        if(Icol ~= find(strcmp('I/mA', hfigure.input.spectraEC(1).header)))
            if(Icol ~= find(strcmp('<I/mA>', hfigure.input.spectraEC(1).header)))
                Icol = -1;
            end
        end
    end
    
    hfigure.result.CA_data.flowin = NaN;
    hfigure.result.CA_data.flowout = NaN;
    hfigure.result.CA_data.time = NaN;
    hfigure.result.CA_data.charge = NaN;
    hfigure.result.CA_data.current = NaN;
    hfigure.result.CA_data.potential = NaN;
    hfigure.result.CA_data.Rcmp = NaN;
    
    pcount = 1;
    % loop through all the CA data files
    for i = 1:size(hfigure.input.spectraEC,2)
        % get the absolute timecode offset of the file
        try
            timecodeoffset = hfigure.input.spectraEC(i).timecode;
        catch
            timecodeoffset = 0;
        end
        % loop through all datapoints of a single CA data file
        for j=1:size(hfigure.input.spectraEC(i).spectrum,1)
            if(flowincol == -1)
                hfigure.result.CA_data.flowin(pcount) = hfigure.input.flowrate;  % fallback to manual value
            else
                hfigure.result.CA_data.flowin(pcount) = hfigure.input.spectraEC(i).spectrum(j,flowincol);
            end
            if(flowoutcol == -1)
                hfigure.result.CA_data.flowout(pcount) = hfigure.input.flowrate; % fallback to manual value
            else
                hfigure.result.CA_data.flowout(pcount) = hfigure.input.spectraEC(i).spectrum(j,flowoutcol);
            end
            if(Icol == -1)
                hfigure.result.CA_data.current(pcount) = 0;
            else
                hfigure.result.CA_data.current(pcount) = hfigure.input.spectraEC(i).spectrum(j,Icol);
            end
            if(Rcmpcol == -1)
                hfigure.result.CA_data.Rcmp(pcount) = hfigure.input.Ru*hfigure.input.compensation;
            else
                hfigure.result.CA_data.Rcmp(pcount) = hfigure.input.spectraEC(i).spectrum(j,Rcmpcol);
            end
            
            hfigure.result.CA_data.time(pcount) = hfigure.input.spectraEC(i).spectrum(j,timecol)+timecodeoffset;
            hfigure.result.CA_data.potential(pcount) = hfigure.input.spectraEC(i).spectrum(j,potcol);    
            hfigure.result.CA_data.charge(pcount) = hfigure.input.spectraEC(i).spectrum(j,chargecol);
            pcount = pcount + 1;
        end
    end
    
    hfigure.result.CA_data.time = hfigure.result.CA_data.time/60; % convert to minutes
    % sort time
    [~,sortidx] = sort(hfigure.result.CA_data.time);
    hfigure.result.CA_data.flowin = hfigure.result.CA_data.flowin(sortidx);
    hfigure.result.CA_data.flowout = hfigure.result.CA_data.flowout(sortidx);
    hfigure.result.CA_data.time = hfigure.result.CA_data.time(sortidx);
    hfigure.result.CA_data.charge = hfigure.result.CA_data.charge(sortidx);
    hfigure.result.CA_data.current = hfigure.result.CA_data.current(sortidx);
    hfigure.result.CA_data.potential = hfigure.result.CA_data.potential(sortidx);
    hfigure.result.CA_data.Rcmp = hfigure.result.CA_data.Rcmp(sortidx);
end
