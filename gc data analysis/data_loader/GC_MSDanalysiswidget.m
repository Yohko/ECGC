%Licence: GNU General Public License version 2 (GPLv2)
function GC_MSDanalysiswidget()
data = GC_dloadAgilent;
if(~isempty(data))
    S.f = figure; 

    S.dataTIC = data(1).spectrum;
    S.dataTCD = data(2).spectrum;
    S.dataMSD = data(3).spectrum;
    S.dataMSDTIC = data(4).spectrum;
    % create matrix from 'point cloud'
    idx = find(~isnan(S.dataMSD(:,3)) & ~isinf(S.dataMSD(:,3)));
    S.F = scatteredInterpolant(S.dataMSD(idx,1), S.dataMSD(idx,2),S.dataMSD(idx,3));
    min_x = round(min(S.dataMSD(idx,1))*10)/10;
    max_x = round(max(S.dataMSD(idx,1))*10)/10;
    min_y = round(min(S.dataMSD(idx,2))*1)/1;
    max_y = round(max(S.dataMSD(idx,2))*1)/1;
    S.xvec = min_x:0.01:max_x; % 0.01 min 
    S.yvec = min_y:1:max_y; % only full m/z
    [xq, yq] = meshgrid(S.xvec,S.yvec);
    S.MSDinterp = S.F(xq, yq);
    %S.bg = sum(S.MSDinterp(:,1:5),2)/5;

    GC_settings_graph;

    S.ax1 = subplot(1,2,1);
    S.h1=plot(S.dataMSDTIC(:,1),S.dataMSDTIC(:,2),'linewidth', f_line);
    ylabel('counts', 'fontsize',f_caption);
    xlabel('Retention Time / min', 'fontsize',f_caption);
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    title('MSD TIC', 'fontsize',10);
    set(gca, 'units','normalized', 'Position', [0.15, 0.2, 0.35, 0.7]);
    
    S.ax2 = subplot(1,2,2);
    imagesc(S.xvec,S.yvec,S.MSDinterp);
    ylabel('m/z', 'fontsize',f_caption);
    xlabel('Retention Time / min', 'fontsize',f_caption);
    set(gca, 'linewidth', f_line);
    set(gca, 'fontsize', f_caption);
    title('MSD', 'fontsize',10);
    xlim([min(S.dataMSD(:,1)) max(S.dataMSD(:,1))]);
    ylim([min(S.dataMSD(:,2)) max(S.dataMSD(:,2))]);
    set(gca, 'units','normalized', 'Position', [0.6, 0.2, 0.35, 0.7]);

    tmpstr = data(3).name;
    tmpstr = tmpstr(1:end-4);
    sgtitle(strrep(tmpstr, '_', '\_'), 'fontsize',16);
    S.edit_mz = uicontrol('Style','edit',...
                     'units','pix',...
                     'position',[10 0 50 20],...
                     'fontsize',14,...
                     'string','0',...
                     'callback',{@edit_mz_call,S});
end


function edit_mz_call(varargin)
mzedit = varargin{1};
S = varargin{3};
axes(S.ax1);
tmpval = str2double(mzedit.String);
try 
    idx = find(S.yvec == tmpval);
catch
    idx = 1;
end
if(isempty(idx))
   idx = 1;
   mzedit.String = 'error';
end
GC_settings_graph;
plot(S.xvec,S.MSDinterp(idx,:),'linewidth', f_line);
legend(sprintf('m/z = %s',mzedit.String));
ylabel('counts', 'fontsize',f_caption);
xlabel('Retention Time / min', 'fontsize',f_caption);
set(gca, 'linewidth', f_line);
set(gca, 'fontsize', f_caption);
