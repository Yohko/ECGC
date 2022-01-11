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

    param.f_wminG = 0.8;
    param.f_wmaxG = 1.2;

    param.f_wminasymG = 0.8;
    param.f_wmaxasymG = 1.2;

    param.f_expdtmin = 1E-3; % cannot be zero
    param.f_expdtmax = 0.04;

    param.f_slopemin = 0.9;
    param.f_slopemax = 1.1;

    param.f_offsetmin = 0.9;
    param.f_offsetmax = 1.1;

    
    % param.intermethod = 'linear';
    param.intermethod = 'spline';

    index = find(datax > start & datax < stop);
    if(isempty(index))
        return;
    end
    param.display_org = display;
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
        for i=1:param.maxBGiter
            %forward
            YBsamplef = my_BGforward(YBsamplef, curvature(1));
            %backward
            YBsampleb = my_BGbackward(YBsampleb, curvature(2));
        end

        [BGlinef, index_onlynoisef, ~, Mf] = my_BGhelper1(XB, YB, XBsample,YBsamplef,param.maxBGiter, param);
        [BGlineb, index_onlynoiseb, ~, Mb] = my_BGhelper1(XB, YB, XBsample,YBsampleb,param.maxBGiter, param);
        
        
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
        BGline = interp1(XBtmp,BGlinetmp(ia),XB,param.intermethod,'extrap');
        
        
        index_onlynoise = unique([index_onlynoisef(1:idf);index_onlynoiseb(idb:end)]);
        % points which are not noise belong to peaks
        index_onlysignal = setdiff(1:length(BGline), index_onlynoise);

        error_M = (Mb+Mf)/2;
        if(param.subM)
            BGline = BGline + error_M;
        end
    else
        % (2) same curvarure value for forward and backward
        YBsample = get_avYBsample(YB, samplepoints, param.av_width);
        for i=1:param.maxBGiter
           %forward
            YBsample = my_BGforward(YBsample, curvature);
            %backward
            YBsample = my_BGbackward(YBsample, curvature);
        end
        
        [BGline, index_onlynoise, ~, error_M] = my_BGhelper1(XB, YB, XBsample,YBsample,param.maxBGiter, param);
        
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

    
    %% plot in GUI 1
    %display = sprintf('%s area=%s %s %s', display, num2str(ret_area),char(177),num2str(ret_error));
    if(param.showplot == 1)
        GC_settings_graph;
        f_caption = 10;
        h0 = plot(hfigure.ax1,XB,YB, 'linewidth', f_line, 'color', 'black');
        hold(hfigure.ax1,'on');
        h1 = plot(hfigure.ax1,XB,BGline,'-', 'linewidth', f_line, 'color', [0 0.4470 0.7410]);
        plot(hfigure.ax1,XB(samplepoints),BGline(samplepoints),'o', 'linewidth', f_line,'MarkerSize',4, 'Color', get(h1, 'Color'));
        %plot(hfigure.ax1,XB,BGline,'-', 'linewidth', f_line);
        hold(hfigure.ax1,'off');
        box(hfigure.ax1,'on');
        xlabel(hfigure.ax1,'retention time / min', 'fontsize',f_caption);
        ylabel(hfigure.ax1,'intensity / mV', 'fontsize',f_caption);
        set(hfigure.ax1, 'linewidth', f_line);
        set(hfigure.ax1, 'fontsize', f_caption);
        legend(hfigure.ax1,[h0, h1], {'Data', 'BG'});
        legend(hfigure.ax1,'boxoff');

        x_width = XB(end)-XB(1);
        xlim(hfigure.ax1,[XB(1)-0.05*x_width XB(end)+0.05*x_width])

        maxY = max(YB);
        minY = min(YB);
        y_width = maxY-minY;
        ylim(hfigure.ax1,[minY-0.1*y_width maxY+0.1*y_width])

    end    
    
    
    %% peak fit if defined in config
    fp_area = 0;
    fp_error = 0;
    do_fit = 0;
    fp_center = 0;
    fp_fwhm = 0;
    area_criterion = param.fit_low_criterion.*error_S*(XB(end)-XB(1));
    testfactor = raw_area/(error_S*(XB(end)-XB(1)));
    if ~isempty(param.fit_type)
        fprintf('%s - factor=%s\n',param.display_org,num2str(testfactor));
    end
    
    if (~isempty(param.fit_type)) % && raw_area < area_criterion)
        fit_type = param.fit_type;
        new_area_criterion = inf;
        if length(fit_type) > 1 %isstring(fit_type)
            if length(fit_type) == length(area_criterion)
                
                for i = 1:length(param.fit_type)
                    if raw_area < area_criterion(i) && new_area_criterion >= area_criterion(i)
                        fit_type = param.fit_type(i);
                        new_area_criterion = area_criterion(i);
                            
                    end
                end
            end
        else
            new_area_criterion = area_criterion;
        end
        if raw_area < new_area_criterion


            do_fit = 1;
            try
                switch fit_type
                    % width for Gauss distribution (FWHM)
                    % 99.9% confidence (3x)
                    % 97.7% confidence (2x)
                    % 84.1% confidence (1x)
                    case 'offset_gauss1'
                        ret = fit_offsetGauss1(XB, YBsub, param);
                    case 'linoffset_gauss1'
                        ret = fit_linoffsetGauss1(XB, YBsub, param);
                    case 'gauss1'
                        ret = fit_Gauss1(XB, YBsub, param);
                    case 'gauss2'
                        ret = fit_Gauss2(XB, YBsub, param);
                    case 'offset_gauss2'
                        ret = fit_offsetGauss2(XB, YBsub, param);
                    case 'linoffset_gauss2'
                        ret = fit_linoffsetGauss2(XB, YBsub, param);
                    case 'linoffset_asymgauss2'
                        ret = fit_linoffsetasymGauss2(XB, YBsub, param);
                    case 'linoffset_coupled_gauss2'
                        ret = fit_linoffsetcoupledGauss2(XB, YBsub, param);
                    case 'linoffset_coupled_asymgauss2'
                        ret = fit_linoffsetcoupledasymGauss2(XB, YBsub, param);
                    case 'offset_asymgauss1'
                        ret = fit_offsetasymGauss1(XB, YBsub, param);
                    case 'linoffset_asymgauss1'
                        ret = fit_linoffsetasymGauss1(XB, YBsub, param);
                    case 'asymgauss1'
                        ret = fit_asymGauss1(XB, YBsub, param);
                    case 'asymgauss2'
                        ret = fit_asymGauss2(XB, YBsub, param);
                    otherwise
                        error('Unknown Peak type');
                end

                fp = ret.fp;
                fp_area = ret.fp_area(param.sel_peak);
                fp_peak = ret.fp_peak(:,param.sel_peak);
                fp_error = ret.fp_error(param.sel_peak);
                fp_center = ret.fp_center(param.sel_peak);
                fp_fwhm = ret.fp_fwhm(param.sel_peak);



            catch ME
                disp(ME)
                error(ME.message);
            end
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
        catch ME
            disp(ME)
            error('Error with prelim Gauss fit for sat. peak.');
        end

        % get initial guesses from Gauss
        a0 = f.a1*f.c1*(pi)^.5; % peak area
        a1 = f.b1; % retention time
        a2 = f.c1; % width of gaussian
        a3 = 0.01; % exponential damping term
        ft = fittype('GC_asym_Gauss(x, a0, a1, a2, a3)');
        try
            f2 = fit( XB, YBsub, ft,...
                'Lower',[0, 0.8*a1, 0, 0],...
                'Upper',[4*a0 1.2*a1 2*a2 1],...
                'StartPoint',[a0 a1 a2 a3]);
        catch ME
            disp(ME)
            error('Error with Skewed Gauss fit');
        end
        sat_area = f2.a0;
        error_S_fp = std(YBsub-f2(XB));
        sat_error = (error_S_fp)*(3*f2.a2);
    end


