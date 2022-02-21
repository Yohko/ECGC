%Licence: GNU General Public License version 2 (GPLv2)
function GC_MSDanalysiswidget()
addpath(fullfile( fileparts(mfilename('fullpath')), 'data_loader',filesep));
addpath(fullfile( fileparts(mfilename('fullpath')), 'helper',filesep));

hfigure = struct;
hfigure.h_fig = 400;
hfigure.w_fig = 1200;
hfigure.f_legend = 16;
hfigure.f_axis = 16;
hfigure.f_caption = 16;
hfigure.f_line = 1.5;
hfigure.EICx = [];
hfigure.EICy = [];
hfigure.MZx = [];
hfigure.MZy = [];

set(0,'units','pixels');
pix_screen = get(0,'screensize');

hfigure.figure = uifigure('units','pixel','position',...
    [(pix_screen(3)-hfigure.w_fig)/2 (pix_screen(4)-hfigure.h_fig)/2 hfigure.w_fig hfigure.h_fig],...
    'Resize','off','Name','MSD analysis widget');
set(hfigure.figure, 'MenuBar', 'none');
set(hfigure.figure, 'ToolBar', 'none');

h_bottom = 30;
h_left = 30;
h_top = 20;

hfigure.ax1 =  uiaxes(hfigure.figure);
set(hfigure.ax1,'position', [h_left h_bottom hfigure.w_fig/3-h_left hfigure.h_fig-h_bottom-h_top]);
hfigure.ax2 =  uiaxes(hfigure.figure);
set(hfigure.ax2,'position', [h_left+hfigure.w_fig/3 h_bottom hfigure.w_fig/3-h_left hfigure.h_fig-h_bottom-h_top]);
hfigure.ax3 =  uiaxes(hfigure.figure);
set(hfigure.ax3,'position', [h_left+2*hfigure.w_fig/3 h_bottom hfigure.w_fig/3-h_left hfigure.h_fig-h_bottom-h_top]);

offset = 5;
uilabel(hfigure.figure,...
          'position',[offset 5 30 20],...
          'fontsize',12,...
          'Text','m/z:',...
          'HorizontalAlignment', 'left');
offset = offset + 30;

hfigure.edit_mz = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset 5 50 20],...
                 'fontsize',14,...
                 'Value',0,...
                 'RoundFractionalValues','on', ...
                 'ValueChangedFcn',{@callback_edit_mz});
hfigure.edit_mz.Limits = [0 600];
offset = offset + 55;

uibutton(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'BackgroundColor', [0.9290 0.6940 0.1250], ...
          'FontWeight', 'bold', ...
          'ButtonPushedFcn',{@callback_export_EIC},...
          'Text','export EIC');
offset = offset + 75;

uilabel(hfigure.figure,...
          'position',[offset 5 60 20],...
          'fontsize',12,...
          'Text','Disp. Int.:',...
          'HorizontalAlignment', 'left');
offset = offset + 65;

hfigure.dropdown_EIC = uidropdown(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'Items',{'normal','sqrt','log'},...
          'Value','normal', ...
          'ValueChangedFcn',{@callback_dropdown_EIC});


offset = 1*hfigure.w_fig/3+5;
uilabel(hfigure.figure,...
          'position',[offset 5 30 20],...
          'fontsize',12,...
          'Text','time:',...
          'HorizontalAlignment', 'left');
offset = offset + 30;

hfigure.edit_time = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset 5 50 20],...
                 'fontsize',14,...
                 'Value',0, ...                 
                 'ValueChangedFcn',{@callback_edit_time});
offset = offset + 55;

uibutton(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'BackgroundColor', [0.9290 0.6940 0.1250], ...
          'FontWeight', 'bold', ...
          'ButtonPushedFcn',{@callback_export_MZ},...
          'Text','export m/z');
offset = offset + 75;

uilabel(hfigure.figure,...
          'position',[offset 5 60 20],...
          'fontsize',12,...
          'Text','Disp. Int.:',...
          'HorizontalAlignment', 'left');
