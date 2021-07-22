%Licence: GNU General Public License version 2 (GPLv2)
% individual settings for GC, peak windows, calibration factors, etc.

% --- Peak specific settings ---
% e.g. GCset(settingnum).CH(channelnum).peak(peaknum).
% curvature > 0: relative to actual curvature
% curvature < 0: absolute curvature
% subpeak: which peak(area) to subtract from current peak(area)
% subpeakCH: channel of 'subpeak' peak
% subpeakf: scaling factor for area subtraction (useful for MS detector)
% n: charge for FE calculation
% offset, factor: ppm = measarea*factor + offset (calibration factors)
% start, end: define peak window
% BGpoints: optional (default is 10), # of node points for BG calculation

% --- GC specific settings ---
% e.g. GCset(settingnum).
% type: to select the correct loader (SRI or Agilent)
% name: unique name for current setting, e.g. different calibration dates

% --- Channel specific settings ---
% e.g. GCset(settingnum).CH(channelnum).
% name: name of channel, e.g. name of channel data file (MSD, TIC, TCDA,
%       FIDB for Agilent), or substring of filename for SRI
% RT_cutoff: channel saturation threshold

% --- not functional ---
% RT_shift: % 0 .. disable time shift correction, 1 .. enable time shift correction
% RT_offset:
% RT_edge_start:
% RT_edge_center:

%% ########################################################################
numsetting = 1;
f_MSD = 1;
f_TCD = 1;

GCset(numsetting).type = 'Agilent'; % to select the correct loader
GCset(numsetting).name = 'GCMS_216'; % for naming it in loader, different names for different calibration etc


GCset(numsetting).CH(1).name = 'TIC';
GCset(numsetting).CH(2).name = 'TCDA';

GCset(numsetting).CH(3).name = 'MSD';
GCset(numsetting).CH(3).mz = 26;
GCset(numsetting).CH(3).mzplus = 0.5;
GCset(numsetting).CH(3).mzminus = 0.5;

GCset(numsetting).CH(4).name = 'MSD';
GCset(numsetting).CH(4).mz = 32;
GCset(numsetting).CH(4).mzplus = 0.5;
GCset(numsetting).CH(4).mzminus = 0.5;

GCset(numsetting).CH(5).name = 'MSD';
GCset(numsetting).CH(5).mz = 14;
GCset(numsetting).CH(5).mzplus = 0.5;
GCset(numsetting).CH(5).mzminus = 0.5;

GCset(numsetting).CH(6).name = 'MSD';
GCset(numsetting).CH(6).mz = 28;
GCset(numsetting).CH(6).mzplus = 0.5;
GCset(numsetting).CH(6).mzminus = 0.5;

GCset(numsetting).CH(7).name = 'MSD';
GCset(numsetting).CH(7).mz = 15;
GCset(numsetting).CH(7).mzplus = 0.5;
GCset(numsetting).CH(7).mzminus = 0.5;



% 
% GCset(numsetting).CH(7).name = 'MSD';
% GCset(numsetting).CH(7).mz = 29;
% GCset(numsetting).CH(7).mzplus = 0.5;
% GCset(numsetting).CH(7).mzminus = 0.5;
% 
% GCset(numsetting).CH(8).name = 'MSD';
% GCset(numsetting).CH(8).mz = 31;
% GCset(numsetting).CH(8).mzplus = 0.5;
% GCset(numsetting).CH(8).mzminus = 0.5;
% 
% GCset(numsetting).CH(9).name = 'MSD';
% GCset(numsetting).CH(9).mz = 43;
% GCset(numsetting).CH(9).mzplus = 0.5;
% GCset(numsetting).CH(9).mzminus = 0.5;
% 
% GCset(numsetting).CH(10).name = 'MSD';
% GCset(numsetting).CH(10).mz = 45;
% GCset(numsetting).CH(10).mzplus = 0.5;
% GCset(numsetting).CH(10).mzminus = 0.5;
% 
% GCset(numsetting).CH(11).name = 'MSD';
% GCset(numsetting).CH(11).mz = 57;
% GCset(numsetting).CH(11).mzplus = 0.5;
% GCset(numsetting).CH(11).mzminus = 0.5;
% 
% GCset(numsetting).CH(12).name = 'MSD';
% GCset(numsetting).CH(12).mz = 58;
% GCset(numsetting).CH(12).mzplus = 0.5;
% GCset(numsetting).CH(12).mzminus = 0.5;

