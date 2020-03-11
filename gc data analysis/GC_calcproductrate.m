%Licence: GNU General Public License version 2 (GPLv2)
function GC_calcproductrate()
    global result input

    CA_flowout = cell2mat(result.CAdata(5));
    input.flowrate = mean(CA_flowout);
    input.hr = input.headspacevol/input.flowrate/60*1000;

	for ii = 1:length(result.peakFID)
        result.peakFID(ii).ppm = (result.peakFID(ii).area+result.peakFID(ii).offset)./result.peakFID(ii).factor;
        result.peakFID(ii).uM = result.peakFID(ii).ppm./24.5;
        result.peakFID(ii).umol = result.peakFID(ii).uM.*input.headspacevol;
        result.peakFID(ii).umolhr = result.peakFID(ii).umol./input.hr;
	end

	for ii = 1:length(result.peakTCD)
        result.peakTCD(ii).ppm = (result.peakTCD(ii).area+result.peakTCD(ii).offset)./result.peakTCD(ii).factor;
        result.peakTCD(ii).uM = result.peakTCD(ii).ppm./24.5;
        result.peakTCD(ii).umol = result.peakTCD(ii).uM.*input.headspacevol;
        result.peakTCD(ii).umolhr = result.peakTCD(ii).umol./input.hr;
	end
end