offset = offset + 65;

hfigure.dropdown_MZ = uidropdown(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'Items',{'normal','sqrt','log'},...
          'Value','normal', ...
          'ValueChangedFcn',{@callback_dropdown_MZ});



offset = 2*hfigure.w_fig/3+5;
uibutton(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'FontWeight', 'bold', ...
          'FontColor', [0.8500 0.3250 0.0980], ...
          'BackgroundColor', [0.3010 0.7450 0.9330], ...
          'ButtonPushedFcn',{@callback_load_data},...
          'Text','load MSD');
offset = offset + 75;

uilabel(hfigure.figure,...
          'position',[offset 5 60 20],...
          'fontsize',12,...
          'Text','Disp. Int.:',...
          'HorizontalAlignment', 'left');
offset = offset + 65;

hfigure.dropdown_MSD = uidropdown(hfigure.figure,...
          'position',[offset 5 70 20],...
          'fontsize',12,...
          'Items',{'normal','sqrt','log'},...
          'Value','normal', ...
          'ValueChangedFcn',{@callback_dropdown_MSD});
offset = offset + 75;

uibutton(hfigure.figure,...
          'position',[offset 5 100 20],...
          'fontsize',12,...
          'BackgroundColor', [0.9290 0.6940 0.1250], ...
          'FontWeight', 'bold', ...
          'ButtonPushedFcn',{@callback_save_png},...
          'Text','save as png');

% uibutton(hfigure.figure,...
%           'position',[offset 5 100 20],...
%           'fontsize',12,...
%           'ButtonPushedFcn',{@callback_export_MSD},...
%           'Text','export MSD');
% offset = offset + 105;

offset = 5;
hfigure.dropdown_EICmode = uidropdown(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 60 20],...
          'fontsize',12,...
          'Items',{'EIC','TIC'},...
          'Value','EIC', ...
          'ValueChangedFcn',{@callback_dropdown_EICmode});
offset = offset + 65;


uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 30 20],...
          'fontsize',12,...
          'Text','-m/z:',...
          'HorizontalAlignment', 'left');
offset = offset + 30;

hfigure.edit_mzmin = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset hfigure.h_fig-20 30 20],...
                 'fontsize',14,...
                 'Value',0,...
                 'ValueChangedFcn',{@callback_edit_mzmin});
hfigure.edit_mzmin.Limits = [0 2];
offset = offset + 35;

uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 30 20],...
          'fontsize',12,...
          'Text','+m/z:',...
          'HorizontalAlignment', 'left');
offset = offset + 30;

hfigure.edit_mzmax = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset hfigure.h_fig-20 30 20],...
                 'fontsize',14,...
                 'Value',0,...
                 'ValueChangedFcn',{@callback_edit_mzmax});
hfigure.edit_mzmax.Limits = [0 2];
offset = offset + 35;

offset = 1*hfigure.w_fig/3+5;
uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 50 20],...
          'fontsize',12,...
          'Text','BG time:',...
          'HorizontalAlignment', 'left');
offset = offset + 55;

hfigure.edit_bgtime = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset hfigure.h_fig-20 50 20],...
                 'fontsize',14,...
                 'Value',0, ...                 
                 'ValueChangedFcn',{@callback_edit_bgtime});
offset = offset + 55;

uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 50 20],...
          'fontsize',12,...
          'Text','BG sub.:',...
          'HorizontalAlignment', 'left');
offset = offset + 55;

hfigure.dropdown_MZbg = uidropdown(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 70 20],...
          'fontsize',12,...
          'Items',{'none','sub','disp'},...
          'Value','none', ...
          'ValueChangedFcn',{@callback_edit_bgtime});
offset = offset + 75;



uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 15 20],...
          'fontsize',12,...
          'Text','-t:',...
          'HorizontalAlignment', 'left');
offset = offset + 20;