for ii=1:length(GCset(numsetting).CH)
    GCset(numsetting).CH(ii).RT_shift = 0;
    GCset(numsetting).CH(ii).RT_offset = 1.37;
    GCset(numsetting).CH(ii).RT_edge_start = 1.25;
    GCset(numsetting).CH(ii).RT_edge_center = 1.7;
    GCset(numsetting).CH(ii).RT_cutoff = 1e12;
end


GCset(numsetting).idH2.peak = 1;
GCset(numsetting).idH2.CH = 2; % TCD
GCset(numsetting).idO2.peak = 2;
GCset(numsetting).idO2.CH = 2; % TCD


GCset(numsetting).idCO.peak = 3;
GCset(numsetting).idCO.CH = 2; % TCD
GCset(numsetting).idCH4.peak = 4;
GCset(numsetting).idCH4.CH = 2; % TCD

%GCset(numsetting).idC2H4.peak = 5;
%GCset(numsetting).idC2H4.CH = 2;
%GCset(numsetting).idC2H6.peak = 6;
%GCset(numsetting).idC2H6.CH = 2;

% GCset(numsetting).idC2H4.peak = 3;
% GCset(numsetting).idC2H4.CH = 1;
% GCset(numsetting).idC2H6.peak = 4;
% GCset(numsetting).idC2H6.CH = 1;

GCset(numsetting).idC2H4.peak = 1;
GCset(numsetting).idC2H4.CH = 3; % MSD mz = 26
GCset(numsetting).idC2H6.peak = 2;
GCset(numsetting).idC2H6.CH = 3;  % MSD mz = 26

GCset(numsetting).idCO2nd.peak = 1;
GCset(numsetting).idCO2nd.CH = 1;
GCset(numsetting).idCH42nd.peak = 2;
GCset(numsetting).idCH42nd.CH = 1;

% MSD TIC #################################################################
CHid = 1;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "CO";
GCset(numsetting).CH(CHid).peak(ii).start = 1.5;
GCset(numsetting).CH(CHid).peak(ii).end = 2.15;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.02;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%x0
GCset(numsetting).CH(CHid).peak(ii).factor = [0.000116785, 7.82E-13];% X1, X2, ...
GCset(numsetting).CH(CHid).peak(ii).n = 2;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 2;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 1;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "CH4";
GCset(numsetting).CH(CHid).peak(ii).start = 1.8;
GCset(numsetting).CH(CHid).peak(ii).end = 2.15;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-35.74447405;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.000251717, 5.88E-12];%0.000546589 * f_MSD;%0.000547219*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 8;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 3;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4";
GCset(numsetting).CH(CHid).peak(ii).start = 3.1;
GCset(numsetting).CH(CHid).peak(ii).end = 3.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.000001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-55.14788481;
GCset(numsetting).CH(CHid).peak(ii).factor = [1.94E-05, 6.61E-13];%0.000101239*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 4;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6";
GCset(numsetting).CH(CHid).peak(ii).start = 3.9;
GCset(numsetting).CH(CHid).peak(ii).end = 4.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.000001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-55.29275737;
GCset(numsetting).CH(CHid).peak(ii).factor = [6.00E-05, 1.86E-15];%7.86313E-05*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

% TCD #####################################################################
CHid = 2;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "H2";
GCset(numsetting).CH(CHid).peak(ii).start = 0.9;
GCset(numsetting).CH(CHid).peak(ii).end = 1.9;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-9.7426436;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.000729034, 3.36E-12];%0.000794411*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 2;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 1;

ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "O2"; %N2
GCset(numsetting).CH(CHid).peak(ii).start = 1.8;
GCset(numsetting).CH(CHid).peak(ii).end = 2.3;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = [0, 0];
GCset(numsetting).CH(CHid).peak(ii).n = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).fit_type = 'asymgauss2';
%GCset(numsetting).CH(CHid).peak(ii).fit_param = [2.19,0.02,2.13,0.02]; % we only use the area of the first defined peak
% O2 is the first one, second is N2
GCset(numsetting).CH(CHid).peak(ii).fit_param = [2.13,0.02,2.19,0.02]; % we only use the area of the first defined peak
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;


