%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_integrate(hfigure)
    for ii = 1:length(hfigure.input.peakCH1)
        hfigure.result.peakCH1(ii).area = zeros(size(hfigure.input.CH1,2),1);
        hfigure.result.peakCH1(ii).err = zeros(size(hfigure.input.CH1,2),1);
        hfigure.result.peakCH1(ii).name = hfigure.input.peakCH1(ii).name;
        hfigure.result.peakCH1(ii).n = hfigure.input.peakCH1(ii).n;
        hfigure.result.peakCH1(ii).offset = hfigure.input.peakCH1(ii).offset;
        hfigure.result.peakCH1(ii).factor = hfigure.input.peakCH1(ii).factor;        
    end
    
    for ii = 1:length(hfigure.input.peakCH2)
        hfigure.result.peakCH2(ii).area = zeros(size(hfigure.input.CH1,2),1);
        hfigure.result.peakCH2(ii).err = zeros(size(hfigure.input.CH1,2),1);
        hfigure.result.peakCH2(ii).name = hfigure.input.peakCH2(ii).name;
        hfigure.result.peakCH2(ii).n = hfigure.input.peakCH2(ii).n;
        hfigure.result.peakCH2(ii).offset = hfigure.input.peakCH2(ii).offset;
        hfigure.result.peakCH2(ii).factor = hfigure.input.peakCH2(ii).factor;
    end
    
    hfigure.result.run = zeros(size(hfigure.input.CH1,2),1);

    BGiter = 100;
    disppauseval = 0.5;
    
    for i=1:size(hfigure.input.CH1,2)
        %shift = hfigure.input.CO2offset-hfigure.input.CO2pos(i); % correct for drifts in spectra
        shift = 0;
        % ##### CH1 #######################################################
        for ii = 1:length(hfigure.result.peakCH1)
            hfigure.UIprog.Message = sprintf('STEP (5) integrate %d/%d: %s %s', i,size(hfigure.input.CH1,2),hfigure.input.ch1name,hfigure.result.peakCH1(ii).name);
            hfigure.UIprog.Value = 0.1+i/size(hfigure.input.CH1,2)*0.4;
            start = hfigure.input.peakCH1(ii).start+shift;
            stop = hfigure.input.peakCH1(ii).end+shift;
            graph_title = hfigure.result.peakCH1(ii).name;
            displot = hfigure.input.checkplot(ii);
            if(hfigure.input.peakCH1(ii).start ~= -1)
                switch hfigure.input.intselBGtype(ii)
                    case 1 % linear
                        area = GC_peakInteg_line(hfigure.input.tR,hfigure.input.CH1(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    case 2 % linearfit
                        area = GC_peakInteg_linefit(hfigure.input.tR,hfigure.input.CH1(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    %case 3 % multi line
                    otherwise % default
                        area = GC_peakInteg_multiline(hfigure.input.tR,hfigure.input.CH1(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift;20;hfigure.input.peakCH1(ii).curvature;1],sprintf('%d %s',i,graph_title),hfigure);
                        hfigure.result.peakCH1(ii).err(i) = area(6);
                end
                hfigure.result.peakCH1(ii).area(i) = area(1);
                if(hfigure.input.plotpeaks && displot)
                    pause(disppauseval);
                end
            else
                hfigure.result.peakCH1(ii).area(i) = 0;
            end
        end

        % ##### CH2 #######################################################
        for ii = 1:length(hfigure.result.peakCH2)
            hfigure.UIprog.Message = sprintf('STEP (5) integrate %d/%d: %s %s', i,size(hfigure.input.CH1,2),hfigure.input.ch2name,hfigure.result.peakCH2(ii).name);
            hfigure.UIprog.Value = 0.1+i/size(hfigure.input.CH1,2)*0.4;
            start = hfigure.input.peakCH2(ii).start+shift;
            stop = hfigure.input.peakCH2(ii).end+shift;
            graph_title = hfigure.result.peakCH2(ii).name;
            displot = hfigure.input.checkplot(length(hfigure.input.peakCH1)+ii);
            if(hfigure.input.peakCH2(ii).start ~= -1)
                switch hfigure.input.intselBGtype(length(hfigure.input.peakCH1)+ii)
                    case 1 % linear
                        area = GC_peakInteg_line(hfigure.input.tR,hfigure.input.CH2(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    case 2 % linearfit
                        area = GC_peakInteg_linefit(hfigure.input.tR,hfigure.input.CH2(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
                    %case 3 % multi line
                    otherwise % default
                        area = GC_peakInteg_multiline(hfigure.input.tR,hfigure.input.CH2(:,i), start, stop, [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift;20;hfigure.input.peakCH2(ii).curvature;1],sprintf('%d %s',i,graph_title),hfigure);
                        hfigure.result.peakCH2(ii).err(i) = area(6);
                end
                hfigure.result.peakCH2(ii).area(i) = area(1);
                if(hfigure.input.plotpeaks && displot)
                    pause(disppauseval);
                end
            else
                hfigure.result.peakCH2(ii).area(i) = 0;
            end
        end        
        hfigure.result.run(i) = i;
    end
    
    % convert to seconds to get the same peak area as in the SRI Software
    for ii = 1:length(hfigure.result.peakCH1)
        hfigure.result.peakCH1(ii).area = hfigure.result.peakCH1(ii).area*60;
        hfigure.result.peakCH1(ii).err = hfigure.result.peakCH1(ii).err*60;
    end
	for ii = 1:length(hfigure.result.peakCH2)
        hfigure.result.peakCH2(ii).area = hfigure.result.peakCH2(ii).area*60;
        hfigure.result.peakCH2(ii).err = hfigure.result.peakCH2(ii).err*60;
	end
    
    % substract shoulder peaks (defined by subpeak in
    % 'GC_settings_integrate'
	for ii = 1:length(hfigure.result.peakCH1)
        if(hfigure.input.peakCH1(ii).subpeak ~=0)
            hfigure.result.peakCH1(ii).area = hfigure.result.peakCH1(ii).area-hfigure.result.peakCH1(hfigure.input.peakCH1(ii).subpeak).area;
        end
	end
	for ii = 1:length(hfigure.result.peakCH2)
        if(hfigure.input.peakCH2(ii).subpeak ~=0)
            hfigure.result.peakCH2(ii).area = hfigure.result.peakCH2(ii).area-hfigure.result.peakCH2(hfigure.input.peakCH1(ii).subpeak).area;
        end
	end
end