hfigure.edit_tmin = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset hfigure.h_fig-20 30 20],...
                 'fontsize',14,...
                 'Value',0.1,...
                 'ValueChangedFcn',{@callback_edit_tmin});
hfigure.edit_tmin.Limits = [0 2];
offset = offset + 35;

uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 15 20],...
          'fontsize',12,...
          'Text','+t:',...
          'HorizontalAlignment', 'left');
offset = offset + 20;

hfigure.edit_tmax = uieditfield(hfigure.figure,'numeric',...
                 'position',[offset hfigure.h_fig-20 30 20],...
                 'fontsize',14,...
                 'Value',0.1,...
                 'ValueChangedFcn',{@callback_edit_tmax});
hfigure.edit_tmax.Limits = [0 2];
offset = offset + 35;


offset = 2*hfigure.w_fig/3+5;
hfigure.dropdown_MSDmode = uidropdown(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 100 20],...
          'fontsize',12,...
          'Items',{'interp','point'},...
          'Value','point', ...
          'ValueChangedFcn',{@callback_dropdown_MSDmode});
offset = offset + 105;


hfigure.file_name = uilabel(hfigure.figure,...
          'position',[offset hfigure.h_fig-20 hfigure.w_fig/3 20],...
          'fontsize',12,...
          'Text','none',...
          'HorizontalAlignment', 'left');


guidata(hfigure.figure, hfigure);


function callback_edit_mz(varargin)
hfigure = guidata(varargin{1});
plot_EIC(hfigure);


function callback_edit_time(varargin)
hfigure = guidata(varargin{1});
plot_MZ(hfigure);


function callback_edit_bgtime(varargin)
hfigure = guidata(varargin{1});
plot_MZ(hfigure);


function callback_edit_tmin(varargin)
hfigure = guidata(varargin{1});
plot_MZ(hfigure);


function callback_edit_tmax(varargin)
hfigure = guidata(varargin{1});
plot_MZ(hfigure);


function callback_dropdown_MSD(varargin)
hfigure = guidata(varargin{1});
plot_MSD(hfigure);
plot_EIC(hfigure);
plot_MZ(hfigure);

function callback_dropdown_EIC(varargin)
hfigure = guidata(varargin{1});
plot_EIC(hfigure);


function callback_dropdown_MZ(varargin)
hfigure = guidata(varargin{1});
plot_MZ(hfigure);


function callback_dropdown_EICmode(varargin)
hfigure = guidata(varargin{1});
plot_EIC(hfigure);


function callback_edit_mzmin(varargin)
hfigure = guidata(varargin{1});
plot_EIC(hfigure);


function callback_edit_mzmax(varargin)
hfigure = guidata(varargin{1});
plot_EIC(hfigure);


function callback_dropdown_MSDmode(varargin)
hfigure = guidata(varargin{1});
plot_MSD(hfigure);
plot_EIC(hfigure);
plot_MZ(hfigure);


%%
function hfigure = plot_EIC(hfigure)
mzedit = get(hfigure.edit_mz,'Value');
try 
    idxc = find(hfigure.yvec == mzedit);
    idx = find(hfigure.yvec >= mzedit-hfigure.edit_mzmin.Value & hfigure.yvec <= mzedit+hfigure.edit_mzmax.Value);
catch
    idx = 1;
    idxc = idx;
end
if(isempty(idx))
    idx = 1;
    idxc = idx;
