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
	for jj = 1:length(hfigure.result.CH)
        for i=1:length(hfigure.input.CH(jj).spectra)
            for ii = 1:length(hfigure.result.CH(jj).peak)
                totalpeakcount = totalpeakcount + 1;
            end
        end
	end
    
	for jj = 1:length(hfigure.result.CH)
        peakcounter1 = peakcounter1 + peakcounter2;
        for i=1:length(hfigure.input.CH(jj).spectra)
            peakcounter2 = 0;
            if (hfigure.input.CH(jj).RT_shift == 1)
                shift = 0;
            else
                shift = 0;
            end
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
                
                if(hfigure.input.CH(jj).peak(ii).start ~= -1)
                    switch hfigure.input.intselBGtype(ii)
                        case 1 % linear
                            area = GC_peakInteg_line(hfigure.input.CH(jj).spectra(i).spectrum(:,1),...
                                                     hfigure.input.CH(jj).spectra(i).spectrum(:,2),...
                                                     start, stop, ...
                                                     [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],...
                                                     sprintf('%d %s',i,graph_title));
                        case 2 % linearfit
                            area = GC_peakInteg_linefit(hfigure.input.CH(jj).spectra(i).spectrum(:,1),...
                                                     hfigure.input.CH(jj).spectra(i).spectrum(:,2),...
                                                     start, stop, ...
                                                     [0;0;hfigure.input.plotpeaks & displot;BGiter;0.87+shift],...
                                                     sprintf('%d %s',i,graph_title));
                        %case 3 % multi line
                        otherwise % default
                            param = struct();
                            param.showplot = hfigure.input.plotpeaks & displot;
                            param.maxBGiter = BGiter;
                            if (isfield(hfigure.input.CH(jj).peak(ii),'BGpoints') && ~isempty(hfigure.input.CH(jj).peak(ii).BGpoints))
                                param.BGpoints = hfigure.input.CH(jj).peak(ii).BGpoints;
                            else
                                param.BGpoints = 10;
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
                            param.BGspacing = 1;
                            param.subM = subM;
                            param.peakcutoff = hfigure.input.CH(jj).RT_cutoff;
                            area = GC_peakInteg_multiline(hfigure.input.CH(jj).spectra(i).spectrum(:,1),...
                                                     newY,...
                                                     start, stop, ...
                                                     param, ...
                                                     sprintf('%d %s',i,graph_title),hfigure);
                            hfigure.result.CH(jj).peak(ii).err(i) = area(6);
                    end
                    hfigure.result.CH(jj).peak(ii).area(i) = area(1);
                    if(hfigure.input.plotpeaks && displot)
                        pause(disppauseval);
                    end
                else
                    hfigure.result.CH(jj).peak(ii).area(i) = 0;
                end
            end
        end
	end
    
    % convert to seconds to get the same peak area as in the SRI Software
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
