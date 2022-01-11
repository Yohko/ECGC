%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_loadsample(hfigure)
    hfigure.retval = 1;    
    id = get(hfigure.listbox_samplelist,'Value');
	hfigure.input.resultname = sprintf('%d_%s',table2array(hfigure.input.samplelist(id,2)),...
         char(table2cell(hfigure.input.samplelist(id,1))));
    hfigure.input.GCoffsettime = table2array(hfigure.input.samplelist(id,6));
    hfigure.input.GCinttime = table2array(hfigure.input.samplelist(id,7));
    hfigure.input.GC_binning = table2array(hfigure.input.samplelist(id,8));
    hfigure.input.area = table2array(hfigure.input.samplelist(id,3));
    hfigure.input.UtoRHE = table2array(hfigure.input.samplelist(id,5));
    hfigure.input.Ru = table2array(hfigure.input.samplelist(id,9));
    hfigure.input.compensation = table2array(hfigure.input.samplelist(id,10));
    hfigure.input.GCandEC = table2array(hfigure.input.samplelist(id,11));    
	try
        load(sprintf('CA_%s.mat',hfigure.input.resultname));
	catch
        eval(sprintf('CA_%s = 0;',hfigure.input.resultname));
        disp('Error loading EC data.');
        hfigure.input.GCandEC = 0;
	end

    try
        load(sprintf('GC_%s.mat',hfigure.input.resultname));
    catch
        eval(sprintf('GC_%s = 0;',hfigure.input.resultname));
        disp('Error loading GC data.');
        hfigure.retval = -1;
    end
    eval(sprintf('hfigure.input.spectraEC = CA_%s;',hfigure.input.resultname));
	eval(sprintf('hfigure.input.spectra = GC_%s;',hfigure.input.resultname));
end
