%Licence: GNU General Public License version 2 (GPLv2)
function [ret_area, ret_error] = GC_peak_integrate(datax, datay, start, stop, param, display, hfigure)
    % http://journals.iucr.org/j/issues/1975/01/00/a12580/a12580.pdf

    %param.showplot      % show plot
    %param.maxBGiter     % max BG iterations
    %param.BGpoints      % #points in between
    %param.curvature     % curvature parameter
    %param.BGspacing     % 0.. random spaced, 1 evenly spaced
    %param.subM          % sub M?
    %param.peakcutoff    % criteria to detect detector saturation    
    %param.fit_low_criterion % decide when doing peak fits
    
    % default return values
    ret_area = 0;
	ret_error = 0;

    index = find(datax > start & datax < stop);
    if(isempty(index))
        return;
    end
    display_org = display;
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

    %% calculate BG    
    if length(param.curvature) > 1
        % (1) different curvarure values for forward and backward
        YBsamplef = get_avYBsample(YB, samplepoints, param.av_width);
        YBsampleb = get_avYBsample(YB, samplepoints, param.av_width);
%        YBsamplef = YB(samplepoints);
%        YBsampleb = YB(samplepoints);
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

        error_M = (Mb+Mf)/2;
        if(param.subM)
            BGline = BGline + error_M;
        end
    else
        % (2) same curvarure value for forward and backward
        %YBsample = YB(samplepoints);
        YBsample = get_avYBsample(YB, samplepoints, param.av_width);
        for i=1:param.maxBGiter
           %forward
            YBsample = my_BGforward(YBsample, curvature);
            %backward
            YBsample = my_BGbackward(YBsample, curvature);
        end
        
        [BGline, index_onlynoise, ~, error_M] = my_BGhelper1(XB, YB, XBsample,YBsample,param.maxBGiter);
        
        % points which are not noise belong to peaks
        index_onlysignal = setdiff(1:length(BGline), index_onlynoise);
        
        if(param.subM)
            BGline = BGline + error_M;
        end

    end

    %% substract BG
    YBsub = YB-BGline;

    %% calculate the final error
    error_S = std(YBsub(index_onlynoise)); % standard deviation
    error_M = mean(YBsub(index_onlynoise)); % mean value
    
    %% integrate BG corrected curve to obtain raw peak area
    raw_area = trapz(XB, YBsub);
    % calculated raw area is smaller then just integrating noise with
    % 99.7% confidence (3x)
    % 95% confidence (2x)
    % 68% confidence (1x)
    raw_error = (error_S)*(XB(end)-XB(1));

    
    %% detect individual peaks
    starti(1) = 0;
    stopi(1) = 0;
    peak_count = 0;
    if(length(index_onlysignal)>2) % min three points for a peak
        peak_count = 1;
        starti(peak_count) = index_onlysignal(1);
        stopi(peak_count) = index_onlysignal(end);
        for ii = 1:(length(index_onlysignal)-1)
           if((index_onlysignal(ii+1)-1)~=index_onlysignal(ii))               
               if(index_onlysignal(ii)-starti(peak_count) > 2) % min three points for a peak
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
                break;
            end
       end
    end

    %% peak fit if defined in config
    fp_area = 0;
    fp_error = 0;
    do_fit = 0;
    fp_center = 0;
    fp_fwhm = 0;
    area_criterion = param.fit_low_criterion*error_S*(XB(end)-XB(1));
    testfactor = raw_area/(error_S*(XB(end)-XB(1)));
    if ~isempty(param.fit_type)
        fprintf('%s - factor=%s\n',display_org,num2str(testfactor));
    end
    
    if (~isempty(param.fit_type) && raw_area < area_criterion)
        do_fit = 1;
        try
            switch param.fit_type
                % width for Gauss distribution (FWHM)
                % 99.9% confidence (3x)
                % 97.7% confidence (2x)
                % 84.1% confidence (1x)
                case 'offset_gauss1'
                    fp = fit_offsetGauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'linoffset_gauss1'
                    fp = fit_linoffsetGauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'gauss1'
                    fp = fit_Gauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'gauss2'
                    fp = fit_Gauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'offset_gauss2'
                    fp = fit_offsetGauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'linoffset_gauss2'
                    fp = fit_linoffsetGauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a1*fp.c1*(pi)^.5;
                    fp_peak = fp.a1.*exp(-((XB-fp.b1)./fp.c1).^2);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.c1);
                    fp_center = fp.b1;
                    fp_fwhm = fp.c1;
                case 'offset_asymgauss1'
                    fp = fit_offsetasymGauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a0;
                    fp_peak = GC_asym_Gauss(XB, fp.a0, fp.a1, fp.a2, fp.a3);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.a2);
                    fp_center = fp.a1;
                    fp_fwhm = fp.a2;
                case 'linoffset_asymgauss1'
                    fp = fit_linoffsetasymGauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a0;
                    fp_peak = GC_asym_Gauss(XB, fp.a0, fp.a1, fp.a2, fp.a3);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.a2);
                    fp_center = fp.a1;
                    fp_fwhm = fp.a2;
                case 'asymgauss1'
                    fp = fit_asymGauss1(XB, YBsub, param, start, stop);
                    fp_area = fp.a0;
                    fp_peak = GC_asym_Gauss(XB, fp.a0, fp.a1, fp.a2, fp.a3);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.a2);
                    fp_center = fp.a1;
                    fp_fwhm = fp.a2;
                case 'asymgauss2'
                    fp = fit_asymGauss2(XB, YBsub, param, start, stop);
                    fp_area = fp.a0;
                    fp_peak = GC_asym_Gauss(XB, fp.a0, fp.a1, fp.a2, fp.a3);
                    error_S_fp = std(YBsub-fp(XB));
                    fp_error = (error_S_fp)*(3*fp.a2);
                    fp_center = fp.a1;
                    fp_fwhm = fp.a2;
                otherwise
                    disp('Error');
                    return;
            end
        catch ME
