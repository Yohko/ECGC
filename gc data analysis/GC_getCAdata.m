%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_getCAdata(hfigure)
    CApotcount = 1;
    % for CA ECLab data:
    potcol = strmatch('Ewe/V', hfigure.input.spectraEC(1).header,'exact');
    chargecol = strmatch('(Q-Qo)/C', hfigure.input.spectraEC(1).header,'exact');
    timecol = strmatch('time/s', hfigure.input.spectraEC(1).header,'exact');
    flowincol = strmatch('Analog IN 1/V', hfigure.input.spectraEC(1).header,'exact');
    if(isempty(flowincol))
        flowincol = -1;
    end
    flowoutcol = strmatch('Analog IN 2/V', hfigure.input.spectraEC(1).header,'exact');
    if(isempty(flowoutcol))
        flowoutcol = -1;
    end
    Rcmpcol = strmatch('Rcmp/Ohm', hfigure.input.spectraEC(1).header,'exact');
	if(isempty(Rcmpcol))
        Rcmpcol = -1;
    end
    Icol = strmatch('I/mA', hfigure.input.spectraEC(1).header,'exact');
	if(isempty(Icol))
        Icol = strmatch('<I>/mA', hfigure.input.spectraEC(1).header,'exact');
        if(isempty(Icol))
            Icol = -1;
        end
    end
    cyclecol = strmatch('cycle number', hfigure.input.spectraEC(1).header,'exact');
	if(isempty(cyclecol))
        cyclecol = -1;
    end
	% need to check that all CA contain the information needed
    % todo: add support for mixed data files
    for i = 1:size(hfigure.input.spectraEC,1)
        if(potcol ~= strmatch('Ewe/V', hfigure.input.spectraEC(1).header,'exact'))
            potcol = -1; 
        end
        if(chargecol ~= strmatch('(Q-Qo)/C', hfigure.input.spectraEC(1).header,'exact'))
            chargecol = -1;
        end
        if(timecol ~= strmatch('time/s', hfigure.input.spectraEC(1).header,'exact'))
            timecol = -1;
        end
        if(flowincol ~= strmatch('Analog IN 1/V', hfigure.input.spectraEC(1).header,'exact'))
            flowincol = -1;
        end
        if(flowoutcol ~= strmatch('Analog IN 2/V', hfigure.input.spectraEC(1).header,'exact'))
            flowoutcol = -1;
        end
        if(Rcmpcol ~= strmatch('Rcmp/Ohm', hfigure.input.spectraEC(1).header,'exact'))
            Rcmpcol = -1;
        end
        if(cyclecol ~= strmatch('cycle number', hfigure.input.spectraEC(1).header,'exact'))
            cyclecol = -1;
        end
        if(Icol ~= strmatch('I/mA', hfigure.input.spectraEC(1).header,'exact'))
            if(Icol ~= strmatch('<I/mA>', hfigure.input.spectraEC(1).header,'exact'))
                Icol = -1;
            end
        end
    end
    CA_potentials = NaN;
    CA_charge = NaN;
    CA_times = NaN;
    CA_flowin = NaN;
    CA_flowout = NaN;
    CA_timeline = NaN;
    CA_chargeline = NaN;
    CA_potentialline = NaN;
    CA_current = NaN;
    CA_Rcmp = NaN;
    
    pcount = 1;
    timesingleCA = 0;
    chargesingleCA = 0;
    % loop through all the CA data files
    for i = 1:size(hfigure.input.spectraEC,2)
        % get the absolute timecode offset of the file
        try
            timecodeoffset = hfigure.input.spectraEC(i).timecode;
        catch
            timecodeoffset = 0;
        end
        % loop through all datapoints of a single CA data file
        timeoffset = hfigure.input.spectraEC(i).spectrum(1,timecol);
        if(cyclecol == -1)
            cycle = 1;
        else
            cycle = hfigure.input.spectraEC(i).spectrum(1,cyclecol);
        end
        % loop through the i CA data file content
        for j=1:size(hfigure.input.spectraEC(i).spectrum,1)
            if(cyclecol == -1)
                chargesingleCA = 0;
            else
                if(cycle ~= hfigure.input.spectraEC(i).spectrum(j,cyclecol))
                    cycle = hfigure.input.spectraEC(i).spectrum(j,cyclecol);
                    chargesingleCA = CA_charge(CApotcount);
                end
            end
            potential = hfigure.input.spectraEC(i).spectrum(j,potcol);
            % if Rcmp is on, the potentials can vary slightly
            % I will only compare the first digit after the dot, so
            % potential steps below 100mV are not possible at this moment
            if(round(CA_potentials(CApotcount),1) ~= round(potential,1))
                CApotcount = CApotcount+1;
                CA_potentials(CApotcount) = potential;
            end
            CA_charge(CApotcount) = hfigure.input.spectraEC(i).spectrum(j,chargecol)+chargesingleCA;
            CA_times(CApotcount) = hfigure.input.spectraEC(i).spectrum(j,timecol)-timeoffset+timesingleCA;
            if(flowincol == -1)
                CA_flowin(pcount) = hfigure.input.flowrate;  % fallback to manual value
            else
                CA_flowin(pcount) = hfigure.input.spectraEC(i).spectrum(j,flowincol);
            end
            if(flowoutcol == -1)
                CA_flowout(pcount) = hfigure.input.flowrate; % fallback to manual value
            else
                CA_flowout(pcount) = hfigure.input.spectraEC(i).spectrum(j,flowoutcol);
            end
            if(Icol == -1)
                CA_current(pcount) = 0;
            else
                CA_current(pcount) = hfigure.input.spectraEC(i).spectrum(j,Icol);
            end
            if(Rcmpcol == -1)
                CA_Rcmp(pcount) = hfigure.input.Ru;
            else
                CA_Rcmp(pcount) = hfigure.input.spectraEC(i).spectrum(j,Rcmpcol);
            end
            
            
            CA_timeline(pcount) = hfigure.input.spectraEC(i).spectrum(j,timecol)+timecodeoffset;
            CA_potentialline(pcount) = potential;            
            CA_chargeline(pcount) = hfigure.input.spectraEC(i).spectrum(j,chargecol)+chargesingleCA;
            pcount = pcount + 1;
        end
        timesingleCA = CA_times(CApotcount);
        chargesingleCA = CA_charge(CApotcount);
    end
    % resize vectors (first point is always 0 and not used)
    CA_potentials = CA_potentials(2:end);
    CA_charge = abs(CA_charge(2:end));
    CA_times = CA_times(2:end);
    % calculate only the charge passed and time during one potential step
    for i=2:size(CA_charge,2)
        CA_charge(end-i+2) = CA_charge(end-i+2)-CA_charge(end-i+1);
        CA_times(end-i+2) = CA_times(end-i+2)-CA_times(end-i+1);
    end
    CA_times = CA_times/60; % convert to minutes
    CA_timeline = CA_timeline/60; % convert to minutes
    hfigure.result.CAdata = {CA_potentials; CA_charge; CA_times; CA_flowin; CA_flowout;CA_timeline;CA_chargeline; CA_current; CA_potentialline; CA_Rcmp};
end
