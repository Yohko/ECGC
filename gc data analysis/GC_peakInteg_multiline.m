%Licence: GNU General Public License version 2 (GPLv2)
function retvals = GC_peakInteg_multiline(datax, datay, start, stop, param, display, hfigure)
    % http://journals.iucr.org/j/issues/1975/01/00/a12580/a12580.pdf

    %param.showplot      % show plot
    %param.maxBGiter     % max BG iterations
    %param.BGpoints      % #points in between
    %param.curvature     % curvature parameter
    %param.BGspacing     % 0.. random spaced, 1 evenly spaced
    %param.subM          % sub M?
    %param.peakcutoff    % criteria to detect detector saturation    
    
    retvals = [0;0;0;0;0;0];
    index = find(datax > start & datax < stop);
    if(isempty(index))
        return;
    end

    XB = datax(index);
    YB = datay(index);
    idx_abovethreshold = find(YB >= param.peakcutoff, 1);
    indexold = index;
    if(isempty(idx_abovethreshold) == 0)
        % delete all points between first and last index
        indexover = find(YB >= param.peakcutoff);
        index = [1:(indexover(1)-1),(indexover(end)+1):length(XB)];
        if(length(index) < 3)
            disp('Error with calculating peak area in ');
            disp(display);
            disp('Signal saturated.');
            return;
        end
        XB = XB(index);
        YB = YB(index);
    end
    
    %% absolute or relative curvature, forward and backward?
    if length(param.curvature) > 1
        if(param.curvature(1)<0)
            curvature(1) = abs(param.curvature(1));
        else
            curvature(1) = abs(YB(end)-YB(1))*param.curvature(1);
        end
        if(param.curvature(2)<0)
            curvature(2) = abs(param.curvature(2));
        else
            curvature(2) = abs(YB(end)-YB(1))*param.curvature(2);
        end
    else
        if(param.curvature<0)
            curvature = abs(param.curvature);
        else
            curvature = abs(YB(end)-YB(1))*param.curvature;
        end
    end

    %% get nodes at which the BG is calculated
    samplepoints = zeros(param.BGpoints+1,1);
    switch param.BGspacing
        %case 0 % random
        case 1
            for i=0:param.BGpoints
                samplepoints(i+1) = 1+round((length(XB)-1)/param.BGpoints*i);
            end
        otherwise % random
            samplepoints(1) = 1;
            samplepoints(2) = length(XB);
            for i=3:param.BGpoints+1
                samplepoints(i) = randi(length(XB));
            end    
    end

    samplepoints=unique(samplepoints,'sorted');
    XBsample = XB(samplepoints);
    YBsample = YB(samplepoints);

    %% calculate BG
    if length(param.curvature) > 1
        % (1) different curvarure values for forward and backward
        YBsamplef = YB(samplepoints);
        YBsampleb = YB(samplepoints);
        for i=1:param.maxBGiter
            %forward
            YBsamplef = my_BGforward(YBsamplef, curvature(1));
            %backward
            YBsampleb = my_BGbackward(YBsampleb, curvature(2));
        end

        [BGlinef, index_onlynoisef, ~, Mf] = my_BGhelper1(XB, YB, XBsample,YBsamplef,param.maxBGiter);
        [BGlineb, index_onlynoiseb, ~, Mb] = my_BGhelper1(XB, YB, XBsample,YBsampleb,param.maxBGiter);
        
        
        % find left BG end (beginning of the index gap)
        idf = find((index_onlynoisef(2:end)-index_onlynoisef(1:end-1))>1,1,'first');
        % find right BG beginning (end of the index gap)
        idb = 1+find((index_onlynoiseb(2:end)-index_onlynoiseb(1:end-1))>1,1,'last');
        
        % if no beginning or end is found set to default values
        if isempty(idf)
            idf = length(index_onlynoisef);
        end
        if isempty(idb)
            idb = 1;
        end
        
        % add let BGline and right BGline together
        % remove duplicate points and interpolate again
        XBtmp = [XB(index_onlynoisef(1:idf));XB(index_onlynoiseb(idb:end))];
        BGlinetmp = [BGlinef(index_onlynoisef(1:idf));BGlineb(index_onlynoiseb(idb:end))];
        [XBtmp, ia, ~] = unique(XBtmp);        
        BGline = interp1(XBtmp,BGlinetmp(ia),XB,'linear','extrap');
        
        
        index_onlynoise = unique([index_onlynoisef(1:idf);index_onlynoiseb(idb:end)]);
        % points which are not noise belong to peaks
        index_onlysignal = setdiff(1:length(BGline), index_onlynoise);

        M = (Mb+Mf)/2;
        if(param.subM)
            BGline = BGline + M;
        end
    else
        % (2) same curvarure value for forward and backward
        for i=1:param.maxBGiter
           %forward
            YBsample = my_BGforward(YBsample, curvature);
            %backward
            YBsample = my_BGbackward(YBsample, curvature);
        end
        
        [BGline, index_onlynoise, ~, M] = my_BGhelper1(XB, YB, XBsample,YBsample,param.maxBGiter);
        
        % points which are not noise belong to peaks
        index_onlysignal = setdiff(1:length(BGline), index_onlynoise);
        
        if(param.subM)
            BGline = BGline + M;
        end

    end


    YBsub = YB-BGline;
    %if(param.subM == 0)
    %    YBsub(YBsub<0) = 0;
    %end
    
    % integrate BG corrected curve to obtain raw peak area
    rawarea = trapz(XB, YBsub);

    %% calculate the final error
    S = std(YBsub(index_onlynoise)); % standard deviation
    M = mean(YBsub(index_onlynoise)); % mean value
    
    %% detect individual peaks
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
            if(centerfound < range_stop && centerfound > range_start)
                display = sprintf('%s center %s range %s %s\n',display,num2str(centerfound),num2str(range_start),num2str(range_stop));
                %index_onlysignal = starti(i):stopi(i);
                retvals(2) = XB(starti(i));
                retvals(3) = XB(stopi(i));
                break;
            end
       end
    end

    %% peak fit if defined in config
    fp_area = -1;
    if (~isempty(param.fit_type))
        try
            switch param.fit_type
                case 'gauss2'
                    fp = fit_Gauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5; % peak area
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                case 'asymgauss2'
                    fp = fit_asymGauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a0; % Todo: include error of fit                    
                    fp_peak = GC_asym_Gauss(XB, fp.a0, fp.a1, fp.a2, fp.a3);
                otherwise
                    disp('Error');
                    return;
            end
        catch
            disp('Error in peak fit in ');
            disp(display);
            fp_area = -1;
        end
    end
    
    %% some points are above saturation threshold
    % do a peak fitting to approximate peak to extrapolate saturated
    % peak
    if(isempty(idx_abovethreshold) == 0)
        % peak is saturated, need to do some peak fitting to 
        % approximate the area 
        % first get some approximate guesses based on Gauss peak profile
        %a1 = % amplitutde
        %b1 = % elution time
        %c1 = % width of gaussian
        try
            %f = fit(x2(idx_abovethreshold),y2(idx_abovethreshold),'gauss1',...
            f = fit(XB, YBsub,'gauss1',...
            'Lower',[0.5*param.peakcutoff, start, 0.01],...
            'Upper',[20*param.peakcutoff, stop, abs(stop-start)]);%,...
            %'StartPoint',[a0 a1 a2]);
        catch
            disp('Error with prelim Gauss fit in ');
            disp(display);
            disp('Probably everything saturated.');
            return;
        end

        % get initial guesses from Gauss
        a0 = f.a1*f.c1*(pi)^.5; % peak area
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
            return;
        end
        area = f2.a0; % Todo: include error of fit
    else
        % no saturation, just integrate over YB-BGline
        if(length(index_onlysignal) > 1)
            % integrate only 'detected peak'
            area = trapz(XB(index_onlysignal), YBsub(index_onlysignal));
            if(3*S*(XB(end)-XB(1))> area) % check if area is above noise level
               area = 0;
            end
        else
            area = 0;
        end
    end
    areaerr = (3*S+M)*(XB(end)-XB(1));

    
    % calculated raw area is smaller then just integrating noise with
    % 99.9% confidence (3x)
    % 97.7% confidence (2x)
    % 84.1% confidence (1x)
    
    if rawarea < 2*S*(XB(end)-XB(1))
        rawarea = 0;
    end
    
    
    %% plot in GUI
    display = sprintf('%s area=%s %s %s', display, num2str(rawarea),char(177),num2str(areaerr));
    if(param.showplot == 1)
        GC_settings_graph;
        f_caption = 10;
        plot(hfigure.ax1,XB,YB, 'linewidth', f_line);
        hold(hfigure.ax1,'on');
        %plot(hfigure.ax1,XB(samplepoints),BGline(samplepoints),'o-', 'linewidth', f_line,'MarkerSize',4);
        plot(hfigure.ax1,XB,BGline,'-', 'linewidth', f_line);
        hold(hfigure.ax1,'off');
        box(hfigure.ax1,'on');
        xlabel(hfigure.ax1,'elution time / min', 'fontsize',f_caption);
        ylabel(hfigure.ax1,'intensity / mV', 'fontsize',f_caption);
        set(hfigure.ax1, 'linewidth', f_line);
        set(hfigure.ax1, 'fontsize', f_caption);
        legend(hfigure.ax1,'Data', 'BG');
        legend(hfigure.ax1,'boxoff');
        if(isempty(idx_abovethreshold) == 0)
            plot(hfigure.ax2,XB,YBsub,'-', 'linewidth', f_line);
            hold(hfigure.ax2,'on');
            plot(hfigure.ax2,datax(indexold),f2(datax(indexold)), 'linewidth', f_line); % Skewed Gaussian
            if(length(index_onlysignal)>2)
                plot(hfigure.ax2,XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black');
                legend(hfigure.ax2,'Data-BG', 'Skewed Gaussian','above noise');
            else
                legend(hfigure.ax2,'Data-BG', 'Skewed Gaussian');
            end
            legend(hfigure.ax2,'boxoff');
            hold(hfigure.ax2,'off');
            box(hfigure.ax2,'on');
        else
            plot(hfigure.ax2,XB,YBsub,'-', 'linewidth', f_line);
            hold(hfigure.ax2,'on');
            if(length(index_onlysignal)>2)
                plot(hfigure.ax2,XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black', 'linewidth', f_line);
                hlegend = legend(hfigure.ax2,'Data-BG','above noise');
            else
                hlegend = legend(hfigure.ax2,'Data-BG');            
            end
            if (~isempty(param.fit_type) && fp_area >= 0)
                plot(hfigure.ax2,XB,fp(XB), 'linewidth', f_line,'DisplayName','cust. model'); % user defined peak model
                plot(hfigure.ax2,XB,fp_peak, 'linewidth', f_line,'DisplayName','prod. peak'); % the peak of interest

            end
            
            legend(hfigure.ax2,'boxoff');
            %patch('Parent',  hlegend, 'FaceColor','y', 'FaceAlpha',0.2);
            set(hlegend,'color','none');
            hold(hfigure.ax2,'off');
            box(hfigure.ax2,'on');
        end
        xlabel(hfigure.ax2,'elution time / min', 'fontsize',f_caption);
        ylabel(hfigure.ax2,'intensity / mV', 'fontsize',f_caption);
        set(hfigure.ax2, 'linewidth', f_line);
        set(hfigure.ax2, 'fontsize', f_caption);
        set(hfigure.figtitle,'Text',display,'fontsize',10);
    end
        
    if(area <= 0) % just in case
       area = 0;
    end
    
    % 1: peak area
    % 2: XB(intl)
    % 3: XB(intr)
    % 4: integrate raw area
    % 5: area from peak fit (if saturated), or from peak above noise
    % 6: peak area error
    if rawarea<0
        rawarea = 0;
    end
    
    % if a peak model was defined in the config file
    % we only use the area for the first peak (as defined in by the
    % centerparam in the config file)
    if (~isempty(param.fit_type))
        fprintf('Using cust. model: ROI = %s, FULL = %s\n',num2str(fp_area),num2str(rawarea));
        rawarea = fp_area;
        area = fp_area;
    end

    
    retvals(1) = rawarea;
    retvals(4) = rawarea;
    retvals(5) = area; 
    retvals(6) = areaerr; % (3*S+M)*(XB(end)-XB(1));
end


function YBsample = my_BGforward(YBsample, curvature)
    for j=2:length(YBsample)-1
        middle = (YBsample(j+1)+YBsample(j-1))/2;
        if((middle+curvature)<YBsample(j))
            YBsample(j) = middle;
        end
    end
end


function YBsample = my_BGbackward(YBsample, curvature)
    for j=2:length(YBsample)-1
        k = length(YBsample)-j+1;
        middle = (YBsample(k+1)+YBsample(k-1))/2;
        if((middle+curvature)<YBsample(k))
            YBsample(k) = middle;
        end
    end
end


function [BGline, index_onlynoise, S, M] = my_BGhelper1(XB, YB, XBsample,YBsample,maxBGiter)
    % interpolate new background to original grid so we can substract it
    BGline = interp1(XBsample,YBsample,XB,'linear','extrap');
    % calculate noise level and reject points based on this
    index_onlynoise = 1:length(BGline);
    YBsub = YB-BGline;
    maxval = max(YBsub);
    factor = 3;
    % cannot always use 3 but need to scale it down if necessary
    if(round(maxval/std(YBsub,1))<=3)
        factor = 1;
    end
    for j=1:(maxBGiter/10)
        S = std(YBsub(index_onlynoise),1); % standard deviation
        M = mean(YBsub(index_onlynoise)); % mean value
        Snew = S;
        for i=1:maxBGiter
            index_onlynoise = find(YBsub <= factor*Snew); % reject all points above M+3*S
            Snew = std(YBsub(index_onlynoise),1); % standard deviation
            if(Snew/S<0.01) % TBD what is the optimal parameter for the change
                break;
            end
        end
        if(i==1)
           break; 
        end
    end
    
    % remove BGline below peak and make it a straight line
    % interpolate new background to original grid so we can substract it
    BGline = interp1(XB(index_onlynoise),BGline(index_onlynoise),XB,'linear','extrap');
end


function fp = fit_Gauss2(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)

    % lower limits
    a1_l = 0; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.01; % width

    a2_l =  0; % height
    b2_l =  param.fit_param(3)-param.fit_param(4); % center
    c2_l = 0.01; % width

    % upper limits
    a1_u = param.peakcutoff; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = abs(stop-start); % width

    a2_u =  param.peakcutoff; % height
    b2_u =  param.fit_param(3)+param.fit_param(4); % center
    c2_u = abs(stop-start); % width

    fpoptions = fitoptions('gauss2', ...
        'Lower', [a1_l b1_l c1_l a2_l b2_l c2_l],...
        'Upper', [a1_u b1_u c1_u a2_u b2_u c2_u]);
    fp = fit(XB, YBsub,'gauss2',fpoptions);
end

function fp = fit_asymGauss2(XB, YBsub, param, start, stop)
    % get initial guesses from Gauss
    fp = fit_Gauss2(XB, YBsub, param, start, stop);
    
    a0 = fp.a1*fp.c1*(pi)^.5; % peak area
    a1 = fp.b1; % elution time
    a2 = fp.c1; % width of gaussian
    a3 = 0.01; % exponential damping term

    b0 = fp.a2*fp.c2*(pi)^.5; % peak area
    b1 = fp.b2; % elution time
    b2 = fp.c2; % width of gaussian
    b3 = 0.01; % exponential damping term

    a0_l = 0; % peak area
    a1_l = a1-0.1*abs(a1-b1); % center
    a2_l = 0.01; % width of gaussian
    a3_l = 0; % exponential damping term
 
    b0_l = 0; % peak area
    b1_l = b1-0.1*abs(a1-b1); % center
    b2_l = 0.01; % width of gaussian
    b3_l = 0; % exponential damping term
 
    a0_u = 2*a0; % peak area
    a1_u = a1+0.1*abs(a1-b1); % center
    a2_u = 2*a2; % width of gaussian
    a3_u = 1; % exponential damping term

    b0_u = 2*b0; % peak area
    b1_u = b1+0.1*abs(a1-b1); % center
    b2_u = 2*b2; % width of gaussian
    b3_u = 1; % exponential damping term

    ft = fittype('GC_asym_Gauss2(x, a0, a1, a2, a3, b0, b1, b2, b3)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower',[a0_l, a1_l, a2_l, a3_l, ...
                     b0_l, b1_l, b2_l, b3_l],...
            'Upper',[a0_u, a1_u, a2_u, a3_u, ...
                     b0_u, b1_u, b2_u, b3_u],...
            'StartPoint',[a0 a1 a2 a3,...
                          b0, b1, b2, b3]);
    catch ME
        disp('Error with Skewed Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end
