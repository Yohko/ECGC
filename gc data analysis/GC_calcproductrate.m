%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_calcproductrate(hfigure)
    CA_flowout = cell2mat(hfigure.result.CAdata(5));
    hfigure.input.flowrate = mean(CA_flowout);
    hfigure.input.hr = hfigure.input.headspacevol/hfigure.input.flowrate/60*1000;

	for ii = 1:length(hfigure.result.peakCH1)
        hfigure.result.peakCH1(ii).ppm = (hfigure.result.peakCH1(ii).area+hfigure.result.peakCH1(ii).offset)./hfigure.result.peakCH1(ii).factor;
        hfigure.result.peakCH1(ii).uM = hfigure.result.peakCH1(ii).ppm./24.5;
        hfigure.result.peakCH1(ii).umol = hfigure.result.peakCH1(ii).uM.*hfigure.input.headspacevol;
        hfigure.result.peakCH1(ii).umolhr = hfigure.result.peakCH1(ii).umol./hfigure.input.hr;
	end

	for ii = 1:length(hfigure.result.peakCH2)
        hfigure.result.peakCH2(ii).ppm = (hfigure.result.peakCH2(ii).area+hfigure.result.peakCH2(ii).offset)./hfigure.result.peakCH2(ii).factor;
        hfigure.result.peakCH2(ii).uM = hfigure.result.peakCH2(ii).ppm./24.5;
        hfigure.result.peakCH2(ii).umol = hfigure.result.peakCH2(ii).uM.*hfigure.input.headspacevol;
        hfigure.result.peakCH2(ii).umolhr = hfigure.result.peakCH2(ii).umol./hfigure.input.hr;
	end
end