%            disp(ME)
            disp('Error in peak fit in ');
            disp(display);
        end
    end
    
    %% some points are above saturation threshold
    % do a peak fitting to approximate peak to extrapolate saturated
    % peak
    sat_area = 0;
    sat_error = 0;
    if(isempty(idx_abovethreshold) == 0)
        % peak is saturated, need to do some peak fitting to 
        % approximate the area 
        % first get some approximate guesses based on Gauss peak profile
        %a1 = % amplitutde
        %b1 = % retention time
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
        a1 = f.b1; % retention time
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
        sat_area = f2.a0;
        error_S_fp = std(YBsub-f2(XB));
        sat_error = (error_S_fp)*(3*f2.a2);
    end


%% decide on area and error
    if (~isempty(param.fit_type) && do_fit == 1)
        fprintf('%s - Using cust. model: ROI = %s%s%s, FULL = %s%s%s with center = %s, width = %s\n',display_org,num2str(fp_area),char(177),num2str(fp_error),num2str(raw_area),char(177),num2str(raw_error), num2str(fp_center),num2str(fp_fwhm));
        ret_area = fp_area;
        ret_error = fp_error;
    elseif (isempty(idx_abovethreshold) == 0)
        fprintf('%s - sat. peak model: ROI = %s, FULL = %s\n',display_org,num2str(sat_area),num2str(raw_area));
        ret_area = sat_area;
        ret_error = sat_error;
    else
        ret_area = raw_area;
        ret_error = raw_error;
        % cutoff criterion
        if ret_area < (error_M+error_S)*(XB(end)-XB(1))
           ret_area = 0;
        end
    end
    
    if ret_area<0
        ret_area = 0;
    end


    %% plot in GUI
    display = sprintf('%s area=%s %s %s', display, num2str(ret_area),char(177),num2str(ret_error));
    if(param.showplot == 1)
        GC_settings_graph;
        f_caption = 10;
        plot(hfigure.ax1,XB,YB, 'linewidth', f_line);
        hold(hfigure.ax1,'on');
        plot(hfigure.ax1,XB(samplepoints),BGline(samplepoints),'o-', 'linewidth', f_line,'MarkerSize',4);
        %plot(hfigure.ax1,XB,BGline,'-', 'linewidth', f_line);
        hold(hfigure.ax1,'off');
        box(hfigure.ax1,'on');
        xlabel(hfigure.ax1,'retention time / min', 'fontsize',f_caption);
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
            if (~isempty(param.fit_type) && fp_area > 0)
                plot(hfigure.ax2,XB,fp(XB), 'linewidth', f_line,'DisplayName','cust. model'); % user defined peak model
                plot(hfigure.ax2,XB,fp_peak, 'linewidth', f_line,'DisplayName','prod. peak'); % the peak of interest

            end
            
            legend(hfigure.ax2,'boxoff');
            %patch('Parent',  hlegend, 'FaceColor','y', 'FaceAlpha',0.2);
            set(hlegend,'color','none');
            hold(hfigure.ax2,'off');
            box(hfigure.ax2,'on');
        end
        xlabel(hfigure.ax2,'retention time / min', 'fontsize',f_caption);
        ylabel(hfigure.ax2,'intensity / mV', 'fontsize',f_caption);
        set(hfigure.ax2, 'linewidth', f_line);
        set(hfigure.ax2, 'fontsize', f_caption);
        set(hfigure.figtitle,'Text',display,'fontsize',10);

        x_width = XB(end)-XB(1);
        xlim(hfigure.ax1,[XB(1)-0.05*x_width XB(end)+0.05*x_width])
        xlim(hfigure.ax2,[XB(1)-0.05*x_width XB(end)+0.05*x_width])

        maxY = max(YB);
        minY = min(YB);
        y_width = maxY-minY;
        ylim(hfigure.ax1,[minY-0.1*y_width maxY+0.1*y_width])

        maxY = max(YBsub);
        minY = min(YBsub);
        y_width = maxY-minY;
        ylim(hfigure.ax2,[minY-0.1*y_width maxY+0.1*y_width])

    end

