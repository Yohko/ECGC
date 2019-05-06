%Licence: GNU General Public License version 2 (GPLv2)
function GC_calcfaradaicEff()
    global result input

    %CA_potentials = cell2mat(result.CAdata(1));
    %CA_charge = cell2mat(result.CAdata(2));
    CA_times = cell2mat(result.CAdata(3));
    %CA_totaltime = cumsum(CA_times);
    %CA_flowin = cell2mat(result.CAdata(4));
    CA_flowout = cell2mat(result.CAdata(5));
    CA_timeline = cell2mat(result.CAdata(6)); % already in minutes
    %CA_timeline = CA_timeline-CA_timeline(1);
    CA_chargeline = abs(cell2mat(result.CAdata(7)));
    CA_current = abs(cell2mat(result.CAdata(8)));
    CA_potentialline = cell2mat(result.CAdata(9));
    %CA_chargeline = cell2mat(result.CAdata(7));

    GCtimes = input.timecodes/60;
    result.H2Faraday = zeros(length(result.H2umolhr),1);
    result.COFaraday = zeros(length(result.H2umolhr),1);
    result.CH4Faraday = zeros(length(result.H2umolhr),1);
    result.C2H4Faraday = zeros(length(result.H2umolhr),1);
    result.C2H6Faraday = zeros(length(result.H2umolhr),1);
    result.GCpotential = zeros(length(result.H2umolhr),1);
    result.GCcurrent = zeros(length(result.H2umolhr),1);
    result.GCflowrate = zeros(length(result.H2umolhr),1);
    result.GCcharge = zeros(length(result.H2umolhr),1);
    result.GCtime = zeros(length(result.H2umolhr),1);
    %result.GCtimecode = zeros(length(result.H2umolhr),1);
    %CAcurrent = 0;

    offset = 0;
    CA_chargelinesum = zeros(length(CA_chargeline),1);
    for i=1:size(CA_chargeline,2)
       if(CA_chargeline(i) == 0 && i > 1)
          offset = CA_chargelinesum(i-1);
       end
       CA_chargelinesum(i) =  offset + CA_chargeline(i);
    end

    % loop through all GC spectra
    for i=1:length(result.H2umolhr)
        binidx = find((GCtimes(i)-input.GCinttime-input.GCoffsettime)<CA_timeline);
        if(input.GC_binning == 0) % for accumulation experiment
            charge =CA_chargelinesum(binidx(1));
            time = CA_times(1,binidx(1));
            binidxavg = find((GCtimes(i)-input.GCoffsettime)>CA_timeline & (GCtimes(i)-input.GCinttime-input.GCoffsettime)<CA_timeline);
            CAcurrent = mean(CA_current(binidxavg));
            CAflowrate = mean(CA_flowout(binidxavg));
            potential = mean(CA_potentialline(binidxavg));
        elseif(input.GC_binning == 1) % for flowcell experiment
            binidxavg = find((GCtimes(i)-input.GCoffsettime)>CA_timeline & (GCtimes(i)-input.GCinttime-input.GCoffsettime)<CA_timeline);
            if(isempty(binidxavg))
                charge = 0;
                time = 0;
                CAcurrent = 0;
                CAflowrate = 0;
                potential = 0;
            else
                charge = CA_chargelinesum(binidxavg(end))-CA_chargelinesum(binidxavg(1));
                CAcurrent = mean(CA_current(binidxavg));
                CAflowrate = mean(CA_flowout(binidxavg));
                potential = mean(CA_potentialline(binidxavg));
                time = CA_timeline(binidxavg(end))-CA_timeline(binidxavg(1));
            end
        end
        if(charge<0)
        % nothing here
        end

        factor = (1/(charge/96500*1E6)*time/60*100);
        result.H2Faraday(i) = result.H2umolhr(i)*2*factor;
        result.COFaraday(i) = result.COumolhr(i)*2*factor;
        result.CH4Faraday(i) = result.CH4umolhr(i)*8*factor;
        result.C2H4Faraday(i) = result.C2H4umolhr(i)*12*factor;
        result.C2H6Faraday(i) = result.C2H6umolhr(i)*14*factor;
        result.GCpotential(i) = potential; 
        result.GCcharge(i) = charge;
        result.GCtime(i) = time;
        result.GCtimes(i) = GCtimes(i)*60+8*60*60; % timezone correction
        result.GCcurrent(i) = CAcurrent;
        result.GCflowrate(i) = CAflowrate;
    end
end
