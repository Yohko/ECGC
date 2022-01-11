%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_integrate(hfigure)
    for jj = 1:length(hfigure.input.CH)
        hfigure.result.CH(jj).name = hfigure.input.CH(jj).name;
        for ii = 1:length(hfigure.input.CH(jj).peak)
            hfigure.result.CH(jj).peak(ii).area = zeros(1,length(hfigure.input.CH(jj).spectra));
            hfigure.result.CH(jj).peak(ii).err = zeros(1,length(hfigure.input.CH(jj).spectra));
            hfigure.result.CH(jj).peak(ii).name = hfigure.input.CH(jj).peak(ii).name;
            hfigure.result.CH(jj).peak(ii).n = hfigure.input.CH(jj).peak(ii).n;
            hfigure.result.CH(jj).peak(ii).offset = hfigure.input.CH(jj).peak(ii).offset;
            hfigure.result.CH(jj).peak(ii).factor = hfigure.input.CH(jj).peak(ii).factor;        
        end
    end
    
    BGiter = 100;
    disppauseval = 0.5;
    peakcounter1 = 0;
    peakcounter2 = 0;
    progresscounter = 0;
    totalpeakcount = 0;
    % calculate the total peak count for integration
    % (for GUI)
	for jj = 1:length(hfigure.result.CH)
        for i=1:length(hfigure.input.CH(jj).spectra)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                totalpeakcount = totalpeakcount + 1;
            end
        end
	end
    
    % loop though all defined channels
	for jj = 1:length(hfigure.result.CH)
        % for GUI to keep track of peak count
        peakcounter1 = peakcounter1 + peakcounter2;

        % loop though all spectra of current channel
        for i=1:length(hfigure.input.CH(jj).spectra)
            peakcounter2 = 0;
            % peak drift correction
            % currently globally disabled
            if (hfigure.input.CH(jj).RT_shift == 1)
                shift = 0;
            else
                shift = 0;
            end

            % loop trough all defined peaks of current channel
            for ii = 1:length(hfigure.result.CH(jj).peak)
                progresscounter = progresscounter + 1;
                peakcounter2 = peakcounter2 + 1;
                hfigure.UIprog.Message = sprintf('STEP (5) integrate %d/%d: %s %s', progresscounter,totalpeakcount,hfigure.input.CH(jj).name,hfigure.result.CH(jj).peak(ii).name);
                hfigure.UIprog.Value = 0.1+(progresscounter)/totalpeakcount*0.4;
                start = hfigure.input.CH(jj).peak(ii).start+shift;
                if (length(hfigure.input.CH(jj).peak(ii).end)>1)
                    stop = hfigure.input.CH(jj).peak(ii).end(2)+hfigure.result.CH(jj).RT_edgepos(i);
                else
                    stop = hfigure.input.CH(jj).peak(ii).end+shift;
                end
                graph_title = hfigure.result.CH(jj).peak(ii).name;
                displot = hfigure.input.checkplot(peakcounter1+peakcounter2);
                switch hfigure.input.CH(jj).name
                    case 'MSD'
                        subM = 1;
                    otherwise
                        subM = 0;
                end

                % exclude peaks which have a start of -1 and put its area
                % to zero
                if(hfigure.input.CH(jj).peak(ii).start ~= -1)
                    param = struct();
                    param.showplot = hfigure.input.plotpeaks & displot;
                    param.maxBGiter = BGiter;
                    if (isfield(hfigure.input.CH(jj).peak(ii),'BGpoints') && ~isempty(hfigure.input.CH(jj).peak(ii).BGpoints))
                        param.BGpoints = hfigure.input.CH(jj).peak(ii).BGpoints;
                    else
                        param.BGpoints = 10;
                    end

                    % peak fit parameters
                    if (isfield(hfigure.input.CH(jj).peak(ii),'fit_type') && ~isempty(hfigure.input.CH(jj).peak(ii).fit_type) &&...
                        isfield(hfigure.input.CH(jj).peak(ii),'fit_param') && ~isempty(hfigure.input.CH(jj).peak(ii).fit_param))
                        param.fit_type = hfigure.input.CH(jj).peak(ii).fit_type;
                        param.fit_param = hfigure.input.CH(jj).peak(ii).fit_param;
                        if (isfield(hfigure.input.CH(jj).peak(ii),'fit_drift'))
                            param.fit_drift = hfigure.input.CH(jj).peak(ii).fit_drift;
                        else
                            param.fit_drift = 0;
                        end

                    
                    
                    else
                       param.fit_type = []; 
                       param.fit_param = []; 
                       param.fit_drift = 0;
                    end
                    if ( isfield(hfigure.input.CH(jj).peak(ii),'fit_low_criterion') && ...
                        ~isempty(hfigure.input.CH(jj).peak(ii).fit_low_criterion) )
                        param.fit_low_criterion = hfigure.input.CH(jj).peak(ii).fit_low_criterion;
                    else
                        param.fit_low_criterion = -Inf; % never fit the data
                    end
                    if ( isfield(hfigure.input.CH(jj).peak(ii),'av_width') && ...
                        ~isempty(hfigure.input.CH(jj).peak(ii).av_width) )
                        param.av_width = hfigure.input.CH(jj).peak(ii).av_width;
                    else
                        param.av_width = -1;
                    end
                    
                    if ( isfield(hfigure.input.CH(jj).peak(ii),'sel_peak') && ...
                        ~isempty(hfigure.input.CH(jj).peak(ii).sel_peak) )
                        param.sel_peak = hfigure.input.CH(jj).peak(ii).sel_peak;
                    else
                        param.sel_peak = 1;
                    end
                    
                    
                    % especially useful for Agilent GC
                    % with TCD and FID in series
                    % (Accessory 19232C)
                    if (isfield(hfigure.input.CH(jj).peak(ii),'filter') && ~isempty(hfigure.input.CH(jj).peak(ii).filter))
                        windowSize = hfigure.input.CH(jj).peak(ii).filter; 
                        b = (1/windowSize)*ones(1,windowSize);
                        a = 1;
                        newY = filter(b,a,hfigure.input.CH(jj).spectra(i).spectrum(:,2));
                    else
                        newY = hfigure.input.CH(jj).spectra(i).spectrum(:,2);
                    end
                    param.curvature = hfigure.input.CH(jj).peak(ii).curvature;
                    param.BGspacing = 1;  % 0.. random spaced, 1 even spaced
                    param.subM = subM;
                    param.peakcutoff = hfigure.input.CH(jj).RT_cutoff;

                    % calculate BG and integrate peak
                    [ret_area, ret_error] = GC_peak_integrate(hfigure.input.CH(jj).spectra(i).spectrum(:,1),...
                                             newY,...
                                             start, stop, ...
                                             param, ...
                                             sprintf('%d %s',i,graph_title),hfigure);
                    %fprintf('%d CH %s %s: area=%f\n',i, hfigure.input.CH(jj).name, hfigure.result.CH(jj).peak(ii).name, ret_area)

                    % save calculated peak area
                    hfigure.result.CH(jj).peak(ii).area(i) = ret_area;

                    % save calculated peak area error
                    hfigure.result.CH(jj).peak(ii).err(i) = ret_error;

                    % pause for a few seconds if plotting peaks
                    if(hfigure.input.plotpeaks && displot)
                        pause(disppauseval);
                    end
                else
                    hfigure.result.CH(jj).peak(ii).area(i) = 0;
                end
            end
        end
	end
    
    % convert x-axis from min to seconds to get the same peak area as in the SRI Software
    for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            hfigure.result.CH(jj).peak(ii).area = hfigure.result.CH(jj).peak(ii).area*60;
            hfigure.result.CH(jj).peak(ii).err = hfigure.result.CH(jj).peak(ii).err*60;
        end
    end
    
    % substract shoulder peaks (defined by subpeak in
    % 'GC_settings_integrate')
	for jj = 1:length(hfigure.result.CH)
        for ii = 1:length(hfigure.result.CH(jj).peak)
            if(hfigure.input.CH(jj).peak(ii).subpeak ~=0)
                hfigure.result.CH(jj).peak(ii).area = hfigure.result.CH(jj).peak(ii).area ...
                -hfigure.result.CH(hfigure.input.CH(jj).peak(ii).subpeakCH).peak(hfigure.input.CH(jj).peak(ii).subpeak).area ...
                .*hfigure.input.CH(jj).peak(ii).subpeakf;
            end
        end
	end
end
