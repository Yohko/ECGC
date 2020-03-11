%Licence: GNU General Public License version 2 (GPLv2)
% peak position window for integration

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
peakFID(1).name = "CO";
peakFID(1).start = 0.4;
peakFID(1).end = 1.2;
peakFID(1).curvature = 0.02;
peakFID(1).displotnum = 2;
peakFID(1).offset = 0;
peakFID(1).factor = 1/2.757850684;
peakFID(1).n = 2;
peakFID(1).subpeak = 2;

peakFID(2).name = "CH4";
peakFID(2).start = 0.85;
peakFID(2).end = 1.2;
peakFID(2).curvature = 0.02;%-0.02;
peakFID(2).displotnum = 3;
peakFID(2).offset = 0;
peakFID(2).factor = 1/2.922806834;
peakFID(2).n = 8;
peakFID(2).subpeak = 0;

peakFID(3).name = "C2H4";
peakFID(3).start = 2.4;
peakFID(3).end = 3.4;
peakFID(3).curvature = 0.000001;%0.005;
peakFID(3).displotnum = 4;
peakFID(3).offset = 0;
peakFID(3).factor = 1/1.330678609;
peakFID(3).n = 12;
peakFID(3).subpeak = 0;

peakFID(4).name = "C2H6";
peakFID(4).start = 3.4;
peakFID(4).end = 4.8;
peakFID(4).curvature = 0.000001;%-0.002;
peakFID(4).displotnum = 5;
peakFID(4).offset = 0;
peakFID(4).factor = 1/1.390701495;
peakFID(4).n = 14;
peakFID(4).subpeak = 0;

% ### TCD #################################################################
peakTCD(1).name = "H2";
peakTCD(1).start = 0.48;
peakTCD(1).end = 0.68;
peakTCD(1).curvature = -0.01;
peakTCD(1).displotnum = 10;
peakTCD(1).offset = 0;
peakTCD(1).factor = 1/44.71900545;
peakTCD(1).n = 2;
peakTCD(1).subpeak = 0;

peakTCD(2).name = "O2";
peakTCD(2).start = 0.64;
peakTCD(2).end = 0.9;
peakTCD(2).curvature = 0.005;
peakTCD(2).displotnum = 11;
peakTCD(2).offset = 0;
peakTCD(2).factor = 1/106.2677781;
peakTCD(2).n = 0;
peakTCD(2).subpeak = 0;


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