end
set(hfigure.edit_mz, 'Value',hfigure.yvec(idxc));
mzedit = get(hfigure.edit_mz,'Value');
switch hfigure.dropdown_EICmode.Value
    case 'TIC'
        hfigure.EICx = hfigure.dataMSDTIC(:,1);
        hfigure.EICy = hfigure.dataMSDTIC(:,2);
    otherwise
        switch hfigure.dropdown_MSDmode.Value
            case 'interp'
                hfigure.EICx = hfigure.xvec;
                hfigure.EICy = sum(hfigure.MSDinterp(idx,:),1);
            case 'point'
                % 1 time
                % 2 mz
                % 3 counts
                idx = find(~isnan(hfigure.dataMSD(:,3)) & ...
                           ~isinf(hfigure.dataMSD(:,3)) & ...
                           hfigure.dataMSD(:,2) >= mzedit-hfigure.edit_mzmin.Value & ...
                           hfigure.dataMSD(:,2) <= mzedit+hfigure.edit_mzmax.Value ...
                          );
                hfigure.EICx = unique(hfigure.dataMSD(idx,1),'sorted');
                hfigure.EICy = zeros(size(hfigure.EICx));
                for ii = 1:length(hfigure.dataMSD(idx,3))
                    jj = find(hfigure.dataMSD(idx(ii),1)==hfigure.EICx);
                    hfigure.EICy(jj) = hfigure.EICy(jj) + hfigure.dataMSD(idx(ii),3);
                end
        end
end
switch hfigure.dropdown_EIC.Value
    case 'sqrt'
        plot(hfigure.ax1,hfigure.EICx,sqrt(hfigure.EICy),'linewidth', hfigure.f_line);
        ylabel(hfigure.ax1,'sqrt(counts)', 'fontsize',hfigure.f_caption);
    case 'log'
        plot(hfigure.ax1,hfigure.EICx,log(hfigure.EICy),'linewidth', hfigure.f_line);
        ylabel(hfigure.ax1,'log(counts)', 'fontsize',hfigure.f_caption);
    otherwise
        plot(hfigure.ax1,hfigure.EICx,hfigure.EICy,'linewidth', hfigure.f_line);
        ylabel(hfigure.ax1,'counts', 'fontsize',hfigure.f_caption);
end
xlabel(hfigure.ax1,'retention time [min]', 'fontsize',hfigure.f_caption);
set(hfigure.ax1, 'linewidth', hfigure.f_line);
set(hfigure.ax1, 'fontsize', hfigure.f_caption);
box(hfigure.ax1,'on');
title(hfigure.ax1,sprintf('m/z = %d',mzedit), 'fontsize',hfigure.f_caption);
guidata(hfigure.figure, hfigure);


%%
function hfigure = plot_MZ(hfigure)
time = get(hfigure.edit_time,'Value');
bgtime = get(hfigure.edit_bgtime,'Value');


try 
    idxc = find(hfigure.xvec >= time);
    idx = find(hfigure.xvec >= time-hfigure.edit_tmin.Value & hfigure.xvec <= time+hfigure.edit_tmax.Value);
catch
    idx = 1;
    idxc = idx;
end
if(isempty(idx))
    idx = 1;
    idxc = idx;
else
     idxc = idxc(1);
end
% BG
try 
    idxc2 = find(hfigure.xvec >= bgtime);
    idx2 = find(hfigure.xvec >= bgtime-hfigure.edit_tmin.Value & hfigure.xvec <= bgtime+hfigure.edit_tmax.Value);
catch
    uialert(hfigure.figure,'bg time not available','error');
    idx2 = 1;
    idxc2 = idx2;
end
if(isempty(idx))
    uialert(hfigure.figure,'bg time not available','error');
    idx2 = 1;
    idxc2 = idx2;
else
    idxc2 = idxc2(1);
end

set(hfigure.edit_time, 'Value',hfigure.xvec(idxc));
set(hfigure.edit_bgtime, 'Value',hfigure.xvec(idxc2));
time = get(hfigure.edit_time,'Value');
bgtime = get(hfigure.edit_bgtime,'Value');

