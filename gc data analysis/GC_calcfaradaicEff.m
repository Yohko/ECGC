%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_calcfaradaicEff(hfigure)
    %CA_potentials = cell2mat(hfigure.result.CAdata(1));
    %CA_charge = cell2mat(hfigure.result.CAdata(2));
    CA_times = cell2mat(hfigure.result.CAdata(3));
    %CA_totaltime = cumsum(CA_times);
    %CA_flowin = cell2mat(hfigure.result.CAdata(4));
    CA_flowout = cell2mat(hfigure.result.CAdata(5));
    CA_timeline = cell2mat(hfigure.result.CAdata(6)); % already in minutes
    %CA_timeline = CA_timeline-CA_timeline(1);
    CA_chargeline = abs(cell2mat(hfigure.result.CAdata(7)));
    CA_current = abs(cell2mat(hfigure.result.CAdata(8)));
    CA_potentialline = cell2mat(hfigure.result.CAdata(9));
    CA_Rcmp = cell2mat(hfigure.result.CAdata(10))/hfigure.input.compensation;
    %CA_chargeline = cell2mat(hfigure.result.CAdata(7));
    GCtimes = hfigure.input.timecodes/60;
    hfigure.result.GCpotential = zeros(length(hfigure.result.peakCH1(1).area),1);
    hfigure.result.GCcurrent = zeros(length(hfigure.result.peakCH1(1).area),1);
    hfigure.result.GCcurrenterr = zeros(length(hfigure.result.peakCH1(1).area),1);
    hfigure.result.GCflowrate = zeros(length(hfigure.result.peakCH1(1).area),1);
    hfigure.result.GCcharge = zeros(length(hfigure.result.peakCH1(1).area),1);
    hfigure.result.GCtime = zeros(length(hfigure.result.peakCH1(1).area),1);
    %hfigure.result.GCtimecode = zeros(length(hfigure.result.peakCH1(1).area),1);
    CAcurrent = 0;

    offset = 0;
    CA_chargelinesum = zeros(length(CA_chargeline),1);
    for i=1:size(CA_chargeline,2)
       if(CA_chargeline(i) == 0 && i > 1)
          offset = CA_chargelinesum(i-1);
       end
       CA_chargelinesum(i) =  offset + CA_chargeline(i);
    end

    % loop through all GC spectra
    for i=1:length(hfigure.result.peakCH1(1).area)
        binidx = find((GCtimes(i)-hfigure.input.GCinttime-hfigure.input.GCoffsettime)<CA_timeline);
        if(hfigure.input.GC_binning == 0) % for accumulation experiment
            charge =CA_chargelinesum(binidx(1));
            time = CA_times(1,binidx(1));
            binidxavg = find((GCtimes(i)-hfigure.input.GCoffsettime)>CA_timeline & (GCtimes(i)-hfigure.input.GCinttime-hfigure.input.GCoffsettime)<CA_timeline);
            CAcurrent = mean(CA_current(binidxavg));
            CAcurrenterr = std(CA_current(binidxavg));
            CAflowrate = mean(CA_flowout(binidxavg));
            potential = mean(CA_potentialline(binidxavg));
            Rucmp = mean(CA_Rcmp(binidxavg));
        elseif(hfigure.input.GC_binning == 1) % for flowcell experiment
            binidxavg = find((GCtimes(i)-hfigure.input.GCoffsettime)>CA_timeline & (GCtimes(i)-hfigure.input.GCinttime-hfigure.input.GCoffsettime)<CA_timeline);
            if(isempty(binidxavg))
                charge = 0;
                time = 0;
                CAcurrent = 0;
                CAcurrenterr = 0;
                CAflowrate = 0;
                potential = 0;
                Rucmp = 0;
            else
                charge = CA_chargelinesum(binidxavg(end))-CA_chargelinesum(binidxavg(1));
                CAcurrent = mean(CA_current(binidxavg));
                CAcurrenterr = std(CA_current(binidxavg));
                CAflowrate = mean(CA_flowout(binidxavg));
                potential = mean(CA_potentialline(binidxavg));
                Rucmp = mean(CA_Rcmp(binidxavg));
                time = CA_timeline(binidxavg(end))-CA_timeline(binidxavg(1));
            end
        end
        if(charge<0)
        % nothing here
        end

        factor = (1/(charge/96500*1E6)*time/60*100);
        for ii = 1:length(hfigure.result.peakCH1)
            hfigure.result.peakCH1(ii).Faraday = hfigure.result.peakCH1(ii).umolhr(i)*hfigure.result.peakCH1(ii).n*factor;
        end
        
        for ii = 1:length(hfigure.result.peakCH2)
            hfigure.result.peakCH2(ii).Faraday = hfigure.result.peakCH2(ii).umolhr(i)*hfigure.result.peakCH2(ii).n*factor;
        end
        hfigure.result.GCpotential(i) = potential;
        hfigure.result.GCcharge(i) = charge;
        hfigure.result.GCtime(i) = time;
        hfigure.result.GCtimes(i) = GCtimes(i)*60+8*60*60; % timezone correction
        hfigure.result.GCcurrent(i) = CAcurrent;
        hfigure.result.GCRu(i) = Rucmp;
        hfigure.result.GCflowrate(i) = CAflowrate;
        hfigure.result.GCcurrenterr(i) = 3*CAcurrenterr;
    end
end
