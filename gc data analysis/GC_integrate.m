%Licence: GNU General Public License version 2 (GPLv2)
function GC_integrate(display,BGtype)
    % display(1)  ..  1 plot, 0 don't plot
    % FID:
    % display(2)  ..  CO
    % display(3)  ..  CH4
    % display(4)  ..  C2H4
    % display(5)  ..  C2H6
    % display(6)  ..  2nd CH4
    % display(7)  ..  2nd CO
    % TCD:
    % display(8)  ..  H2O2
    % display(9)  ..  PG
    % display(10) ..  H2
    % display(11) ..  O2
	global GC_usersetting
    eval(GC_usersetting); % load settings

    
    global result
    global input
    result.FID_CH4 = zeros(size(input.FID,2),1);
    result.FID_CO = zeros(size(input.FID,2),1);
    result.CO_flag = zeros(size(input.FID,2),1);
    result.FID_CH4_2nd = zeros(size(input.FID,2),1);
    result.FID_CO_2nd = zeros(size(input.FID,2),1);
    result.FID_C2H4 = zeros(size(input.FID,2),1);
    result.FID_C2H6 = zeros(size(input.FID,2),1);
    result.TCD_H2 = zeros(size(input.FID,2),1);
    result.TCD_O2 = zeros(size(input.FID,2),1);
    result.TCD_CH4 = zeros(size(input.FID,2),1);
    result.run = zeros(size(input.FID,2),1);

    BGiter = 1000;
    for i=1:size(input.FID,2)
        shift = input.CO2offset-input.CO2pos(i); % correct for drifts in spectra
        % #### CO #########################################################
        % CH4 can be a shoulder on the CO peak, substract CH4 later at end
        % of this file
        start = CO_start+shift;
        stop = CO_end+shift;
        graph_title = 'CO';
        displot = display(2);
        switch BGtype(1)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise % default
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0.87+shift;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        
        result.FID_CO(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end
        if area(3)<0.95
           result.CO_flag(i) = 1;
        end
        
        % #### CH4 ########################################################
        start = CH4_start+shift;
        %stop = input.CO2edge(i);
        stop = input.CO2edge(i)-0.05;
        graph_title = 'CH_4';
        displot = display(3);
        if(stop<start)
           stop = CH4_end+shift;
        end
        
        switch BGtype(2)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i),start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s %d',i,graph_title,input.CO2edge(i)));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i),start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s %d',i,graph_title,input.CO2edge(i)));
            %case 3 % multi line
            otherwise % linear
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;40;-0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.FID_CH4(i) = area(1);
        CH4tmp(i) = area(4);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % #### C2H4 #######################################################
        start = C2H4_start+shift;
        stop = C2H4_end+shift;%
        graph_title = 'C_2H_4';
        displot = display(4);
        switch BGtype(3)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.005;1],sprintf('%d %s',i,graph_title));
        end
        result.FID_C2H4(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % #### C2H6 #######################################################
        start = C2H6_start+shift;
        stop = C2H6_end+shift;
        graph_title = 'C_2H_6';
        displot = display(5);
        switch BGtype(4)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.04;1],sprintf('%d %s',i,graph_title));
        end
        result.FID_C2H6(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % #### 2nd CH4 ####################################################
        start = CH4_2nd_start+shift;
        stop = CH4_2nd_end+shift;
        graph_title = '2nd CH_4';
        displot = display(6);
        switch BGtype(5)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.FID_CH4_2nd(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % #### 2nd CO #####################################################
        start = CO_2nd_start+shift;
        stop = CO_2nd_end+shift;
        graph_title = '2nd CO';
        displot = display(7);
        switch BGtype(6)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.FID_CO_2nd(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % ##### H2O2 TCD ##################################################
        start = H2O2_start+shift;
        stop = H2O2_end+shift;
        graph_title = 'H_2O_2';
        displot = display(8);
        switch BGtype(7)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));        
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));        
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.TCD_H2O2(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end
        
        % #### PG TCD #####################################################
        start = PG_start+shift;
        stop = PG_end+shift;
        graph_title = 'PG';
        displot = display(9);
        switch BGtype(8)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.TCD_PG(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end
                
        % ##### H2 TCD ####################################################
        start = H2_start+shift;
        stop = H2_end+shift;
        graph_title = 'H_2';
        displot = display(10);
        switch BGtype(9)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.TCD_H2(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end

        % ##### CH4 TCD ###################################################

        % ##### O2 TCD ####################################################
        start = O2_start+shift;
        stop = O2_end+shift;
        graph_title = 'O_2';
        displot = display(11);
        switch BGtype(10)
            case 1 % linear
                area = GC_peakInteg_line(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            case 2 % linearfit
                area = GC_peakInteg_linefit(input.tR,input.TCD(:,i), start, stop, [0;0;display(1) & displot;BGiter],sprintf('%d %s',i,graph_title));
            %case 3 % multi line
            otherwise
                area = GC_peakInteg_multiline(input.tR,input.FID(:,i), start, stop, [0;0;display(1) & displot;BGiter;0;20;0.02;1],sprintf('%d %s',i,graph_title));
        end
        result.TCD_O2(i) = area(1);
        if(display(1) && displot)
            pause(2*display(1));
        end
        result.run(i) = i;
    end
    
    % convert to seconds to get the same peak area as in the SRI Software
    result.FID_CH4 = result.FID_CH4*60;
    result.FID_CO = result.FID_CO*60;
    result.FID_CH4_2nd = result.FID_CH4_2nd*60;
    result.FID_CO_2nd = result.FID_CO_2nd*60;
    result.FID_C2H4 = result.FID_C2H4*60;
    result.FID_C2H6 = result.FID_C2H6*60;
    result.TCD_H2 = result.TCD_H2*60;
    result.TCD_O2 = result.TCD_O2*60;
    result.TCD_CH4 = result.TCD_CH4*60;
    result.TCD_H2O2 = result.TCD_H2O2*60;
    result.TCD_PG = result.TCD_PG*60;

    % check if CH4 is a shoulder peak
	for i=1:length(result.FID_CH4)
        if result.CO_flag(i) == 1
            disp('No CH4 shoulder.');
        else
            disp('CH4 shoulder, substracting CH4 from CO.');
            result.FID_CO(i) = result.FID_CO(i)-CH4tmp(i);
        end        
	end
end