switch hfigure.dropdown_MSDmode.Value
    case 'interp'
        hfigure.MZx = hfigure.yvec;
        hfigure.MZx2 = hfigure.yvec;
        MZy = sum(hfigure.MSDinterp(:,idx),2);
        MZy2 = sum(hfigure.MSDinterp(:,idx2),2);
    case 'point'
        % 1 time
        % 2 mz
        % 3 counts
        idx = find(~isnan(hfigure.dataMSD(:,3)) & ...
                   ~isinf(hfigure.dataMSD(:,3)) & ...
                   hfigure.dataMSD(:,1) >= time-hfigure.edit_tmin.Value & ...
                   hfigure.dataMSD(:,1) <= time+hfigure.edit_tmax.Value ...
                  );
        idx2 = find(~isnan(hfigure.dataMSD(:,3)) & ...
                   ~isinf(hfigure.dataMSD(:,3)) & ...
                   hfigure.dataMSD(:,1) >= bgtime-hfigure.edit_tmin.Value & ...
                   hfigure.dataMSD(:,1) <= bgtime+hfigure.edit_tmax.Value ...
                  );
        hfigure.MZx = unique(hfigure.dataMSD(idx,2),'sorted');
        MZy = zeros(size(hfigure.MZx));
        for ii = 1:length(hfigure.dataMSD(idx,2))
            jj = find(hfigure.dataMSD(idx(ii),2)==hfigure.MZx);
            MZy(jj) = MZy(jj) + hfigure.dataMSD(idx(ii),3);
        end

        hfigure.MZx2 = unique(hfigure.dataMSD(idx2,2),'sorted');
        MZy2 = zeros(size(hfigure.MZx2));
        for ii = 1:length(hfigure.dataMSD(idx2,2))
            jj = find(hfigure.dataMSD(idx2(ii),2)==hfigure.MZx2);
            MZy2(jj) = MZy2(jj) + hfigure.dataMSD(idx2(ii),3);
        end

        % binning
        min_mz = round(min(hfigure.dataMSD(idx,2))*1)/1;
        max_mz = round(max(hfigure.dataMSD(idx,2))*1)/1;
        MZstep = 1;
        MZxvec = min_mz:MZstep:max_mz; % only full m/z
        MZybvec1 = zeros(size(MZxvec));
        MZybvec2 = zeros(size(MZxvec));
        
        for ii = 1:(length(MZxvec))
            idx1 = find(hfigure.MZx >= (MZxvec(ii)-MZstep/2) & hfigure.MZx < (MZxvec(ii)+MZstep/2));
            MZybvec1(ii) = sum(MZy(idx1));
            idx2 = find(hfigure.MZx2 >= (MZxvec(ii)-MZstep/2) & hfigure.MZx2 < (MZxvec(ii)+MZstep/2));
            MZybvec2(ii) = sum(MZy2(idx2));
        end
        MZy = MZybvec1;
        hfigure.MZx = MZxvec;
        MZy2 = MZybvec2;
        hfigure.MZx2 = MZxvec;
end

switch hfigure.dropdown_MZbg.Value
    case 'sub'
        hfigure.MZy = MZy(:)-interp1(hfigure.MZx2(:), MZy2(:), hfigure.MZx(:));
        strx2 = '-BG';
    otherwise
        hfigure.MZy = MZy;
        hfigure.MZy2 = MZy2;
        strx2 = '';
end

switch hfigure.dropdown_MZ.Value
    case 'sqrt'
        bar(hfigure.ax2,hfigure.MZx,sqrt(hfigure.MZy),'FaceColor',[0, 0.4470, 0.7410]);
        strx1 = sprintf('sqrt(counts%s)',strx2);
    case 'log'
        bar(hfigure.ax2,hfigure.MZx,log(hfigure.MZy),'FaceColor',[0, 0.4470, 0.7410]);
        strx1 = sprintf('log(counts%s)',strx2);
    otherwise
        bar(hfigure.ax2,hfigure.MZx,hfigure.MZy,'FaceColor',[0, 0.4470, 0.7410]);
        strx1 = sprintf('counts%s',strx2);
end