end

%%
function YBsample = get_avYBsample(YB, samplepoints, av_width)
    av_width = round(av_width);
    if av_width > 0
        lenYB = length(YB);
        YBsample = zeros(size(YB(samplepoints)));
        counts = zeros(size(YB(samplepoints)));
        for ii=1:length(samplepoints)
            for jj=-av_width:av_width
                if ((samplepoints(ii)+jj)) >= 1 && ((samplepoints(ii)+jj)) <= lenYB
                    counts(ii) = counts(ii) + 1;
                    YBsample(ii) = YBsample(ii) + YB(samplepoints(ii)+jj);
                end
            end
        end
        YBsample = YBsample./counts;
    else % default
        YBsample = YB(samplepoints);
    end    
end

%%
function YBsample = my_BGforward(YBsample, curvature)
    for j=2:length(YBsample)-1
        middle = (YBsample(j+1)+YBsample(j-1))/2;
        if((middle+curvature)<YBsample(j))
            YBsample(j) = middle;
        end
    end
end

%%
function YBsample = my_BGbackward(YBsample, curvature)
    for j=2:length(YBsample)-1
        k = length(YBsample)-j+1;
        middle = (YBsample(k+1)+YBsample(k-1))/2;
        if((middle+curvature)<YBsample(k))
            YBsample(k) = middle;
        end
    end
end

%%
function [BGline, index_onlynoise, error_S, error_M] = my_BGhelper1(XB, YB, XBsample,YBsample,maxBGiter)
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
        error_S = std(YBsub(index_onlynoise),1); % standard deviation
        error_M = mean(YBsub(index_onlynoise)); % mean value
        error_Snew = error_S;
        for i=1:maxBGiter
            index_onlynoise = find(YBsub <= factor*error_Snew); % reject all points above M+3*S
            error_Snew = std(YBsub(index_onlynoise),1); % standard deviation
            if(error_Snew/error_S<0.01) % TBD what is the optimal parameter for the change
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