%% decide on area and error
    if (~isempty(param.fit_type) && do_fit == 1)
        fprintf('%s - Using cust. model: ROI = %s%s%s, FULL = %s%s%s with center = %s, hwhm = %s\n',param.display_org,num2str(fp_area),char(177),num2str(fp_error),num2str(raw_area),char(177),num2str(raw_error), num2str(fp_center),num2str(fp_fwhm));
        ret_area = fp_area;
        ret_error = fp_error;
    elseif (isempty(idx_abovethreshold) == 0)
        fprintf('%s - sat. peak model: ROI = %s, FULL = %s\n',param.display_org,num2str(sat_area),num2str(raw_area));
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


    %% plot in GUI 2 - after fit
    display = sprintf('%s area=%s %s %s', display, num2str(ret_area),char(177),num2str(ret_error));
    if(param.showplot == 1)
        GC_settings_graph;
        f_caption = 10;
        if(isempty(idx_abovethreshold) == 0)
            plot(hfigure.ax2,XB,YBsub,'-', 'linewidth', f_line, 'color', 'black');
            hold(hfigure.ax2,'on');
            plot(hfigure.ax2,datax(indexold),f2(datax(indexold)), 'linewidth', f_line, 'color', [0 0.4470 0.7410]); % Skewed Gaussian
