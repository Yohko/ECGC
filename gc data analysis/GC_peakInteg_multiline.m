%Licence: GNU General Public License version 2 (GPLv2)
function area = GC_peakInteg_multiline(datax, datay, start, stop, param, display)
    % http://journals.iucr.org/j/issues/1975/01/00/a12580/a12580.pdf
    % param(1) integration start % not used anymore
    % param(2) integration end % not used anymore
    % param(3) show plot
    % param(4) max BG iterations
    % param(5) approx peak max (used if we have more then one peak and but)
    % param(6) #points in between
    % param(7) curvature parameter
    % param(8) 0.. random spaced, 1 even spaced

    global GC_usersetting
    eval(GC_usersetting); % load settings

    global input
    index = find(datax > start & datax < stop);
    %index = find((datax > start & datax < stop) & datay>CO2_cutoff);
    XB = datax(index);
    YB = datay(index);
    idx = find(YB>CO2_cutoff, 1);
    indexold = index;
    if(isempty(idx) == 0)
        index = find(YB<CO2_cutoff);
        XB = XB(index);
        YB = YB(index);
    end
	%curvature = 0;
    if(length(YB) < 3)
        disp('Error with calculating peak area in ');
        disp(display);
        disp('Signal saturated.');
        area = [0;0;0;0;0];
        return;
    end
	if(param(7)<0)
        curvature = abs(param(7));
    else
        curvature = abs(YB(end)-YB(1))*param(7);
	end

    switch param(8)
        %case 0 %random
        case 1
            for i=0:param(6)
                samplepoints(i+1) = 1+round((length(XB)-1)/param(6)*i);
            end
        otherwise % random
            samplepoints(1) = 1;
            samplepoints(2) = length(XB);
            for i=3:param(6)+2
                samplepoints(i) = randi(length(XB));
            end    
    end

	samplepoints=unique(samplepoints,'sorted');
    XBsample = XB(samplepoints);
    YBsample = YB(samplepoints);

	for i=1:param(4)
        %forward
        for j=2:length(XBsample)-1
            middle = (YBsample(j+1)+YBsample(j-1))/2;
            if((middle+curvature)<YBsample(j))
                YBsample(j) = middle;
            end
        end
        %backward
        for j=2:length(XBsample)-1
            k = length(XBsample)-j+1;
            middle = (YBsample(k+1)+YBsample(k-1))/2;
            if((middle+curvature)<YBsample(k))
                YBsample(k) = middle;
            end
        end
	end
    
    % interpolate new background to original grid so we can substract it
    BGline = interp1(XBsample,YBsample,XB,'linear','extrap');
       
    % calculate noise level and reject points based on this
    index_onlynoise = 1:length(BGline);
    YBsub = YB-BGline;
    maxval = max(YBsub);
    factor = 3;
    if(round(maxval/std(YBsub,1,'all'))<=3)
        factor = 1;
    end
    for j=1:20
        S = std(YBsub(index_onlynoise),1,'all'); % standard deviation
        M = mean(YBsub(index_onlynoise)); % mean value
        Snew = S;
        for i=1:param(4)
            %index_onlynoise = find(YBsub <= M+3*S); % reject all points above M+3*S
            index_onlynoise = find(YBsub <= factor*Snew); % reject all points above M+3*S
            Snew = std(YBsub(index_onlynoise),1,'all'); % standard deviation
            if(Snew/S<0.01) % TBD what is the optimal parameter for the change
                break;
            end
        end
        if(i==1)
           break; 
        end
    end
    % calculate the final error
    S = std(YBsub(index_onlynoise)); % standard deviation
    M = mean(YBsub(index_onlynoise)); % mean value

    % points which are not noise belong to peaks
    index_onlysignal = 1:length(BGline);
    for i= 1:length(index_onlynoise)
        index_onlysignal = index_onlysignal(find(index_onlynoise(i)~=index_onlysignal));
    end
    index_onlysignaltmp = index_onlysignal;

    % detect individual peaks
    starti(1) = 0;
	stopi(1) = 0;
	peak_count = 0;
    if(length(index_onlysignal)>2) % min three point for a peak
        peak_count = 1;
    	starti(peak_count) = index_onlysignal(1);
        stopi(peak_count) = index_onlysignal(end);
        
        
        for ii = 1:(length(index_onlysignal)-1)
           if((index_onlysignal(ii+1)-1)~=index_onlysignal(ii))               
               if(index_onlysignal(ii)-starti(peak_count) > 2) % min three point for a peak
                   peak_count = peak_count+1;
                   stopi(peak_count-1) = index_onlysignal(ii); % update previous one
                   starti(peak_count) = index_onlysignal(ii+1); % next i as start for next peak
                   stopi(peak_count) = index_onlysignal(end);                   
               else
                   starti(peak_count) = index_onlysignal(ii);
                   stopi(peak_count) = index_onlysignal(end);
               end
               % exclude point
               index_onlysignaltmp = index_onlysignal(i+1:end);
           end
        end
    end
    
    %check if peaks fit into the range expected for the
    %particular molecule, else it might be a different one especially for
    %peaks which are close together (e.g. CO and CH4)
    if(peak_count>0)
        for i=1:peak_count
            factor = 0.2; % 0 .. 0.5
            range_start = start+(stop-start)*factor;
            range_stop = stop-(stop-start)*factor;
            centerfound = XB(starti(i))+(XB(stopi(i))-XB(starti(i)))/2;
            if(centerfound < range_stop & centerfound > range_start)
                display = sprintf('%s center %s range %s %s\n',display,num2str(centerfound),num2str(range_start),num2str(range_stop));
                index_onlysignal = starti(i):stopi(i);
                break;
            end
       end
    end

    if(isempty(idx) == 0)
        % peak is saturated, need to do some peak fitting to 
        % approximate the area 
        % first get some approximate guesses based on Gauss peak profile
        %a1 = % amplitutde
        %b1 = % elution time
        %c1 = % width of gaussian
        try
            %f = fit(x2(idx),y2(idx),'gauss1',...
            f = fit(XB, YBsub,'gauss1',...
            'Lower',[0.5*CO2_cutoff, start, 0.01],...
            'Upper',[20*CO2_cutoff, stop, abs(stop-start)]);%,...
            %'StartPoint',[a0 a1 a2]);
        catch
            disp('Error with prelim Gauss fit in ');
            disp(display);
            disp('Probably everything saturated.');
            area = [0; 0; 0;0;0];
            return;
        end

        % get initial guesses from Gauss
        a0= f.a1*f.c1*(pi)^.5; % peak area
        a1 = f.b1; % elution time
        a2 = f.c1; % width of gaussian
        a3 = 0.1; % exponential damping term
        ft = fittype('GC_asym_Gauss(x, a0, a1, a2, a3)');
        try
            f2 = fit( XB, YBsub, ft,...
                'Lower',[0, 0.8*a1, 0, 0],...
                'Upper',[4*a0 1.2*a1 2*a2 1],...
                'StartPoint',[a0 a1 a2 a3]);
        catch
            disp('Error with Skewed Gauss fit in ');
            disp(display);
            disp('Probably everything saturated.');
            area = [0; 0; 0;0;0];
            return;
        end
        area = f2.a0; % Todo: include error of fit
        %area = trapz(datax(indexold),f2(datax(indexold))); %skewed Gaussian    
    else
        % no saturation, just integrate over YB-BGline
        % area = trapz(XB, YBsub);
        if(length(index_onlysignal) > 1)
            area = trapz(XB(index_onlysignal), YBsub(index_onlysignal));
            if(S*(XB(end)-XB(1))> area) % check if area is above noise level
               area = 0;
            end
        else
            area = 0;
        end
    end
    
    display = sprintf('%s STDev_{noise}=%s; mean_{noise}=%s\narea=%s',display,num2str(S),num2str(M), num2str(area));

	if(param(3) == 1) % plot
        close(input.h_plotfigure);
        input.h_plotfigure = figure();
        subplot(2,1,1);
        plot(XB,YB, 'linewidth', f_line);
        hold on;
        plot(XBsample,YBsample,'o-', 'linewidth', f_line);
        hold off;
        xlabel('elution time / min', 'fontsize',f_caption);
        ylabel('intensity / mV', 'fontsize',f_caption);
        set(gca, 'linewidth', f_line);
        set(gca, 'fontsize', f_caption);
        legend('Data', 'BG');
        legend boxoff;
        if(isempty(idx) == 0)
            subplot(2,1,2);
            plot(XB,YBsub,'-', 'linewidth', f_line);
            hold on;
            plot(datax(indexold),f2(datax(indexold)), 'linewidth', f_line); % Skewed Gaussian
            if(length(index_onlysignal)>2)
                plot(XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black');
                legend('Data-BG', 'Skewed Gaussian','above noise');
            else
                legend('Data-BG', 'Skewed Gaussian');
            end
            legend boxoff;
            hold off;
        else
            subplot(2,1,2);
            plot(XB,YBsub,'-', 'linewidth', f_line);
            hold on;
            if(length(index_onlysignal)>2)
                plot(XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black', 'linewidth', f_line);
                legend('Data-BG','above noise');
            else
                legend('Data-BG');            
            end
            legend boxoff;
            hold off;
        end
        xlabel('elution time / min', 'fontsize',f_caption);
        ylabel('intensity / mV', 'fontsize',f_caption);
        set(gca, 'linewidth', f_line);
        set(gca, 'fontsize', f_caption);
        sgtitle(display)
	end
        
    if(area <= 0) % just in case
       area = 0;
    end
    area1 = area;
    area2 = area;
    area = [area; 0; 0;area1;area2];
end