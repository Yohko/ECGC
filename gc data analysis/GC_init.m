%Licence: GNU General Public License version 2 (GPLv2)
function GC_init()
	global GC_usersetting
    eval(GC_usersetting); % load settings
    global cal % calibration curve for GC
    global input % input data
    global result % output data
    input = struct;
    result = struct;
    cal = struct;

    input.printplot = 1;
	input.h_plotfigure = [];
    ff = what;
    input.cwd = [ff.path '/'];
    input.GCoffsettime = 0;
    input.GCinttime = 2;
    input.GC_binning = 0;
    input.GCandEC = 1;
    input.area = 1;
    input.UtoRHE = 0;
    input.Ru = 0;
    input.compensation = 0.85;
    input.headspacevol = headspacevol;
    input.flowrate = flowrate;
    input.CO2_edge_start  = CO2_edge_start;
    input.CO2_edge_center = CO2_edge_center;
    input.hr = input.headspacevol/input.flowrate/60*1000;
    input.CO2offset = CO2offset;

    cal.CO_offset = CO_offset;
    cal.CO_factor = CO_factor;
    cal.CO_M_offset = CO_M_offset;
    cal.CO_M_factor = CO_M_factor;
    cal.CH4_offset = CH4_offset;
    cal.CH4_factor = CH4_factor;
    cal.CH4_M_offset = CH4_M_offset;
    cal.CH4_M_factor = CH4_M_factor;
    cal.C2H4_offset = C2H4_offset;
    cal.C2H4_factor = C2H4_factor;
    cal.C2H6_offset = C2H6_offset;
    cal.C2H6_factor = C2H6_factor;
    cal.H2_offset = H2_offset;
    cal.H2_factor = H2_factor;
    cal.O2_offset = O2_offset;
    cal.O2_factor = O2_factor;
end