ii = 3;
GCset(numsetting).CH(CHid).peak(ii).name = "CO";
GCset(numsetting).CH(CHid).peak(ii).start = 2.15;
GCset(numsetting).CH(CHid).peak(ii).end = 3.1;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005; % curvature of BG
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-26.95020087;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.006125075,5.64E-10];%0.007279171*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 2; % number of electrons
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0; % subtract area from that peak
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 4;
GCset(numsetting).CH(CHid).peak(ii).name = "CH4";
GCset(numsetting).CH(CHid).peak(ii).start = 3.9;
GCset(numsetting).CH(CHid).peak(ii).end = 5.5;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.002224417, -4.43E-11];%0.00206126*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 8;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 5;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4";
GCset(numsetting).CH(CHid).peak(ii).start = 8.8;
GCset(numsetting).CH(CHid).peak(ii).end = 10.2;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.01;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-5.405923214;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.002037336, 2.31E-11];%0.002214248*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 6;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6";
GCset(numsetting).CH(CHid).peak(ii).start = 9.9;
GCset(numsetting).CH(CHid).peak(ii).end = 11.4;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-9.134102754;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.001727624, 1.08E-11];%0.001795775*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

% MSD mz 26 ###############################################################
CHid = 3;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4(mz=26)";
GCset(numsetting).CH(CHid).peak(ii).start = 3.1;
GCset(numsetting).CH(CHid).peak(ii).end = 3.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = -0.01;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-58.69115967;
GCset(numsetting).CH(CHid).peak(ii).factor = [7.97E-05, 1.09E-11];%0.000420852*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 1;

ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6(mz=26)";
GCset(numsetting).CH(CHid).peak(ii).start = 3.9;
GCset(numsetting).CH(CHid).peak(ii).end = 4.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = -0.01;%-0.002;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-50.61196841;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.000600703, -7.86E-13];%0.000797562*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 1;

% MSD mz 32 ###############################################################
CHid = 4;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "O2(mz=32)";
GCset(numsetting).CH(CHid).peak(ii).start = 1.5;
GCset(numsetting).CH(CHid).peak(ii).end = 2.15;
GCset(numsetting).CH(CHid).peak(ii).curvature = -0.01; % curvature of BG
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0;
GCset(numsetting).CH(CHid).peak(ii).n = 0; % number of electrons
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0; % subtract area from that peak
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

% MSD mz 14 ###############################################################
CHid = 5;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "N2(mz=14)";
GCset(numsetting).CH(CHid).peak(ii).start = 1.5;
GCset(numsetting).CH(CHid).peak(ii).end = 1.8;%2.15; CH4 also has 14 which comes above 1.8
GCset(numsetting).CH(CHid).peak(ii).curvature = -0.01; % curvature of BG
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0;
GCset(numsetting).CH(CHid).peak(ii).n = 0; % number of electrons
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0; % subtract area from that peak
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

% MSD mz 28 ###############################################################
CHid = 6;
BG_spacing = 0.04;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "CO(mz=28)";
GCset(numsetting).CH(CHid).peak(ii).start = 1.5;
GCset(numsetting).CH(CHid).peak(ii).end = 2.15;
GCset(numsetting).CH(CHid).peak(ii).curvature = -0.01; % curvature of BG
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-145.204064;
GCset(numsetting).CH(CHid).peak(ii).factor = [3.44E-05, 6.38E-12];%0.000288303*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 2; % number of electrons
GCset(numsetting).CH(CHid).peak(ii).subpeak = 1; % subtract area from that peak
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 5;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 9999/1379; % ratio mz=28 to mz=14 for N2, https://webbook.nist.gov/cgi/cbook.cgi?ID=C7727379&Units=SI&Mask=200#Mass-Spec
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 1;


ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4(mz=28)";
GCset(numsetting).CH(CHid).peak(ii).start = 3.1;
GCset(numsetting).CH(CHid).peak(ii).end = 3.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.000001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-55.14788481;
GCset(numsetting).CH(CHid).peak(ii).factor = [1.63E-05, 4.39E-12];%0.000101239*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

ii = 3;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6(mz=28)";
GCset(numsetting).CH(CHid).peak(ii).start = 3.9;
GCset(numsetting).CH(CHid).peak(ii).end = 4.8;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.000001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-55.29275737;
GCset(numsetting).CH(CHid).peak(ii).factor = [5.19E-05, 2.10E-12];%7.86313E-05*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    BG_spacing);
GCset(numsetting).CH(CHid).peak(ii).XLS = 0;