%            if(length(index_onlysignal)>2)
%                plot(hfigure.ax2,XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black');
%                legend(hfigure.ax2,'Data-BG', 'Skewed Gaussian','above noise');
%            else
            legend(hfigure.ax2,'Data-BG', 'Skewed Gaussian');
%            end
            legend(hfigure.ax2,'boxoff');
            hold(hfigure.ax2,'off');
            box(hfigure.ax2,'on');
        else
            plot(hfigure.ax2,XB,YBsub,'-', 'linewidth', f_line, 'color', 'black');
            hold(hfigure.ax2,'on');
%            if(length(index_onlysignal)>2)
%                plot(hfigure.ax2,XB(index_onlysignal),YBsub(index_onlysignal),'o', 'color', 'black', 'linewidth', f_line,'DisplayName','above noise');
%                hlegend = legend(hfigure.ax2,'Data-BG','above noise');
%            else
            legendstr = {'Data-BG'};
            %hlegend = legend(hfigure.ax2,'Data-BG');
%            end
            if (~isempty(param.fit_type) && fp_area > 0)
                legendstr(2) = {'model'};
                plot(hfigure.ax2,XB,fp(XB), 'linewidth', f_line,'DisplayName','cust. model', 'color', [0 0.4470 0.7410]); % user defined peak model
                legendstr(3) = {'peak'};
                plot(hfigure.ax2,XB,fp_peak, 'linewidth', f_line,'DisplayName','prod. peak', 'color', [0.9290 0.6940 0.1250]); % the peak of interest
                p12 = predint(fp,XB,0.95,'observation','off');
                legendstr(4) = {'bounds'};
                plot(hfigure.ax2,XB,p12,'m--', 'linewidth', f_line,'DisplayName','bounds', 'color', 'red')
                %p22 = predint(fp,XB,0.95,'functional','on');
                %plot(hfigure.ax2,XB,p22,'m--', 'linewidth', f_line,'DisplayName','bounds')
            end
            hlegend = legend(hfigure.ax2,legendstr);
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
        xlim(hfigure.ax2,[XB(1)-0.05*x_width XB(end)+0.05*x_width])
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
function [BGline, index_onlynoise, error_S, error_M] = my_BGhelper1(XB, YB, XBsample,YBsample,maxBGiter, param)
    % interpolate new background to original grid so we can substract it
    BGline = interp1(XBsample,YBsample,XB,param.intermethod,'extrap');
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
    BGline = interp1(XB(index_onlynoise),BGline(index_onlynoise),XB,param.intermethod,'extrap');
end

%%
function ret = fit_offsetGauss1(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    minh = min(YBsub);
    [s, lb, ub] = setup_Gauss(1, param, XB, YBsub, false);
    try
        myfittype = fittype('offset+a1*exp(-((x-b1)/c1)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1', 'offset'});
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [s, 0],...
            'Lower', [lb, minh],...
            'Upper', [ub, maxh]...
            );
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 1, false);

end


function ret = fit_linoffsetGauss1(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    maxh = max(YBsub);
    minh = min(YBsub);
    [s, lb, ub] = setup_Gauss(1, param, XB, YBsub, false);    
    try
        myfittype = fittype('offset+slope*x+a1*exp(-((x-b1)/c1)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1', 'offset', 'slope'});
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [s, 0, 0],...
            'Lower', [lb, minh, -Inf],...
            'Upper', [ub, maxh, +Inf]...
            );
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 1, false);
end