switch hfigure.dropdown_MZbg.Value
    case 'disp'
        hold(hfigure.ax2,'on');
        switch hfigure.dropdown_MZ.Value
            case 'sqrt'
                bar(hfigure.ax2,hfigure.MZx2,sqrt(hfigure.MZy2),'FaceColor',[0.8500 0.3250 0.0980],'BarWidth',0.5);
            case 'log'
                bar(hfigure.ax2,hfigure.MZx2,log(hfigure.MZy2),'FaceColor',[0.8500 0.3250 0.0980],'BarWidth',0.5);
            otherwise
                bar(hfigure.ax2,hfigure.MZx2,hfigure.MZy2,'FaceColor',[0.8500 0.3250 0.0980],'BarWidth',0.5);
        end

        hold(hfigure.ax2,'off');
        legend(hfigure.ax2,...
               {sprintf('%.3fmin',time), sprintf('BG %.3fmin',bgtime)}, ...
               'Location', 'best', ...
               'color','none', ...
               'FontSize', 8);
        legend(hfigure.ax2,'boxoff');

end

ylabel(hfigure.ax2,strx1, 'fontsize',hfigure.f_caption);
xlabel(hfigure.ax2,'mass-to-charge [m/z]', 'fontsize',hfigure.f_caption);
set(hfigure.ax2, 'linewidth', hfigure.f_line);
set(hfigure.ax2, 'fontsize', hfigure.f_caption);
box(hfigure.ax2,'on');
%xlim(hfigure.ax2,[10, 30]);
title(hfigure.ax2,sprintf('time = %.3f',time), 'fontsize',hfigure.f_caption);
guidata(hfigure.figure, hfigure);

%%
function hfigure = plot_MSD(hfigure)
switch hfigure.dropdown_MSDmode.Value
    case 'interp'
        switch hfigure.dropdown_MSD.Value
            case 'sqrt'
                imagesc(hfigure.ax3,hfigure.xvec,hfigure.yvec,sqrt(hfigure.MSDinterp));
            case 'log'
                imagesc(hfigure.ax3,hfigure.xvec,hfigure.yvec,log(hfigure.MSDinterp));
            otherwise
                imagesc(hfigure.ax3,hfigure.xvec,hfigure.yvec,hfigure.MSDinterp);
        end
    case 'point'
        idx = find(~isnan(hfigure.dataMSD(:,3)) & ~isinf(hfigure.dataMSD(:,3)));
        switch hfigure.dropdown_MSD.Value
            case 'sqrt'
                scatter(hfigure.ax3,hfigure.dataMSD(idx,1), hfigure.dataMSD(idx,2),5, sqrt(hfigure.dataMSD(idx,3)),'filled');
            case 'log'
                imagesc(hfigure.ax3,hfigure.xvec,hfigure.yvec,log(hfigure.MSDinterp));
                scatter(hfigure.ax3,hfigure.dataMSD(idx,1), hfigure.dataMSD(idx,2),5, log(hfigure.dataMSD(idx,3)),'filled');
            otherwise
                scatter(hfigure.ax3,hfigure.dataMSD(idx,1), hfigure.dataMSD(idx,2),5, hfigure.dataMSD(idx,3),'filled');
        end
end
ylabel(hfigure.ax3,'mass-to-charge [m/z]', 'fontsize',hfigure.f_caption);
xlabel(hfigure.ax3,'retention time [min]', 'fontsize',hfigure.f_caption);
set(hfigure.ax3, 'linewidth', hfigure.f_line);
set(hfigure.ax3, 'fontsize', hfigure.f_caption);
title(hfigure.ax3,'MSD', 'fontsize',hfigure.f_caption);
xlim(hfigure.ax3,[min(hfigure.dataMSD(:,1)) max(hfigure.dataMSD(:,1))]);
ylim(hfigure.ax3,[min(hfigure.dataMSD(:,2)) max(hfigure.dataMSD(:,2))]);

set(hfigure.ax3,'Layer','top');

box(hfigure.ax3,'on');

guidata(hfigure.figure, hfigure);


