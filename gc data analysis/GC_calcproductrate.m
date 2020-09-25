%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_calcproductrate(hfigure)
    CA_flowout = cell2mat(hfigure.result.CAdata(5));
    hfigure.input.flowrate = mean(CA_flowout);
    hfigure.input.hr = hfigure.input.headspacevol/hfigure.input.flowrate/60*1000;
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            hfigure.result.CH(jj).peak(ii).ppm = hfigure.result.CH(jj).peak(ii).area.*hfigure.result.CH(jj).peak(ii).factor+hfigure.result.CH(jj).peak(ii).offset;
            hfigure.result.CH(jj).peak(ii).uM = hfigure.result.CH(jj).peak(ii).ppm./24.5;
            hfigure.result.CH(jj).peak(ii).umol = hfigure.result.CH(jj).peak(ii).uM.*hfigure.input.headspacevol;
            hfigure.result.CH(jj).peak(ii).umolhr = hfigure.result.CH(jj).peak(ii).umol./hfigure.input.hr;
        end
	end
end