function ret = fit_Gauss1(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    [s, lb, ub] = setup_Gauss(1, param, XB, YBsub, false);
    try
        fpoptions = fitoptions('gauss1', ...
            'Lower', lb,...
            'Upper', ub, ...
            'StartPoint', s);
        fp = fit(XB, YBsub,'gauss1',fpoptions);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    
    ret = get_Gaussret(XB, YBsub, fp, 1, false);
end


function ret = fit_Gauss2(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    [s, lb, ub] = setup_Gauss(2, param, XB, YBsub, false);
    try
        fpoptions = fitoptions('gauss2', ...
            'Lower', lb,...
            'Upper', ub, ...
            'StartPoint', s);
       fp = fit(XB, YBsub,'gauss2',fpoptions);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 2, false);
end


function ret = fit_offsetGauss2(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    minh = min(YBsub);
    maxh = max(YBsub);
    [s, lb, ub] = setup_Gauss(2, param, XB, YBsub, false);
    try
        myfittype = fittype('offset+a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1','a2','b2','c2', 'offset'});
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [s, 0],...
            'Lower', [lb, minh],...
            'Upper', [ub, maxh]...
            );
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 2, false);
end


function ret = fit_linoffsetGauss2(XB, YBsub, param)
    % params for gauss are
    % height(a), center (b), width (c)
    minh = min(YBsub);
    maxh = max(YBsub);
    [s, lb, ub] = setup_Gauss(2, param, XB, YBsub, false);
    try
        myfittype = fittype('offset+slope*x+a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1','a2','b2','c2', 'offset','slope'});
        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [s, 0, 0],...
            'Lower', [lb, minh, -Inf],...
            'Upper', [ub, maxh, +Inf]...
            );
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 2, false);
end


