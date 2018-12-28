%Licence: GNU General Public License version 2 (GPLv2)
function area = GC_peakInteg_linefit(datax, datay, start, stop, param, display)
    % param(1) integration start % not used anymore
    % param(2) integration end % not used anymore
    % param(3) show plot
    % param(4) max BG iterations
    % param(5) approx peak max (used if we have more then one peak but
    % we only consider one
	global GC_usersetting
    eval(GC_usersetting); % load settings

    global input
    if(length(param)<5)
       param(5) = 1E12; % just set to a high number, higher then GC runtime 
    end
    index = find(datax > start & datax < stop);
    XB = datax(index);
    YB = datay(index);
    area2=0;
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
        plot(XB,YB,XB,BGline, 'linewidth', 2);
        hold on;
        plot([XB(intl) XB(intl)], [min(YB) max(YB)],'linewidth', 2);
        plot([XB(intr) XB(intr)], [min(YB) max(YB)],'linewidth', 2);
        hold off;
        title(display);
        legend('Data', 'BG');
    end
    
    if(intl == intr)
       area = 0;
    else
        area = trapz(XB(intl:intr),YBc(intl:intr,1));
    end
    area1 = area;
    x2 = XB(intl:intr);    
    y2 = YBc(intl:intr,1);
    idx1 = find(x2<param(5));
    idx = find(y2(idx1)>CO2_cutoff, 1);
    if(isempty(idx) == 0) % check if the peak saturates
        idx = find(y2<CO2_cutoff);
        f = fit(x2(idx),y2(idx),'gauss1');       
        %a1 = % amplitutde
        %b1 = % elution time
        %c1 = % width of gaussian
        %f = fit(x2(idx),y2(idx),'gauss1',...
        %'Lower',[0, 0.8*a1, 0],...
        %'Upper',[4*a0 1.2*a1 2*a2],...
        %'StartPoint',[a0 a1 a2]);
        % get initial guesses from Gauss fit
        a0= f.a1*f.c1*(pi)^.5; % peak area
        a1 = f.b1; % elution time
        a2 = f.c1; % width of gaussian
        a3 = 0.1; % exponential damping term
        ft = fittype('GC_asym_Gauss(x, a0, a1, a2, a3)');
        f2 = fit( x2(idx),y2(idx), ft,...
            'Lower',[0, 0.8*a1, 0, 0],...
            'Upper',[4*a0 1.2*a1 2*a2 1],...
            'StartPoint',[a0 a1 a2 a3]);
        if(param(3) == 1)
            close(input.h_plotfigure);
            input.h_plotfigure = figure();
            plot(f,x2(idx),y2(idx));
            hold on;
            %plot(x2(idx),GC_asym_Gauss(parguess, x2(idx)));
            plot(x2,f2(x2));
            hold off;
            title(display);
            legend('data', 'Gaussian', 'Skewed Gaussian');
        end
        %area = trapz(x2,f2(x2)); %skewed Gaussian
        area = f2.a0; %skewed Gaussian
        %area = trapz(x2,f(x2)); % Gaussian
        area2 = area;
    end
    if(area <= 0)
       area = 0;
    end
    area = [area; XB(intl); XB(intr); area1; area2];
end
