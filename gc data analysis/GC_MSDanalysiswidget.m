%Licence: GNU General Public License version 2 (GPLv2)
function GC_MSDanalysiswidget()
addpath(fullfile( fileparts(mfilename('fullpath')), 'data_loader',filesep));
addpath(fullfile( fileparts(mfilename('fullpath')), 'helper',filesep));


hfigure = struct;
hfigure.h_fig = 400;
hfigure.w_fig = 800;
hfigure.f_legend = 16;
hfigure.f_axis = 16;
hfigure.f_caption = 16;
hfigure.f_line = 1.5;
hfigure.EICx = [];
hfigure.EICy = [];

set(0,'units','pixels');
pix_screen = get(0,'screensize');

hfigure.figure = uifigure('units','pixel','position',...
    [(pix_screen(3)-hfigure.w_fig)/2 (pix_screen(4)-hfigure.h_fig)/2 hfigure.w_fig hfigure.h_fig],...
    'Resize','off','Name','MSD analysis widget');
set(hfigure.figure, 'MenuBar', 'none');
set(hfigure.figure, 'ToolBar', 'none');

h_bottom = 30;
h_left = 30;

hfigure.ax1 =  uiaxes(hfigure.figure);
set(hfigure.ax1,'position', [h_left h_bottom hfigure.w_fig/2-h_left hfigure.h_fig-h_bottom]);
hfigure.ax2 =  uiaxes(hfigure.figure);
set(hfigure.ax2,'position', [h_left+hfigure.w_fig/2 h_bottom hfigure.w_fig/2-h_left hfigure.h_fig-h_bottom]);


uilabel(hfigure.figure,...
          'position',[5 5 30 20],...
          'fontsize',12,...
          'Text','m/z:',...
          'HorizontalAlignment', 'left');

hfigure.edit_mz = uieditfield(hfigure.figure,'numeric',...
                 'position',[35 5 50 20],...
                 'fontsize',14,...
                 'Value',0,...
                 'RoundFractionalValues','on', ...
                 'ValueChangedFcn',{@callback_edit_mz});
hfigure.edit_mz.Limits = [0 600];

uibutton(hfigure.figure,...
          'position',[100 5 100 20],...
          'fontsize',12,...
          'ButtonPushedFcn',{@callback_load_data},...
          'Text','load MSD');

uibutton(hfigure.figure,...
          'position',[205 5 100 20],...
          'fontsize',12,...
          'ButtonPushedFcn',{@callback_export_EIC},...
          'Text','export EIC');

% uibutton(hfigure.figure,...
%           'position',[310 5 100 20],...
%           'fontsize',12,...
%           'ButtonPushedFcn',{@callback_export_MSD},...
%           'Text','export MSD');

hfigure.file_name = uilabel(hfigure.figure,...
          'position',[415 5 hfigure.w_fig-415 20],...
          'fontsize',12,...
          'Text','',...
          'HorizontalAlignment', 'left');

guidata(hfigure.figure, hfigure);


function callback_edit_mz(varargin)
hfigure = guidata(varargin{1});
mzedit = get(hfigure.edit_mz,'Value');
try 
    idx = find(hfigure.yvec == mzedit);
catch
    uialert(hfigure.figure,'m/z not available','error');
    idx = 1;
end
if(isempty(idx))
    uialert(hfigure.figure,'m/z not available','error');
    idx = 1;
end
set(hfigure.edit_mz, 'Value',hfigure.yvec(idx));
mzedit = get(hfigure.edit_mz,'Value');
hfigure.EICx = hfigure.xvec;
hfigure.EICy = hfigure.MSDinterp(idx,:);
plot(hfigure.ax1,hfigure.EICx,hfigure.EICy,'linewidth', hfigure.f_line);

format_ax1(hfigure)
legend(hfigure.ax1,sprintf('m/z = %d',mzedit));
legend(hfigure.ax1,'boxoff');
title(hfigure.ax1,'EIC', 'fontsize',10);
guidata(hfigure.figure, hfigure);