% MSD mz 15 ###############################################################
CHid = 7;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "CH4(mz=15)";
GCset(numsetting).CH(CHid).peak(ii).start = 1.7;
GCset(numsetting).CH(CHid).peak(ii).end = 2.15;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;%-35.74447405;
GCset(numsetting).CH(CHid).peak(ii).factor = [0.000518613, 4.50E-11];%0.000546589 * f_MSD;%0.000547219*f_MSD;
GCset(numsetting).CH(CHid).peak(ii).n = 8;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = ...
    floor((GCset(numsetting).CH(CHid).peak(ii).end-GCset(numsetting).CH(CHid).peak(ii).start)/...
    (BG_spacing*0.5));
GCset(numsetting).CH(CHid).peak(ii).XLS = 1;


% 
% % MSD mz 29 ###############################################################
% jj = 7;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "Ethanal(mz=29)"; % Acetaldehyde
% GCset(numsetting).CH(jj).peak(ii).start = 12.16-3;
% GCset(numsetting).CH(jj).peak(ii).end = 12.16+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 10; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% 
% % MSD mz 31 ###############################################################
% jj = 8;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "Methanol(mz=31)";
% GCset(numsetting).CH(jj).peak(ii).start = 11.03-3;
% GCset(numsetting).CH(jj).peak(ii).end = 11.03+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 6; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% 
% ii = 2;
% GCset(numsetting).CH(jj).peak(ii).name = "Ethanol(mz=31)";
% GCset(numsetting).CH(jj).peak(ii).start = 14.85-3;
% GCset(numsetting).CH(jj).peak(ii).end = 14.85+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.0000001; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 12; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% 
% ii = 3;
% GCset(numsetting).CH(jj).peak(ii).name = "1-Propanol(mz=31)";
% GCset(numsetting).CH(jj).peak(ii).start = 19.22-3;
% GCset(numsetting).CH(jj).peak(ii).end = 19.22+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 18; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% % MSD mz 43 ###############################################################
% jj = 9;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "Acetone(mz=43)";
% GCset(numsetting).CH(jj).peak(ii).start = 16.98-3;
% GCset(numsetting).CH(jj).peak(ii).end = 16.98+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 16; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% % MSD mz 45 ###############################################################
% jj = 10;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "2-Propanol(mz=45)";
% GCset(numsetting).CH(jj).peak(ii).start = 17.51-3;
% GCset(numsetting).CH(jj).peak(ii).end = 17.51+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 18; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% % MSD mz 57 ###############################################################
% jj = 11;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "AllylAlcohol(mz=57)";
% GCset(numsetting).CH(jj).peak(ii).start = 18.52-1.5;
% GCset(numsetting).CH(jj).peak(ii).end = 18.52+1.5;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 16; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% % MSD mz 58 ###############################################################
% jj = 12;
% ii = 1;
% GCset(numsetting).CH(jj).peak(ii).name = "Propanal(mz=58)";%Propionaldeyde
% GCset(numsetting).CH(jj).peak(ii).start = 16.58-3;
% GCset(numsetting).CH(jj).peak(ii).end = 16.58+3;
% GCset(numsetting).CH(jj).peak(ii).curvature = -0.01; % curvature of BG
% GCset(numsetting).CH(jj).peak(ii).offset = 0.0;
% GCset(numsetting).CH(jj).peak(ii).factor = 1*f_MSD;
% GCset(numsetting).CH(jj).peak(ii).n = 16; % number of electrons
% GCset(numsetting).CH(jj).peak(ii).subpeak = 0; % subtract area from that peak
% GCset(numsetting).CH(jj).peak(ii).subpeakCH = 0;
% GCset(numsetting).CH(jj).peak(ii).subpeakf = 1;
% 


%% Agilent GC TCD FID 2021/02
f_TCD = 1;
f_FID = 1;
numsetting = 2;
GCset(numsetting).type = 'Agilent'; % to select the correct loader
GCset(numsetting).name = 'GCTCDFID_201'; % for naming it in loader, different names for different calibration etc
GCset(numsetting).CH(1).name = 'TCDA';
GCset(numsetting).CH(2).name = 'FIDB';

GCset(numsetting).CH(1).RT_shift = 1;
GCset(numsetting).CH(1).RT_offset = 0;
GCset(numsetting).CH(1).RT_edge_start = 2.6;
GCset(numsetting).CH(1).RT_edge_center = 3.3;
GCset(numsetting).CH(1).RT_cutoff = 1e12;

