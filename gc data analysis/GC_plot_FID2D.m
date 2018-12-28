%Licence: GNU General Public License version 2 (GPLv2)
function GC_plot_FID2D()
    global GC_usersetting
    eval(GC_usersetting); % load settings
    global input

	figure('units','centimeters','position',[0 0 w_fig h_fig]);
    %imagesc(runnum, tR, FID);
    imagesc(input.runnum, input.tR, log10(-min(min(input.FID))+1+input.FID));
    xlabel('spectrum / #', 'fontsize',f_caption);
    ylabel('Retention Time / min', 'fontsize',f_caption);
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    %set(cb, 'linewidth', f_line);
    %set(cb, 'fontsize', f_caption);
    %set(gca,'YDir','normal');
    title(strrep(input.resultname, '_', '\_'), 'fontsize',10)
%    if(input.printplot == 1)
%        %print(sprintf('%s_FID2D.png',input.resultname),'-dpng', '-r600');
%        %print(sprintf('%s_FID2D.pdf',input.resultname),'-dpdf');
%    end
end
