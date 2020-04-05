%Licence: GNU General Public License version 2 (GPLv2)
% peak position window for integration

ch1name = 'FID';
ch2name = 'TCD';


% used for exporting to XLS and TXT
idCO = 1; %FID
idCH4 = 2; %FID
idC2H4 = 3; %FID
idC2H6 = 4; %FID
idCO2nd = 1; %FID
idCH42nd = 2; %FID
idH2 = 1; %TCD
idO2 = 2; %TCD



% ### FID #################################################################
peakCH1(1).name = "CO";
peakCH1(1).start = 0.4;
peakCH1(1).end = 1.2;
peakCH1(1).curvature = 0.02;
peakCH1(1).displotnum = 2;
peakCH1(1).offset = 0;
peakCH1(1).factor = 1/2.757850684;
peakCH1(1).n = 2;
peakCH1(1).subpeak = 2;

peakCH1(2).name = "CH4";
peakCH1(2).start = 0.85;
peakCH1(2).end = 1.2;
peakCH1(2).curvature = 0.02;%-0.02;
peakCH1(2).displotnum = 3;
peakCH1(2).offset = 0;
peakCH1(2).factor = 1/2.922806834;
peakCH1(2).n = 8;
peakCH1(2).subpeak = 0;

peakCH1(3).name = "C2H4";
peakCH1(3).start = 2.4;
peakCH1(3).end = 3.4;
peakCH1(3).curvature = 0.000001;%0.005;
peakCH1(3).displotnum = 4;
peakCH1(3).offset = 0;
peakCH1(3).factor = 1/1.330678609;
peakCH1(3).n = 12;
peakCH1(3).subpeak = 0;

peakCH1(4).name = "C2H6";
peakCH1(4).start = 3.4;
peakCH1(4).end = 4.8;
peakCH1(4).curvature = 0.000001;%-0.002;
peakCH1(4).displotnum = 5;
peakCH1(4).offset = 0;
peakCH1(4).factor = 1/1.390701495;
peakCH1(4).n = 14;
peakCH1(4).subpeak = 0;

% ### TCD #################################################################
peakCH2(1).name = "H2";
peakCH2(1).start = 0.48;
peakCH2(1).end = 0.68;
peakCH2(1).curvature = -0.01;
peakCH2(1).displotnum = 10;
peakCH2(1).offset = 0;
peakCH2(1).factor = 1/44.71900545;
peakCH2(1).n = 2;
peakCH2(1).subpeak = 0;

peakCH2(2).name = "O2";
peakCH2(2).start = 0.64;
peakCH2(2).end = 0.9;
peakCH2(2).curvature = 0.005;
peakCH2(2).displotnum = 11;
peakCH2(2).offset = 0;
peakCH2(2).factor = 1/106.2677781;
peakCH2(2).n = 0;
peakCH2(2).subpeak = 0;


% #########################################################################
% settings to automatically align different spectra
CO2offset = 1.37; %arbitrary value based on one spectrum after N2 clean, can be adjusted if needed, peak position window is calibrated to this
CO2_edge_start = 1.25;
CO2_edge_center = 1.7;
%CO2_cutoff = 4530;
%CO2_cutoff = 4520;
%CO2_cutoff = 4420;
CO2_cutoff = 4100;
%CO2_cutoff = 4450;
%CO2_cutoff = 6530;