function format_ax1(hfigure)
ylabel(hfigure.ax1,'counts', 'fontsize',hfigure.f_caption);
xlabel(hfigure.ax1,'Retention Time / min', 'fontsize',hfigure.f_caption);
set(hfigure.ax1, 'linewidth', hfigure.f_line);
set(hfigure.ax1, 'fontsize', hfigure.f_caption);


function [file, path] = select_output_file(name)
filter = {'*.csv';'*.txt';'*.dat';'*.*'};
[file, path] = uiputfile(filter, 'select file to write',name);


function callback_export_EIC(varargin)
hfigure = guidata(varargin{1});
[file, path] = select_output_file(sprintf('%s_mz_%d',get(hfigure.file_name,'Text'),get(hfigure.edit_mz,'Value')));
if isequal(file,0) || isequal(path,0)
   disp('User clicked Cancel.')
else
    fid=fopen(sprintf('%s%s',path,file), 'w');
    for ii = 1:length(hfigure.EICx)
        fprintf(fid,'%s,%s\n',hfigure.EICx(ii), hfigure.EICx(ii));
    end
    fclose(fid);
end


% function callback_export_MSD(varargin)
% hfigure = guidata(varargin{1});
% [file, path] = select_output_file('MSD');


function callback_load_data(varargin)
hfigure = guidata(varargin{1});
data = GC_dloadAgilent;
if(~isempty(data))
    hfigure.dataTIC = data(1).spectrum;
    hfigure.dataTCD = data(2).spectrum;
    hfigure.dataMSD = data(3).spectrum;
    hfigure.dataMSDTIC = data(4).spectrum;
    % create matrix from 'point cloud'
    idx = find(~isnan(hfigure.dataMSD(:,3)) & ~isinf(hfigure.dataMSD(:,3)));
    hfigure.F = scatteredInterpolant(hfigure.dataMSD(idx,1), hfigure.dataMSD(idx,2),hfigure.dataMSD(idx,3));
    min_x = round(min(hfigure.dataMSD(idx,1))*10)/10;
    max_x = round(max(hfigure.dataMSD(idx,1))*10)/10;
    min_y = round(min(hfigure.dataMSD(idx,2))*1)/1;
    max_y = round(max(hfigure.dataMSD(idx,2))*1)/1;
    hfigure.xvec = min_x:0.01:max_x; % 0.01 min 
    hfigure.yvec = min_y:1:max_y; % only full m/z
    [xq, yq] = meshgrid(hfigure.xvec,hfigure.yvec);
    hfigure.MSDinterp = hfigure.F(xq, yq);
    %hfigure.bg = sum(hfigure.MSDinterp(:,1:5),2)/5;
    
    hfigure.EICx = hfigure.dataMSDTIC(:,1);
    hfigure.EICy = hfigure.dataMSDTIC(:,2);
    plot(hfigure.ax1,hfigure.EICx,hfigure.EICy,'linewidth', hfigure.f_line);
    title(hfigure.ax1,'TIC', 'fontsize',10);
    format_ax1(hfigure);
    
    box(hfigure.ax1,'on');
    imagesc(hfigure.ax2,hfigure.xvec,hfigure.yvec,hfigure.MSDinterp);
    ylabel(hfigure.ax2,'m/z', 'fontsize',hfigure.f_caption);
    xlabel(hfigure.ax2,'Retention Time / min', 'fontsize',hfigure.f_caption);
    set(hfigure.ax2, 'linewidth', hfigure.f_line);
    set(hfigure.ax2, 'fontsize', hfigure.f_caption);
    title(hfigure.ax2,'MSD', 'fontsize',10);
    xlim(hfigure.ax2,[min(hfigure.dataMSD(:,1)) max(hfigure.dataMSD(:,1))]);
    ylim(hfigure.ax2,[min(hfigure.dataMSD(:,2)) max(hfigure.dataMSD(:,2))]);
    box(hfigure.ax2,'on');

    set(hfigure.file_name,'Text',data(3).name);

end
guidata(hfigure.figure, hfigure);
