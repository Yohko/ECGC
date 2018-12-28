%Licence: GNU General Public License version 2 (GPLv2)
function GC_plot_faradayEff()
    global GC_usersetting
    eval(GC_usersetting); % load settings
    global input result

    figure('units','centimeters','position',[0 0 w_fig h_fig*2]);
    plot(result.GCpotential+input.UtoRHE,result.COFaraday,'o', 'linewidth', f_line);
    hold on;
    plot(result.GCpotential+input.UtoRHE,result.CH4Faraday,'o', 'linewidth', f_line);
    plot(result.GCpotential+input.UtoRHE,result.C2H4Faraday,'o', 'linewidth', f_line);
    %plot(GCpotential,C2H6Faraday,'o', 'linewidth', f_line);
    plot(result.GCpotential+input.UtoRHE,result.H2Faraday,'o', 'linewidth', f_line);
    %plot(GCpotential,O2Faraday,'o', 'linewidth', f_line);
    hold off;
    %h = legend('CO','CH_4','C_2H_4','C_2H_6','H_2','Location','Best');
    h = legend('CO','CH_4','C_2H_4','H_2','Location','NorthWest');
    h.FontSize = 10;
    legend boxoff;
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    xlabel('{\itU} vs. RHE / V', 'fontsize',f_caption);
    ylabel('\eta_F_a_r_a_d_a_y / %', 'fontsize',f_caption);
    ylim([0 100]);
    xlim([(min(result.GCpotential)+input.UtoRHE-0.1) (max(result.GCpotential)+input.UtoRHE+0.1)]);
    title(strrep(input.resultname, '_', '\_'), 'fontsize',10)
%    if(input.printplot == 1)
%        print(sprintf('%s_FaradayEff.png',input.resultname),'-dpng', '-r600');
%        %print(sprintf('%s_FaradayEff.pdf',input.resultname),'-dpdf');
%    end
end
