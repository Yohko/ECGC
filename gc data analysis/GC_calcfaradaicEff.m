%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_calcfaradaicEff(hfigure)
    offset = 0;
    CA_chargesum = zeros(length(hfigure.result.CA_data.charge),1);
    for i=1:length(hfigure.result.CA_data.charge)
       if(hfigure.result.CA_data.charge(i) == 0 && i > 1)
          offset = CA_chargesum(i-1);
       end
       CA_chargesum(i) =  offset + hfigure.result.CA_data.charge(i);
    end

    charge = 0;
    time = 0;
    CAcurrent = 0;
    CAcurrenterr = 0;
    CAflowrate = 0;
    potential = 0;
    Rucmp = 0;
    
    % loop through all GC spectra
	for i=1:length(hfigure.input.CH(1).spectra)
        if(hfigure.input.GC_binning == 0) % for accumulation experiment
            % find all CA data point before the injection time
            binidxavg = find((hfigure.input.CH(1).spectra(i).timecode/60-hfigure.input.GCoffsettime)>=hfigure.result.CA_data.time);
            % get complete charge until injection
            charge = CA_chargesum(binidxavg(end));
            time = hfigure.result.CA_data.time(binidxavg(end));
            % calculate average current, flow and potential for this injection
            CAcurrent = mean(hfigure.result.CA_data.current(binidxavg));
            CAcurrenterr = std(hfigure.result.CA_data.current(binidxavg));
            CAflowrate = mean(hfigure.result.CA_data.flowout(binidxavg));
            potential = mean(hfigure.result.CA_data.potential(binidxavg));
            CAflowrateerr = std(hfigure.result.CA_data.flowout(binidxavg));
            potentialerr = std(hfigure.result.CA_data.potential(binidxavg));
            Rucmp = mean(hfigure.result.CA_data.Rcmp(binidxavg));
        elseif(hfigure.input.GC_binning == 1) % for flowcell experiment
            % find all CA data point before the injection time
            binidxavg = find((hfigure.input.CH(1).spectra(i).timecode/60-hfigure.input.GCoffsettime)>=hfigure.result.CA_data.time ...
                & (hfigure.input.CH(1).spectra(i).timecode/60-hfigure.input.GCinttime-hfigure.input.GCoffsettime)<=hfigure.result.CA_data.time);
            % get the all CA data points within the injection window
            % (t_inj-t_offset-t_integrate) < t_CA < (t_inj-t_offset)
            if(isempty(binidxavg)) % no CA information available
                charge = 0;
                time = 0;
                CAcurrent = 0;
                CAcurrenterr = 0;
                CAflowrate = 0;
                CAflowrateerr = 0;
                potential = 0;
                potentialerr = 0;
                Rucmp = 0;
            else % CA information available
                charge = CA_chargesum(binidxavg(end))-CA_chargesum(binidxavg(1));
                CAcurrent = mean(hfigure.result.CA_data.current(binidxavg));
                CAcurrenterr = std(hfigure.result.CA_data.current(binidxavg));
                CAflowrate = mean(hfigure.result.CA_data.flowout(binidxavg));
                CAflowrateerr = std(hfigure.result.CA_data.flowout(binidxavg));
                potential = mean(hfigure.result.CA_data.potential(binidxavg));
                potentialerr = std(hfigure.result.CA_data.potential(binidxavg));
                Rucmp = mean(hfigure.result.CA_data.Rcmp(binidxavg));
                time = hfigure.result.CA_data.time(binidxavg(end))-hfigure.result.CA_data.time(binidxavg(1));
            end
        end
        
        % calculate the faradaic efficiency for each component/peak
        factor = (1/(abs(charge)/96500*1E6)*time*60*100);
        for jj = 1:length(hfigure.result.CH)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                hr = hfigure.input.headspacevol/(CAflowrate/60)*1000;
                hfigure.result.CH(jj).peak(ii).ppm(i) = hfigure.result.CH(jj).peak(ii).offset;
                for m=1:length(hfigure.result.CH(jj).peak(ii).factor)
                    hfigure.result.CH(jj).peak(ii).ppm(i) = hfigure.result.CH(jj).peak(ii).ppm(i) + ...
                      hfigure.result.CH(jj).peak(ii).factor(m) * hfigure.result.CH(jj).peak(ii).area(i)^m;
                end
                hfigure.result.CH(jj).peak(ii).uM(i) = hfigure.result.CH(jj).peak(ii).ppm(i)./24.5;
                hfigure.result.CH(jj).peak(ii).umol(i) = hfigure.result.CH(jj).peak(ii).uM(i) ...
                                                         .*hfigure.input.headspacevol;
                hfigure.result.CH(jj).peak(ii).umolhr(i) = hfigure.result.CH(jj).peak(ii).umol(i) ...
                                                           ./hr;
                hfigure.result.CH(jj).peak(ii).Faraday(i) = hfigure.result.CH(jj).peak(ii).umolhr(i) ...
                                                            *hfigure.result.CH(jj).peak(ii).n ...
                                                            *factor;
            end
        end
        
        hfigure.result.GC_data.potential(i) = potential;
        hfigure.result.GC_data.potentialerr(i) = 3*potentialerr;
        hfigure.result.GC_data.charge(i) = charge;
        hfigure.result.GC_data.time(i) = time;
        hfigure.result.GC_data.times(i) = hfigure.input.CH(1).spectra(i).timecode+hfigure.input.GC_timezonecorr; % timezone correction
        hfigure.result.GC_data.current(i) = CAcurrent;
        hfigure.result.GC_data.Ru(i) = Rucmp/hfigure.input.compensation;
        hfigure.result.GC_data.flowrate(i) = CAflowrate;
        hfigure.result.GC_data.flowrateerr(i) = 3*CAflowrateerr;
        hfigure.result.GC_data.currenterr(i) = 3*CAcurrenterr;
	end
end
