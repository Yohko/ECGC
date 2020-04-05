%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_init(hfigure)
    eval(hfigure.GC_usersetting); % load settings
    hfigure.input.printplot = 0;
	hfigure.input.h_plotfigure = [];
    ff = what;
    hfigure.input.cwd = [ff.path '/'];
    hfigure.input.GCoffsettime = 0;
    hfigure.input.GCinttime = 2;
    hfigure.input.GC_binning = 0;
    hfigure.input.GCandEC = 1;
    hfigure.input.area = 1;
    hfigure.input.UtoRHE = 0;
    hfigure.input.Ru = 0;
    hfigure.input.compensation = 0.85;
    hfigure.input.headspacevol = headspacevol;
    hfigure.input.flowrate = flowrate;
    hfigure.input.hr = hfigure.input.headspacevol/hfigure.input.flowrate/60*1000;
    % update data in app
    guidata(hfigure.figure,hfigure);
end
