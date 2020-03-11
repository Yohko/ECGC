%Licence: GNU General Public License version 2 (GPLv2)
function GC_integrate(display,BGtype)
    % display(1)  ..  1 plot, 0 don't plot
	global GC_usersetting
    eval(GC_usersetting); % load settings
    
    global result
    global input
    
    for ii = 1:length(peakFID)
        result.peakFID(ii).area = zeros(size(input.FID,2),1);
        result.peakFID(ii).err = zeros(size(input.FID,2),1);
        result.peakFID(ii).name = peakFID(ii).name;
        result.peakFID(ii).n = peakFID(ii).n;
        result.peakFID(ii).offset = peakFID(ii).offset;
        result.peakFID(ii).factor = peakFID(ii).factor;        
    end
    
    for ii = 1:length(peakTCD)
        result.peakTCD(ii).area = zeros(size(input.FID,2),1);
        result.peakTCD(ii).err = zeros(size(input.FID,2),1);
        result.peakTCD(ii).name = peakTCD(ii).name;
        result.peakTCD(ii).n = peakTCD(ii).n;
        result.peakTCD(ii).offset = peakTCD(ii).offset;
        result.peakTCD(ii).factor = peakTCD(ii).factor;
    end
    
    result.run = zeros(size(input.FID,2),1);

    BGiter = 100;
    disppauseval = 0.5;
    
    for i=1:size(input.FID,2)
        %shift = input.CO2offset-input.CO2pos(i); % correct for drifts in spectra
        shift = 0;
        % ##### FID #######################################################
        for ii = 1:length(result.peakFID)
            start = peakFID(ii).start+shift;
            stop = peakFID(ii).end+shift;
            graph_title = result.peakFID(ii).name;
            displot = display(peakFID(ii).displotnum); % if its plotted, need to check with peakTCD.name
            if(peakFID(ii).start ~= -1)
                switch BGtype(1)
                    case 1 % linear
                        area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    case 2 % linearfit
                        area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    %case 3 % multi line
                    otherwise % default
                        area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift;20;peakFID(ii).curvature;1],sprintf('%d %s',i,graph_title));
                        result.peakFID(ii).err(i) = area(6);
                end
                result.peakFID(ii).area(i) = area(1);
                if(display(1) && displot)
                    pause(disppauseval);
                end
            else
                result.peakFID(ii).area(i) = 0;
            end
        end

        % ##### TCD #######################################################
        for ii = 1:length(result.peakTCD)
            start = peakTCD(ii).start+shift;
            stop = peakTCD(ii).end+shift;
            graph_title = result.peakTCD(ii).name;
            displot = display(peakTCD(ii).displotnum); % if its plotted, need to check with peakTCD.name
            if(peakTCD(ii).start ~= -1)
                switch BGtype(1)
                    case 1 % linear
                        area = GC_peakInteg_line(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    case 2 % linearfit
                        area = GC_peakInteg_linefit(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    %case 3 % multi line
                    otherwise % default
                        area = GC_peakInteg_multiline(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift;20;peakTCD(ii).curvature;1],sprintf('%d %s',i,graph_title));
                        result.peakTCD(ii).err(i) = area(6);
                end
                result.peakTCD(ii).area(i) = area(1);
                if(display(1) && displot)
                    pause(disppauseval);
                end
            else
                result.peakTCD(ii).area(i) = 0;
            end
        end        
        result.run(i) = i;
    end
    
    % convert to seconds to get the same peak area as in the SRI Software
    for ii = 1:length(result.peakFID)
        result.peakFID(ii).area = result.peakFID(ii).area*60;
        result.peakFID(ii).err = result.peakFID(ii).err*60;
    end
	for ii = 1:length(result.peakTCD)
        result.peakTCD(ii).area = result.peakTCD(ii).area*60;
        result.peakTCD(ii).err = result.peakTCD(ii).err*60;
	end
    
    % substract shoulder peaks (defined by subpeak in
    % 'GC_settings_integrate'
	for ii = 1:length(result.peakFID)
        if(peakFID(ii).subpeak ~=0)
            result.peakFID(ii).area = result.peakFID(ii).area-result.peakFID(peakFID(ii).subpeak).area;
        end
	end
	for ii = 1:length(result.peakTCD)
        if(peakTCD(ii).subpeak ~=0)
            result.peakTCD(ii).area = result.peakTCD(ii).area-result.peakTCD(peakFID(ii).subpeak).area;
        end
	end
end