function [file, path] = select_output_file(name)
filter = {'*.csv';'*.txt';'*.dat';'*.*'};
[file, path] = uiputfile(filter, 'select file to write',name);


function callback_export_EIC(varargin)
hfigure = guidata(varargin{1});
export_xy(hfigure.EICx, ...
          hfigure.EICy, ...
          sprintf('%s_mz_%d',get(hfigure.file_name,'Text'),get(hfigure.edit_mz,'Value')));


function callback_export_MZ(varargin)
hfigure = guidata(varargin{1});
export_xy(hfigure.MZx, ...
          hfigure.MZy, ...
          sprintf('%s_time_%d',get(hfigure.file_name,'Text'),get(hfigure.edit_time,'Value')));


function export_xy(datax, datay, filename)
[file, path] = select_output_file(filename);
if isequal(file,0) || isequal(path,0)
   disp('User clicked Cancel.')
else
    fid=fopen(sprintf('%s%s',path,file), 'w');
    for ii = 1:length(datax)
        fprintf(fid,'%f,%f\n',datax(ii), datay(ii));
    end
    fclose(fid);
end


% function callback_export_MSD(varargin)
% hfigure = guidata(varargin{1});
% [file, path] = select_output_file('MSD');


function callback_save_png(varargin)
hfigure = guidata(varargin{1});
filter = {'*.png'};
[file, path] = uiputfile(filter, 'select file to write',sprintf('%s',get(hfigure.file_name,'Text')));
if isequal(file,0) || isequal(path,0)
   disp('User clicked Cancel.')
else
    %exportapp(hfigure.figure,[path file]);
    exportgraphics(hfigure.figure,sprintf('%s%s',path,file),'Resolution',1200);
end


function callback_load_data(varargin)
hfigure = guidata(varargin{1});
data = GC_dloadAgilent;
if(~isempty(data))
    hfigure.dataTIC = data(get_spectrumidx(data, 'TIC1')).spectrum;
    %hfigure.dataTCD = data(2).spectrum;
    hfigure.dataMSD = data(get_spectrumidx(data, 'MSD1')).spectrum;
    hfigure.dataMSDTIC = data(get_spectrumidx(data, 'MSDTIC1')).spectrum;
    % create matrix from 'point cloud'
    idx = find(~isnan(hfigure.dataMSD(:,3)) & ~isinf(hfigure.dataMSD(:,3)));
    hfigure.F = scatteredInterpolant(hfigure.dataMSD(idx,1), hfigure.dataMSD(idx,2),hfigure.dataMSD(idx,3));
    min_x = round(min(hfigure.dataMSD(idx,1))*10)/10;
    max_x = round(max(hfigure.dataMSD(idx,1))*10)/10;
    min_y = round(min(hfigure.dataMSD(idx,2))*1)/1;
    max_y = round(max(hfigure.dataMSD(idx,2))*1)/1;
    %hfigure.xvec = min_x:0.01:max_x; % 0.01 min
    hfigure.xvec = min_x:0.001:max_x; % 0.005 min 
    hfigure.yvec = min_y:1:max_y; % only full m/z
    [xq, yq] = meshgrid(hfigure.xvec,hfigure.yvec);
    hfigure.MSDinterp = hfigure.F(xq, yq);
    %hfigure.bg = sum(hfigure.MSDinterp(:,1:5),2)/5;
    idx = find(hfigure.MSDinterp < 0);
    hfigure.MSDinterp(idx) = 0;

    % plot EIC
    hfigure = plot_EIC(hfigure);

    % plot mz
    hfigure = plot_MZ(hfigure);

    % plot MSD
    hfigure = plot_MSD(hfigure);

    set(hfigure.file_name,'Text',sprintf('data name: %s',data(get_spectrumidx(data, 'MSD1')).name));
end
guidata(hfigure.figure, hfigure);


function idx = get_spectrumidx(data, str)
idx = -1;
for ii=1:length(data)
    if contains(data(ii).name,str)
        idx = ii;
        return
    end
end
