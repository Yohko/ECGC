%Licence: GNU General Public License version 2 (GPLv2)
function GC_plot_rawarea()
    global GC_usersetting
    eval(GC_usersetting); % load settings
    global input result
    
    figure('units','centimeters','position',[0 0 w_fig h_fig]);
    plot( input.runnum, result.FID_CH4,'o-', 'linewidth', f_line);
    hold on;
    plot( input.runnum, result.FID_CO,'o-', 'linewidth', f_line);
    plot( input.runnum, result.FID_CH4_2nd,'o-', 'linewidth', f_line);
    plot( input.runnum, result.FID_CO_2nd,'o-', 'linewidth', f_line);
    plot( input.runnum, result.FID_C2H4,'o-', 'linewidth', f_line);
    plot( input.runnum, result.FID_C2H6,'o-', 'linewidth', f_line);
    plot( input.runnum, result.TCD_H2,'o-', 'linewidth', f_line);
    plot( input.runnum, result.TCD_O2,'o-', 'linewidth', f_line);
    hold off;
    h = legend('CH_4','CO','CH_4 2^n^d', 'CO 2^n^d','C_2H_4','C_2H_6','H_2','O_2','Location','Best');
    h.FontSize = 6;
    legend boxoff;
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    xlabel('spectrum / #', 'fontsize',f_caption);
    ylabel('raw area', 'fontsize',f_caption);
    if((input.runnum(end)-1) < (input.runnum(1)+1))
        xlim([(input.runnum(end)-1) (input.runnum(1)+1)]);
    else
        xlim([(input.runnum(1)-1) (input.runnum(end)+1)]);
    end
    title(strrep(input.resultname, '_', '\_'), 'fontsize',10)
%    if(input.printplot == 1)
%        print(sprintf('%s_rawarea.png',input.resultname),'-dpng', '-r600');
%        %print(sprintf('%s_rawarea.pdf',input.resultname),'-dpdf');
%    end
end