function ret = fit_linoffsetcoupledGauss2(XB, YBsub, param)
    % height(a), center (b), width (c)
    minh = min(YBsub);
    maxh = max(YBsub);
    [s, lb, ub] = setup_Gauss(2, param, XB, YBsub, true);
    try
        myfittype = fittype('offset+slope*x+a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-(b1+b2))/c2)^2)',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a1','b1','c1','a2','b2','c2', 'offset','slope'});

        fp = fit(XB, YBsub,myfittype, ...
            'StartPoint', [s, 0, 0],...
            'Lower', [lb, minh, -Inf],...
            'Upper', [ub, maxh, +Inf]...
            );
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_Gaussret(XB, YBsub, fp, 2, true);
end


function ret = fit_offsetasymGauss1(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_offsetGauss1(XB, YBsub, param);
    [s, lb, ub] = setup_asymGauss(ret.fp, 1, param);
    offset = ret.fp.offset;
    ft = fittype('GC_offset_asym_Gauss(x, a0, a1, a2, a3, offset)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', [lb, param.f_offsetmin*offset],...
            'Upper', [ub, param.f_offsetmax*offset],...
            'StartPoint', [s, offset]);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_asymGaussret(XB, YBsub, fp, 1, false);
end


function ret = fit_linoffsetasymGauss1(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_linoffsetGauss1(XB, YBsub, param);
    [s, lb, ub] = setup_asymGauss(ret.fp, 1, param);
    offset = ret.fp.offset;
    slope = ret.fp.slope;
    [offset_l, offset_u, slope_l, slope_u] ...
     = get_linoffset_boundaries(offset, slope, param);
    ft = fittype('GC_linoffset_asym_Gauss(x, a0, a1, a2, a3, offset, slope)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', [lb, offset_l, slope_l],...
            'Upper', [ub, offset_u, slope_u],...
            'StartPoint', [s, offset, slope]);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_asymGaussret(XB, YBsub, fp, 1, false);
end


function ret = fit_asymGauss1(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_Gauss1(XB, YBsub, param);
    [s, lb, ub] = setup_asymGauss(ret.fp, 1, param);
    ft = fittype('GC_asym_Gauss(x, a0, a1, a2, a3)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', lb,...
            'Upper', ub,...
            'StartPoint', s);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_asymGaussret(XB, YBsub, fp, 1, false);
end


function ret = fit_asymGauss2(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_Gauss2(XB, YBsub, param);

    [s, lb, ub] = setup_asymGauss(ret.fp, 2, param);

    ft = fittype('GC_asym_Gauss2(x, a0, a1, a2, a3, b0, b1, b2, b3)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', lb,...
            'Upper', ub,...
            'StartPoint', s);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    
    ret = get_asymGaussret(XB, YBsub, fp, 2, false);
end


function ret = fit_linoffsetasymGauss2(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_linoffsetGauss2(XB, YBsub, param);

    [s, lb, ub] = setup_asymGauss(ret.fp, 2, param);
    
    offset = ret.fp.offset;
    slope = ret.fp.slope;
    [offset_l, offset_u, slope_l, slope_u] ...
     = get_linoffset_boundaries(offset, slope, param);

    ft = fittype('GC_linoffset_asym_Gauss2(x, a0, a1, a2, a3, b0, b1, b2, b3, offset, slope)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', [lb, offset_l, slope_l],...
            'Upper', [ub, offset_u, slope_u],...
            'StartPoint', [s, offset, slope]);
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end

    ret = get_asymGaussret(XB, YBsub, fp, 2, false);
end


function ret = fit_linoffsetcoupledasymGauss2(XB, YBsub, param)
    % get initial guesses from Gauss
    ret = fit_linoffsetcoupledGauss2(XB, YBsub, param);

    [s, lb, ub] = setup_asymGauss(ret.fp, 2, param);
    
    offset = ret.fp.offset;
    slope = ret.fp.slope;
    [offset_l, offset_u, slope_l, slope_u] ...
     = get_linoffset_boundaries(offset, slope, param);
    
    ft = fittype('GC_linoffset_coupled_asym_Gauss2(x, a0, a1, a2, a3, b0, b1, b2, b3, offset, slope)');
    try
        fp = fit( XB, YBsub, ft,...
            'Lower', [lb, offset_l, slope_l],...
            'Upper', [ub, offset_u, slope_u],...
            'StartPoint', [s, offset, slope]);%, ...
%            'Robust', 'LAR', ...
%            'TolFun', 1E-4);%, ...
%            'Display','iter');
    catch ME
        disp(ME)
        st = dbstack;
        error('gcgui:fit_error', ...
              'Curve fit error for "%s":\n%s',...
              param.display_org,st(1).name);
    end
    ret = get_asymGaussret(XB, YBsub, fp, 2, true);
end


function [offset_l, offset_u, ...
          slope_l, slope_u] ...
          = get_linoffset_boundaries(offset, slope, param)
    tmp = abs(abs(slope)-param.f_slopemin*abs(slope)); 
    if tmp<2E-8
        tmp = 2e-8;
    end
    slope_l = slope - tmp;
    
    tmp = abs(param.f_slopemax*abs(slope)-abs(slope));
    if tmp<2E-8
        tmp = 2e-8;
    end
    slope_u = slope + tmp;

    tmp = abs(abs(offset)-param.f_offsetmin*abs(offset));
    if tmp<2E-8
        tmp = 2e-8;
    end
    offset_l = offset - tmp;

    tmp = abs(param.f_offsetmax*abs(offset)-abs(offset));
    if tmp<2E-8
        tmp = 2e-8;
    end
    offset_u = offset + tmp;
end


function [a, a_l, a_u] = get_area_boundaries(area)
    if area < 2e-4
        a = 1E-5; % peak area
        a_l = 0; % peak area
        a_u = 1; % peak area
    else
        a = area; % peak area
        a_l = 0.8*area; % peak area
        a_u = 1.2*area; % peak area
    end
end


function ret = get_asymGaussret(XB, YBsub, fp, pnum, coupled)
    error_S_fp = std(YBsub-fp(XB));
    ret.fp = fp;
    ret.fp_area = zeros(1,pnum);
    ret.fp_peak = zeros(length(XB),pnum);
    ret.fp_error = zeros(1,pnum);
    ret.fp_center = zeros(1,pnum);
    ret.fp_fwhm = zeros(1,pnum);

    coef = coeffvalues(fp);
    for i=1:pnum
        a0 = coef(1+(i-1)*4);
        if i>1 && coupled
            a1 = coef(2)+coef(2+(i-1)*4);
        else
            a1 = coef(2+(i-1)*4);
        end
        a2 = coef(3+(i-1)*4);
        a3 = coef(4+(i-1)*4);

        ret.fp_area(i) = a0;
        ret.fp_peak(:,i) = GC_asym_Gauss(XB, a0, a1, a2, a3);
        ret.fp_error(i) = (error_S_fp)*(3*a2);
        ret.fp_center(i) = a1;
        ret.fp_fwhm(i) = a2;

    end
end


function ret = get_Gaussret(XB, YBsub, fp, pnum, coupled)
    error_S_fp = std(YBsub-fp(XB));
    ret.fp = fp;
    ret.fp_area = zeros(1,pnum);
    ret.fp_peak = zeros(length(XB),pnum);
    ret.fp_error = zeros(1,pnum);
    ret.fp_center = zeros(1,pnum);
    ret.fp_fwhm = zeros(1,pnum);

    coef = coeffvalues(fp);
    for i=1:pnum
        a1 = coef(1+(i-1)*3);
        if i>1 && coupled
            b1 = coef(2)+coef(2+(i-1)*3);
        else
            b1 = coef(2+(i-1)*3);
        end
        c1 = coef(3+(i-1)*3);

        ret.fp_area(i) = a1*c1*(pi)^.5;
        ret.fp_peak(:,i) = a1.*exp(-((XB-b1)./c1).^2);
        ret.fp_error(i) = (error_S_fp)*(3*c1);
        ret.fp_center(i) = b1;
        ret.fp_fwhm(i) = c1;
    end
end


function [s, lb, ub] = setup_asymGauss(fp, pnum, param)
    % uses previous gauss fit as input
    ub = zeros(1, 4*pnum);
    lb = zeros(1, 4*pnum);
    s = zeros(1, 4*pnum);
    coef = coeffvalues(fp);
    for i=1:pnum
        % get coefficients from gauss peak
        Ga1 = coef(1+(i-1)*3); % height
        Gb1 = coef(2+(i-1)*3); % center, or difference (if coupled)
        Gc1 = coef(3+(i-1)*3); % width
        
        area = Ga1*Gc1*(pi)^.5; % Gauss area
        [a0, a0_l, a0_u] = get_area_boundaries(area);
    
        % start values
        s(1+(i-1)*4) = a0;
        s(2+(i-1)*4) = Gb1; % retention time
        s(3+(i-1)*4) = Gc1; % width of gaussian
        s(4+(i-1)*4) =  0.01; % exponential damping term
        % lower limits
        lb(1+(i-1)*4) = a0_l;
        lb(2+(i-1)*4) = Gb1-Gc1; % center
        lb(3+(i-1)*4) =  param.f_wminasymG*Gc1; % width of gaussian
        lb(4+(i-1)*4) = param.f_expdtmin; % exponential damping term
        % upper limits
        ub(1+(i-1)*4) = a0_u;
        ub(2+(i-1)*4) = Gb1+Gc1; % center
        ub(3+(i-1)*4) = param.f_wmaxasymG*Gc1; % width of gaussian
        ub(4+(i-1)*4) = param.f_expdtmax; % exponential damping term
    end
end


function [s, lb, ub] = setup_Gauss(pnum, param, XB, YBsub, coupled)
    % params for gauss are
    % height(a), center (b), width (c)
    %minh = min(YBsub);
    maxh = max(YBsub);

    ub = zeros(1, 3*pnum);
    lb = zeros(1, 3*pnum);
    s = zeros(1, 3*pnum);
    
    for i=1:pnum
        if i>1 && coupled
            b1_l = param.fit_param(1+2*(i-1))-param.fit_param(2+2*(i-1)); % center
            b1_u = param.fit_param(1+2*(i-1))+param.fit_param(2+2*(i-1)); % center
            [val, ~] = max(YBsub((param.fit_param(1)+b1_l) <= XB ...
                                       & XB <= (param.fit_param(1)+b1_u)));
            a1 = val;
            b1 = param.fit_param(1+2*(i-1));
        else
            b1_l = param.fit_param(1+2*(i-1))-param.fit_param(2+2*(i-1))-param.fit_drift; % center
            b1_u = param.fit_param(1+2*(i-1))+param.fit_param(2+2*(i-1))+param.fit_drift; % center
            [val, validx] = max(YBsub(b1_l <= XB & XB <= b1_u));
            a1 = val;
            b1 = XB(validx);
        end

        % start values
        s(1+(i-1)*3) = a1; % height
        s(2+(i-1)*3) = b1; % center
        s(3+(i-1)*3) = param.fit_param(2+2*(i-1)); % width of gaussian
        % lower limits
        lb(1+(i-1)*3) = 0; % height
        lb(2+(i-1)*3) = b1_l; % center
        lb(3+(i-1)*3) = param.f_wminG*param.fit_param(2+2*(i-1)); % width of gaussian
        % upper limits
        ub(1+(i-1)*3) = 1.1*maxh; % height
        ub(2+(i-1)*3) = b1_u; % center
        ub(3+(i-1)*3) = param.f_wmaxG*param.fit_param(2+2*(i-1)); % width of gaussian

    end
end
