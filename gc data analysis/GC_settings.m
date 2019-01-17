%Licence: GNU General Public License version 2 (GPLv2)
% default settings should be saved as 'GC_settings.m'

%%  settings for graphs
f_legend = 16;
f_axis = 16;
f_caption = 16;
f_line = 1.5;
w_fig = 10;
h_fig = 8;
f_cb = 0.6;
f_alpha = 0.6;

%% peak position window for integration
% FID
CO_start = 0.65+0.1+0.05;
CO_end = 1.05+0.1;
CO_curvature = 0.02;

CH4_start = 0.87+0.2;
CH4_end = 1.20+0.1;
CH4_curvature = -0.02;

C2H4_start = 1.9+0.4;
C2H4_end = 2.7+0.2;
C2H4_curvature = 0.005;

C2H6_start = 2.4+0.4;
C2H6_end = 3.2+0.4-0.2;
C2H6_curvature = 0.04;

CH4_2nd_start = 6.4;
CH4_2nd_end = 7.3;
CH4_2nd_curvature = 0.02;

CO_2nd_start = 7+0.2;
CO_2nd_end = 7.8+0.2;
CO_2nd_curvature = 0.02;

% TCD
H2O2_start = 0.5;
H2O2_end = 0.7;
H2O2_curvature = 0.02;

PG_start = 0.6;
PG_end = 0.8;
PG_curvature = 0.02;

H2_start = 4.2;
H2_end = 5.2;
H2_curvature = 0.02;

O2_start = 5.0-0.1;
O2_end = 5.8-0.2;
O2_curvature = 0.005;

%% other settings
CO2offset = 1.097; %arbitrary value based on one spectrum after N2 clean, can be adjusted if needed, peak position window is calibrated to this
headspacevol = 0.17; % in L
flowrate = 7.5; %in sccm, fallback if not included in EC-Lab file
CO2_edge_start = 1.0;
CO2_edge_center = 1.3;
%CO2_cutoff = 4530;
%CO2_cutoff = 4520;
%CO2_cutoff = 4420;
CO2_cutoff = 4100;
%CO2_cutoff = 4450;
%CO2_cutoff = 6530;
path_to_EXCEL = '/Applications/Microsoft\\ Excel.app';

%% GC calibration factors (Version: ??)
CO_offset = 0;
CO_factor = 6.736;

CO_M_offset = 0;
CO_M_factor = 5.5955;

CH4_offset = 0;
CH4_factor = 6.4612;

CH4_M_offset = 0;
CH4_M_factor = 4.3794;

C2H4_offset = 0;
C2H4_factor = 11.186;

C2H6_offset = 0;
C2H6_factor = 11.38;

H2_offset = 0;
H2_factor = 0.1346;

O2_offset = 0;
O2_factor = 0.0041;