%%
function fp = fit_offsetGauss1(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    minh = min(YBsub);
    
    % lower limits
    a1_l = 0.5*maxh; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.01; % width

    % upper limits
    a1_u = 2*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    
    try
        myfittype = fittype('d1+a1*exp(-((x-b1)/c1)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1', 'd1'});

        [val, idx] = max(YBsub);
        a1_s = val;
        b1_s = XB(idx);
        c1_s = param.fit_param(2);
        
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [a1_s b1_s c1_s 0],...
            'Lower', [a1_l b1_l c1_l minh],...
            'Upper', [a1_u b1_u c1_u maxh]...
            );
    catch ME
        disp('Error with offset Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end

%%
function fp = fit_linoffsetGauss1(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    minh = min(YBsub);
    
    % lower limits
    a1_l = 0.5*maxh; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.01; % width

    % upper limits
    a1_u = 2*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    
    try
        myfittype = fittype('d1+e1*x+a1*exp(-((x-b1)/c1)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1', 'd1', 'e1'});

        [val, idx] = max(YBsub);
        a1_s = val;
        b1_s = XB(idx);
        c1_s = param.fit_param(2);
        
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [a1_s b1_s c1_s 0 0],...
            'Lower', [a1_l b1_l c1_l minh -Inf],...
            'Upper', [a1_u b1_u c1_u maxh +Inf]...
            );
    catch ME
        disp('Error with offset Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end


%%
function fp = fit_Gauss1(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    % lower limits
    a1_l = 0; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.001; % width

    % upper limits
    a1_u = 4*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    fpoptions = fitoptions('gauss1', ...
        'Lower', [a1_l b1_l c1_l],...
        'Upper', [a1_u b1_u c1_u]);
    fp = fit(XB, YBsub,'gauss1',fpoptions);
end

%%
function fp = fit_Gauss2(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    % lower limits
    a1_l = 0; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.001; % width

    a2_l =  0; % height
    b2_l =  param.fit_param(3)-param.fit_param(4); % center
    c2_l = 0.001; % width

    % upper limits
    a1_u = 4*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    a2_u =  4*maxh; % height
    b2_u =  param.fit_param(3)+param.fit_param(4); % center
    c2_u = 2*param.fit_param(4); % width

    fpoptions = fitoptions('gauss2', ...
        'Lower', [a1_l b1_l c1_l a2_l b2_l c2_l],...
        'Upper', [a1_u b1_u c1_u a2_u b2_u c2_u]);
    fp = fit(XB, YBsub,'gauss2',fpoptions);
end

%%
function fp = fit_offsetGauss2(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    minh = min(YBsub);
    maxh = max(YBsub);
    % lower limits
    a1_l = 0; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.001; % width

    a2_l =  0; % height
    b2_l =  param.fit_param(3)-param.fit_param(4); % center
    c2_l = 0.001; % width

    % upper limits
    a1_u = 4*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    a2_u =  4*maxh; % height
    b2_u =  param.fit_param(3)+param.fit_param(4); % center
    c2_u = 2*param.fit_param(4); % width
    try
        myfittype = fittype('d1+a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1','a2','b2','c2', 'd1'});

        [val, idx] = max(YBsub);
        a1_s = val;
        b1_s = param.fit_param(1);
        c1_s = param.fit_param(2);

        a2_s = val;
        b2_s = param.fit_param(3);
        c2_s = param.fit_param(4);

        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [a1_s b1_s c1_s a2_s b2_s c2_s 0],...
            'Lower', [a1_l b1_l c1_l a2_l b2_l c2_l minh],...
            'Upper', [a1_u b1_u c1_u a2_u b2_u c2_u maxh]...
            );
    catch ME
        disp('Error with offset Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end


%%
function fp = fit_linoffsetGauss2(XB, YBsub, param, start, stop)
    % params for gauss are
    % height(a), center (b), width (c)
    minh = min(YBsub);
    maxh = max(YBsub);
    % lower limits
    a1_l = 0; % height
    b1_l = param.fit_param(1)-param.fit_param(2); % center
    c1_l = 0.001; % width

    a2_l =  0; % height
    b2_l =  param.fit_param(3)-param.fit_param(4); % center
    c2_l = 0.001; % width

    % upper limits
    a1_u = 4*maxh; % height
    b1_u = param.fit_param(1)+param.fit_param(2); % center
    c1_u = 2*param.fit_param(2); % width

    a2_u =  4*maxh; % height
    b2_u =  param.fit_param(3)+param.fit_param(4); % center
    c2_u = 2*param.fit_param(4); % width
    try
        myfittype = fittype('d1+e1*x+a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1','a2','b2','c2', 'd1','e1'});

        [val, idx] = max(YBsub);
        a1_s = val;
        b1_s = param.fit_param(1);
        c1_s = param.fit_param(2);

        a2_s = val;
        b2_s = param.fit_param(3);
        c2_s = param.fit_param(4);

        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [a1_s b1_s c1_s a2_s b2_s c2_s 0 0],...
            'Lower', [a1_l b1_l c1_l a2_l b2_l c2_l minh -Inf],...
            'Upper', [a1_u b1_u c1_u a2_u b2_u c2_u maxh +Inf]...
            );
    catch ME
        disp('Error with offset Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end

%%
function fp = fit_offsetasymGauss1(XB, YBsub, param, start, stop)
    % get initial guesses from Gauss
    fp = fit_offsetGauss1(XB, YBsub, param, start, stop);
    area = fp.a1*fp.c1*(pi)^.5;
    maxh = max(YBsub);
    minh = min(YBsub);

    a0 = area; % peak area
    a1 = fp.b1; % retention time
    a2 = fp.c1; % width of gaussian
    a3 = 0.01; % exponential damping term
    offset = fp.d1;

    a0_l = 0.5*area; % peak area
    a1_l = a1-a2; % center
    a2_l = 0.5*a2; % width of gaussian
    a3_l = 0.0; % exponential damping term

    a0_u = 2*area; % peak area
    a1_u = a1+a2; % center
    a2_u = 2*a2; % width of gaussian
    a3_u = 0.5; % exponential damping term
    
    [val, ~] = max(YBsub);
    ft = fittype('GC_offset_asym_Gauss(x, a0, a1, a2, a3, offset)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower',[a0_l, a1_l, a2_l, a3_l, minh],...
            'Upper',[a0_u, a1_u, a2_u, a3_u, maxh],...
            'StartPoint',[a0 a1 a2 a3 offset]);
    catch ME
        disp('Error with Skewed Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end

%%
function fp = fit_linoffsetasymGauss1(XB, YBsub, param, start, stop)
    % get initial guesses from Gauss
    fp = fit_linoffsetGauss1(XB, YBsub, param, start, stop);
    area = fp.a1*fp.c1*(pi)^.5;
    maxh = max(YBsub);
    minh = min(YBsub);

    a0 = area; % peak area
    a1 = fp.b1; % retention time
    a2 = fp.c1; % width of gaussian
    a3 = 0.01; % exponential damping term
    offset = fp.d1;
    slope = fp.e1;

    a0_l = 0.5*area; % peak area
    a1_l = a1-a2; % center
    a2_l = 0.5*a2; % width of gaussian
    a3_l = 0.0; % exponential damping term

    a0_u = 2*area; % peak area
    a1_u = a1+a2; % center
    a2_u = 2*a2; % width of gaussian
    a3_u = 0.5; % exponential damping term
    
    [val, ~] = max(YBsub);
    ft = fittype('GC_linoffset_asym_Gauss(x, a0, a1, a2, a3, offset, slope)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower',[a0_l, a1_l, a2_l, a3_l, minh -Inf],...
            'Upper',[a0_u, a1_u, a2_u, a3_u, maxh +Inf],...
            'StartPoint',[a0 a1 a2 a3 offset slope]);
    catch ME
        disp('Error with Skewed Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end


%%



function fp = fit_asymGauss1(XB, YBsub, param, start, stop)
    % get initial guesses from Gauss
    fp = fit_Gauss(XB, YBsub, param, start, stop);
    area = fp.a1*fp.c1*(pi)^.5;

    a0 = fp.a1*fp.c1*(pi)^.5; % peak area
    a1 = fp.b1; % retention time
    a2 = fp.c1; % width of gaussian
    a3 = 0.01; % exponential damping term

    a0_l = 0.5*area; % peak area
    a1_l = a1-a2; % center
    a2_l = 0.5*a2; % width of gaussian
    a3_l = 0; % exponential damping term

    a0_u = 2*a0; % peak area
    a1_u = a1+a2; % center
    a2_u = 2*a2; % width of gaussian
    a3_u = 0.5; % exponential damping term


    ft = fittype('GC_asym_Gauss(x, a0, a1, a2, a3)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower',[a0_l, a1_l, a2_l, a3_l],...
            'Upper',[a0_u, a1_u, a2_u, a3_u],...
            'StartPoint',[a0 a1 a2 a3]);
    catch ME
        disp('Error with Skewed Gauss fit in ');
        disp(ME);
        rethrow(ME);
    end
end


%%
function fp = fit_asymGauss2(XB, YBsub, param, start, stop)
    % get initial guesses from Gauss
    fp = fit_Gauss2(XB, YBsub, param, start, stop);
    
    a0 = fp.a1*fp.c1*(pi)^.5; % peak area
    a1 = fp.b1; % retention time
    a2 = fp.c1; % width of gaussian
    a3 = 0.01; % exponential damping term

    b0 = fp.a2*fp.c2*(pi)^.5; % peak area
    b1 = fp.b2; % retention time
    b2 = fp.c2; % width of gaussian
    b3 = 0.01; % exponential damping term

    a0_l = 0; % peak area
    a1_l = a1-a2; % center
    a2_l = 0.5*a2; % width of gaussian
    a3_l = 0; % exponential damping term
 
    b0_l = 0; % peak area
    b1_l = b1-b2; % center
    b2_l = 0.5*b2; % width of gaussian
    b3_l = 0; % exponential damping term
 
    a0_u = 2*a0; % peak area
    a1_u = a1+a2; % center
    a2_u = 2*a2; % width of gaussian
    a3_u = 1; % exponential damping term

    b0_u = 2*b0; % peak area
    b1_u = b1+b2; % center
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
