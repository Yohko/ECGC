%Licence: GNU General Public License version 2 (GPLv2)
% this function tries to search for the HWHM point of the
% ref peak to use it as a timing signal
function hfigure = GC_gettimeshift(hfigure)
    for jj = 1:length(hfigure.input.CH)
        if (hfigure.input.CH(jj).RT_shift == 1)
            hfigure.result.CH(jj).RT_edgepos = zeros(1,length(hfigure.input.CH(jj).spectra));
            center = hfigure.input.CH(jj).RT_edge_center;
            start = hfigure.input.CH(jj).RT_edge_start;
            for ii=1:length(hfigure.input.CH(jj).spectra)
                datax = hfigure.input.CH(jj).spectra(ii).spectrum(:,1);
                datay = hfigure.input.CH(jj).spectra(ii).spectrum(:,2);
                index = find(datax > start & datax < center);
                datax = datax(index);
                datay = datay(index);                
                [maxyval, maxyidx] = max(datay);
                index2 = find(datay(1:maxyidx) > (maxyval/2) & datay(1:maxyidx) < maxyval);
                hfigure.result.CH(jj).RT_edgepos(ii) = datax(index2(1));
            end
        end
    end
end
