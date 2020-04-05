%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_gettimeshift(hfigure)
    datax = hfigure.input.tR;
    datay = hfigure.input.CH1;
    center = hfigure.input.CO2_edge_center;
    start = hfigure.input.CO2_edge_start;    
    % this function tries to search for the HWHM point of the saturated CO2
    % peak to use it as a timing signal
    index = find(datax > start & datax < center);
    maxy = datay(index(end),:);
    tmpx = datax(index);
    shift = zeros(size(datay,2),1);
    for i=1:size(datay,2)
        % peaks are cut off over a certain intensity
        index2 = find(datay(index,i) > (maxy(i)/2) & datay(index,i) < hfigure.input.CO2_cutoff);
        if(isempty(index2))
            hfigure.input.CO2edge(i) = hfigure.input.CO2offset;
            shift(i) = hfigure.input.CO2offset;
        else
            hfigure.input.CO2edge(i) =  tmpx(index2(1))-(tmpx(index2(end))-tmpx(index2(1)));
            shift(i) = tmpx(index2(1));
        end
    end
    hfigure.input.CO2pos = shift;
end
