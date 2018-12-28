%Licence: GNU General Public License version 2 (GPLv2)
function area = GC_peakInteg_line(datax, datay, start, stop, param, display)
    % param(1) integration start % not used anymore
    % param(2) integration end % not used anymore
    % param(3) show plot
    % param(4) max BG iterations

    global input
    index = find(datax > start & datax < stop);
    XB = datax(index);
    YB = datay(index);
    
    slope = (YB(1)-YB(end))/(XB(1)-XB(end));
    offset = YB(1)-slope*XB(1);
    BGline = XB*slope+offset;  
    YBc = YB-BGline;
    middle = round(size(YB,1)/2);
    
    intl = 1;
    intr = size(XB,1);
    
    for k=4:param(4)
        intlo = intl;
        intro = intr;
        lefti = find(YBc(1:middle) <= 0);
        righti = find(YBc(middle:end) <= 0);
        [~, I] = min(YBc(lefti));
        pminl = lefti(I);
        [~, I] = min(YBc(middle-1+righti));
        pminr = middle-1+righti(I);
        if(size(pminr,1) == 0)
           pminr = intro;
        elseif(size(pminl,1) == 0)
           pminl = intlo;
        end
        slope = (YBc(pminl)-YBc(pminr))/(XB(pminl)-XB(pminr));
        offset = YBc(pminl)-slope*XB(pminl);
        if(slope == 0 & offset == 0)
            break
        elseif(size(slope,1) == 0)
           break
        elseif(size(offset,1) == 0)
            break
        end
        intl = pminl;
        intr = pminr;
        BGline = BGline+XB*slope+offset;  
        YBc = YB-BGline;
    end
    if(param(3) == 1) % plot
        close(input.h_plotfigure);
        input.h_plotfigure = figure();
        plot(XB,YB,XB,BGline);
        hold on;
        plot([XB(intl) XB(intl)], [min(YB) max(YB)]);
        plot([XB(intr) XB(intr)], [min(YB) max(YB)]);
        hold off;
        title(display);
        legend('Data', 'BG');
    end
    
    if(intl == intr)
       area = 0;
    else
        area = trapz(XB(intl:intr),YBc(intl:intr,1));
    end
    if(area <= 0)
       area = 0;
    end
    area = [area; XB(intl); XB(intr)];
end