GCset(numsetting).CH(2).RT_shift = 0;
GCset(numsetting).CH(2).RT_offset = 0;
GCset(numsetting).CH(2).RT_edge_start = 0;
GCset(numsetting).CH(2).RT_edge_center = 0;
GCset(numsetting).CH(2).RT_cutoff = 1e12;

GCset(numsetting).idH2.peak = 1;
GCset(numsetting).idH2.CH = 1;

GCset(numsetting).idO2.peak = 2;
GCset(numsetting).idO2.CH = 1;

GCset(numsetting).idCO.peak = 3;
GCset(numsetting).idCO.CH = 1;

GCset(numsetting).idCH4.peak = 1;
GCset(numsetting).idCH4.CH = 2;

GCset(numsetting).idC2H4.peak = 2;
GCset(numsetting).idC2H4.CH = 2;

GCset(numsetting).idC2H6.peak = 3;
GCset(numsetting).idC2H6.CH = 2;

GCset(numsetting).idCO2nd.peak = 3;
GCset(numsetting).idCO2nd.CH = 1;
GCset(numsetting).idCH42nd.peak = 4;
GCset(numsetting).idCH42nd.CH = 1;

% TCD #####################################################################
CHid = 1;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "H2";
GCset(numsetting).CH(CHid).peak(ii).start = 0.9;
GCset(numsetting).CH(CHid).peak(ii).end = 1.4;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.000443424*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 2;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;

ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "O2"; %N2
GCset(numsetting).CH(CHid).peak(ii).start = 1.3;
GCset(numsetting).CH(CHid).peak(ii).end = 1.9;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.0*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 3;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 1;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;

ii = 3;
GCset(numsetting).CH(CHid).peak(ii).name = "CO";
GCset(numsetting).CH(CHid).peak(ii).start = 1.5;
GCset(numsetting).CH(CHid).peak(ii).end = 1.9;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001; % curvature of BG
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.004344561*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 2; % number of electrons
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0; % subtract area from that peak
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;

ii = 4;
GCset(numsetting).CH(CHid).peak(ii).name = "CH4";
GCset(numsetting).CH(CHid).peak(ii).start = 2.1;
GCset(numsetting).CH(CHid).peak(ii).end = [2.9,-0.05]; % second parameter defines end by substracting it from edge position of timing peak
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.001242906*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 8;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;

ii = 5;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4";
GCset(numsetting).CH(CHid).peak(ii).start = 5.4;
GCset(numsetting).CH(CHid).peak(ii).end = 6.4;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.001411646*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 40;

ii = 6;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6";
GCset(numsetting).CH(CHid).peak(ii).start = 6.2;
GCset(numsetting).CH(CHid).peak(ii).end = 8.5;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 0.001178587*f_TCD;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 40;

% FID #####################################################################
CHid = 2;
ii = 1;
GCset(numsetting).CH(CHid).peak(ii).name = "CH4";
GCset(numsetting).CH(CHid).peak(ii).start = 1.8;
GCset(numsetting).CH(CHid).peak(ii).end = 2.9;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.0002;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 1.47053E-05*f_FID;
GCset(numsetting).CH(CHid).peak(ii).n = 8;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;
GCset(numsetting).CH(CHid).peak(ii).filter = 4;

ii = 2;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H4";
GCset(numsetting).CH(CHid).peak(ii).start = 5.4;
GCset(numsetting).CH(CHid).peak(ii).end = 6.4;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.001;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 7.94748E-06*f_FID;
GCset(numsetting).CH(CHid).peak(ii).n = 12;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 80;
GCset(numsetting).CH(CHid).peak(ii).filter = 4;

ii = 3;
GCset(numsetting).CH(CHid).peak(ii).name = "C2H6";
GCset(numsetting).CH(CHid).peak(ii).start = 6.2;
GCset(numsetting).CH(CHid).peak(ii).end = 8.5;
GCset(numsetting).CH(CHid).peak(ii).curvature = 0.0005;
GCset(numsetting).CH(CHid).peak(ii).offset = 0.0;
GCset(numsetting).CH(CHid).peak(ii).factor = 8.3804E-06*f_FID;
GCset(numsetting).CH(CHid).peak(ii).n = 14;
GCset(numsetting).CH(CHid).peak(ii).subpeak = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakCH = 0;
GCset(numsetting).CH(CHid).peak(ii).subpeakf = 1;
GCset(numsetting).CH(CHid).peak(ii).BGpoints = 60;
GCset(numsetting).CH(CHid).peak(ii).filter = 4;


