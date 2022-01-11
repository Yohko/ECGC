%Licence: GNU General Public License version 2 (GPLv2)
function GC_plot_umolhr()
    global GC_usersetting
    eval(GC_usersetting); % load settings
    global input result
    
    figure('units','centimeters','position',[0 0 w_fig h_fig*2]);
    plot( input.runnum, result.COumolhr/input.area,'o-', 'linewidth', f_line);
    hold on;
    plot( input.runnum, result.CH4umolhr/input.area,'o-', 'linewidth', f_line);
    plot( input.runnum, result.C2H4umolhr./input.area,'o-', 'linewidth', f_line);
    %plot( input.runnum, result.C2H6umolhr/input.area,'o-', 'linewidth', f_line);
    plot( input.runnum, result.H2umolhr/input.area,'o-', 'linewidth', f_line);
    %plot( input.runnum, result.O2umolhr,'o-', 'linewidth', f_line);
    hold off;
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    xlabel('spectrum / #', 'fontsize',f_caption);
    ylabel('Intensity / µmol\cdothr^-^1\cdotcm^-^2', 'fontsize',f_caption);
    ylim([0,max(result.H2umolhr/input.area)*1.05]);
    if((input.runnum(end)-1) < (input.runnum(1)+1))
        xlim([(input.runnum(end)-1) (input.runnum(1)+1)]);
    else
        xlim([(input.runnum(1)-1) (input.runnum(end)+1)]);
    end
    title(strrep(input.resultname, '_', '\_'), 'fontsize',10)
    %h = legend('CO','CH_4','C_2H_4','C_2H_6','H_2','Location','Best');
    h = legend('CO','CH_4','C_2H_4','H_2','Location','Best');
    h.FontSize = 10;
    legend boxoff;
%    if(input.printplot == 1)
%        print(sprintf('%s_umolhr.png',input.resultname),'-dpng', '-r600');
%        %print(sprintf('%s_umolhr.pdf',input.resultname),'-dpdf');
%    end
end
