%Licence: GNU General Public License version 2 (GPLv2)
function GC_main(sample, plot, BGtype)
    %% (1) ######## some parameters #######################################
    disp('STEP (1) INIT');
    global input
    %global result
    GC_init();
    GC_load_samplelist();
    %% (2) ######## load data files #######################################
    disp('STEP (2) load data');
    if(GC_loadsample(sample) == -1)
        disp('Unknown Sample.');
        return;
    end
    %% (3) ######## split into FID and TCD arrays #########################
    disp('STEP (3) split GC data');
    GC_split_TCD_FID();
    %% (4) ######## get time spectra shifts################################
    disp('STEP (4) get GC shift');
    % use edge of CO2 peak in FID channel to compensate for spectra drifts
    GC_gettimeshift();
    %% (5) ######## integrate GC peaks ####################################
    disp('STEP (5) integrate GC peaks');
    GC_integrate(plot, BGtype);
    %% (6) ######## process ECLab data ####################################
    if(input.GCandEC == 1)
        disp('STEP (6) process EClab data');
        GC_getCAdata();
    end
    %% (7) ######## Calculate production rate #############################
    if(input.GCandEC == 1)
        disp('STEP (7) calculate production rate');
        GC_calcproductrate();
    end
    %% (8) ######## Calc Faradaic Efficiency ##############################
    if(input.GCandEC == 1)
        disp('STEP (8) calculate Faradaic Efficiency');
        GC_calcfaradaicEff();
    end
    %% (9) ######## Create Graphs #########################################
    disp('STEP (9) create graphs (if enabled)');
%     GC_plot_faradayEff(); % Plot Faradaic Efficiency
%     GC_plot_rawarea(); % plot results raw area
%     GC_plot_umolhrsemilog(); % semilogplot results umolhr
%     GC_plot_umolhr(); % plot results umolhr
%     GC_plot_FID2D(); % 2D plot of FID and TCD
    %% (10-1) ######## export data to CSV #################################
    %GC_exportCSV();
    %% (10-2) ######## export data to XLS #################################
    disp('STEP (10) export to EXCEL and open results (if enabled)');
    disp(sprintf('Exporting to: %s',input.cwd));
    GC_exportXLS(); % requires JAVA scripts
end
