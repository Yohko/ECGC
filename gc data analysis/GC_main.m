%Licence: GNU General Public License version 2 (GPLv2)
function GC_main(hfigure)
    %% (1) ######## some parameters #######################################
    hfigure.UIprog = uiprogressdlg(hfigure.figure,'Title','Please Wait');
    hfigure.UIprog.Value = 0.0; 
    hfigure.UIprog.Value = 0.0;
    hfigure.UIprog.Message = 'STEP (1) INIT';
    
    %% (2) ######## load data files #######################################
    hfigure.UIprog.Value = 0.0;
    hfigure.UIprog.Message = 'STEP (2) load data';
    hfigure = GC_loadsample(hfigure);
    if(hfigure.retval == -1)
        disp('Unknown Sample.');
        return;
    end
    
    %% (3) ######## split into FID and TCD arrays #########################
    hfigure.UIprog.Value = 0.0;
    hfigure.UIprog.Message = 'STEP (3) split GC data';
    hfigure = GC_split_GC_channels(hfigure);
    
    %% (4) ######## get time spectra shifts################################
    hfigure.UIprog.Value = 0.0;
    hfigure.UIprog.Message = 'STEP (4) get GC shift';
    hfigure = GC_gettimeshift(hfigure);
    
    %% (5) ######## integrate GC peaks ####################################
    hfigure.UIprog.Value = 0.1;
    hfigure.UIprog.Message = 'STEP (5) integrate GC peaks';
    hfigure = GC_integrate(hfigure);
    
    %% (6) ######## process ECLab data ####################################
    hfigure.UIprog.Value = 0.5;
    hfigure.UIprog.Message = 'STEP (6) process EClab data';
    if(hfigure.input.GCandEC == 1)
        hfigure = GC_getCAdata(hfigure);
    end
    
    %% (7) ######## Calculate production rate #############################
%     hfigure.UIprog.Value = 0.6;
%     hfigure.UIprog.Message = 'STEP (7) calculate production rate';
%     if(hfigure.input.GCandEC == 1)
%         hfigure = GC_calcproductrate(hfigure);
%     end

    %% (8) ######## Calc Faradaic Efficiency ##############################
    hfigure.UIprog.Value = 0.7;
    hfigure.UIprog.Message = 'STEP (8) calculate Faradaic Efficiency';
    if(hfigure.input.GCandEC == 1)
        hfigure = GC_calcfaradaicEff(hfigure);
    end
    
    %% (9) ######## Create Graphs #########################################
    hfigure.UIprog.Value = 0.8;
    hfigure.UIprog.Message = 'STEP (9) create graphs (if enabled)';
    % currently broken
%     GC_plot_faradayEff(); % Plot Faradaic Efficiency
%     GC_plot_rawarea(); % plot results raw area
%     GC_plot_umolhrsemilog(); % semilogplot results umolhr
%     GC_plot_umolhr(); % plot results umolhr
%     GC_plot_FID2D(); % 2D plot of FID and TCD

    %% (10-1) ######## export data to CSV #################################
    hfigure.UIprog.Value = 0.9;
    if hfigure.input.exportCSV
        hfigure.UIprog.Message = 'STEP (10) export data as CSV';
        try
            GC_exportCSV_V2(hfigure);
%            GC_exportCSV(hfigure);
        catch ME
            uialert(hfigure.figure,'Matlab Error.','Error');
            rethrow(ME)
        end
    end

    %% (10-2) ######## export data to XLS #################################
    if hfigure.input.exportXLS
        hfigure.UIprog.Message = 'STEP (10) export data as XLS (slow)';
        if(hfigure.input.GCandEC == 1) % GC and EC data present
            try
                GC_exportXLS_V2(hfigure); % requires JAVA scripts
            catch ME
                uialert(hfigure.figure,'Matlab Error.','Error');
                rethrow(ME)
            end
        end
    end
    hfigure.UIprog.Value = 1;
    hfigure.UIprog.Message = 'Done';
    close(hfigure.UIprog);
end
