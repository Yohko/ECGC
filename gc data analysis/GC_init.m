%Licence: GNU General Public License version 2 (GPLv2)
function GC_init()
	global GC_usersetting
    eval(GC_usersetting); % load settings
    global input % input data
    global result % output data
    input = struct;
    result = struct;

    input.printplot = 0;
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
end
