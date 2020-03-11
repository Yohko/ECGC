%Licence: GNU General Public License version 2 (GPLv2)
function varargout = GC_GUI(varargin)
% GC_GUI MATLAB code for GC_GUI.fig
%      GC_GUI, by itself, creates a new GC_GUI or raises the existing
%      singleton*.
%
%      H = GC_GUI returns the handle to a new GC_GUI or the handle to
%      the existing singleton*.
%
%      GC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GC_GUI.M with the given input arguments.
%
%      GC_GUI('Property','Value',...) creates a new GC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GC_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GC_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GC_GUI

% Last Modified by GUIDE v2.5 28-Dec-2018 17:10:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GC_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GC_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GC_GUI is made visible.
function GC_GUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GC_GUI (see VARARGIN)
% Choose default command line output for GC_GUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GC_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GC_usersetting
GC_usersetting = 'GC_settings'; % for default settings
GC_init();
global input
loadsamplelist(handles);
set(handles.text_CWD,'String',input.cwd);
set(handles.text_settingfile,'String',GC_usersetting);
BGtypes = {'linear', 'linear+fit', 'multi line'};
set(handles.popupmenu_BGCO,'String',BGtypes);
set(handles.popupmenu_BGCO,'Value',3);
set(handles.popupmenu_BGCH4,'String',BGtypes);
set(handles.popupmenu_BGCH4,'Value',3);
set(handles.popupmenu_BGC2H4,'String',BGtypes);
set(handles.popupmenu_BGC2H4,'Value',3);
set(handles.popupmenu_BGC2H6,'String',BGtypes);
set(handles.popupmenu_BGC2H6,'Value',3);
set(handles.popupmenu_BG2ndCH4,'String',BGtypes);
set(handles.popupmenu_BG2ndCH4,'Value',3);
set(handles.popupmenu_BG2ndCO,'String',BGtypes);
set(handles.popupmenu_BG2ndCO,'Value',3);
set(handles.popupmenu_BGH2O2,'String',BGtypes);
set(handles.popupmenu_BGH2O2,'Value',3);
set(handles.popupmenu_BGPG,'String',BGtypes);
set(handles.popupmenu_BGPG,'Value',3);
set(handles.popupmenu_BGO2,'String',BGtypes);
set(handles.popupmenu_BGO2,'Value',3);
set(handles.popupmenu_BGH2,'String',BGtypes);
set(handles.popupmenu_BGH2,'Value',3);
set(handles.text_about,'String',sprintf('© 2017-2020 Matthias H. Richter v200311a\nMatthias.H.Richter@gmail.com'));



% --- Outputs from this function are returned to the command line.
function varargout = GC_GUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton_calc_Callback(~, ~, handles)
global input
if(isempty(input.samplelist))
else
    samplelist = get(handles.listbox_samplelist,'String');
    plot(1) = get(handles.checkbox_plotpeaks, 'Value');
    %FID
    plot(2) = get(handles.checkbox_plotFIDCO, 'Value');
    plot(3) = get(handles.checkbox_plotFIDCH4, 'Value');
    plot(4) = get(handles.checkbox_plotFIDC2H4, 'Value');
    plot(5) = get(handles.checkbox_plotFIDC2H6, 'Value');
    plot(6) = get(handles.checkbox_plotFIDCH42nd, 'Value');
    plot(7) = get(handles.checkbox_plotFIDCO2nd, 'Value');
    %TCD
    plot(8) = get(handles.checkbox_plotTCDH2O2, 'Value');
    plot(9) = get(handles.checkbox_plotTCDPG, 'Value');
    plot(10) = get(handles.checkbox_plotTCDH2, 'Value');
    plot(11) = get(handles.checkbox_plotTCDO2, 'Value');
    %FID
    BGtype(1) = get(handles.popupmenu_BGCO, 'Value');
    BGtype(2) = get(handles.popupmenu_BGCH4, 'Value');
    BGtype(3) = get(handles.popupmenu_BGC2H4, 'Value');
    BGtype(4) = get(handles.popupmenu_BGC2H6, 'Value');
    BGtype(5) = get(handles.popupmenu_BG2ndCH4, 'Value');
    BGtype(6) = get(handles.popupmenu_BG2ndCO, 'Value');
    %TCD
    BGtype(7) = get(handles.popupmenu_BGH2O2, 'Value');
    BGtype(8) = get(handles.popupmenu_BGPG, 'Value');
    BGtype(9) = get(handles.popupmenu_BGH2, 'Value');
    BGtype(10) = get(handles.popupmenu_BGO2, 'Value');   
    sample_name = sprintf('%s_%s',get(handles.edit_date, 'String'),...
    samplelist{get(handles.listbox_samplelist,'Value')});
    GC_main(sample_name, plot,BGtype);
end


function pushbutton_loadlist_Callback(~, ~, handles)
loadsamplelist(handles);


function loadsamplelist(handles)
global input
GC_load_samplelist();
if(isempty(input.samplelist))
data = '';
else
data = table2cell(input.samplelist(:,1))';
end
set(handles.listbox_samplelist,'String',data);
update_boxes(get(handles.listbox_samplelist,'Value'), handles);


function listbox_samplelist_Callback(hObject, ~, handles)
update_boxes(get(hObject,'Value'), handles);


function update_boxes(id, handles)
global input
if(isempty(input.samplelist))
    set(handles.edit_ID, 'String','');
    set(handles.edit_date, 'String','');
    set(handles.edit_area, 'String','');
    set(handles.edit_desc, 'String','');
    set(handles.edit_U2RHE, 'String','');
    set(handles.edit_GCoffset, 'String','');
    set(handles.edit_GCinttime, 'String','');
    set(handles.checkbox_GCbinning, 'Value',0);
    set(handles.checkbox_GCandEC, 'Value',0);
    set(handles.edit_Ru, 'String','');
    set(handles.edit_compensation, 'String','');
else
    set(handles.edit_ID, 'String',table2array(input.samplelist(id,1)));
    set(handles.edit_date, 'String',num2str(table2array(input.samplelist(id,2))));
    set(handles.edit_area, 'String',table2array(input.samplelist(id,3)));
    set(handles.edit_desc, 'String',table2array(input.samplelist(id,4)));
    set(handles.edit_U2RHE, 'String',table2array(input.samplelist(id,5)));
    set(handles.edit_GCoffset, 'String',table2array(input.samplelist(id,6)));
    set(handles.edit_GCinttime, 'String',table2array(input.samplelist(id,7)));
    set(handles.checkbox_GCbinning, 'Value',table2array(input.samplelist(id,8)));
    set(handles.edit_Ru, 'String',table2array(input.samplelist(id,9)));
    set(handles.edit_compensation, 'String',table2array(input.samplelist(id,10)));
    set(handles.checkbox_GCandEC, 'Value',table2array(input.samplelist(id,11)));
end


function pushbutton_saveentry_Callback(~, ~, handles)
save_entry(handles)


function pushbutton_newEntry_Callback(~, ~, handles)
newEntry(handles);


function newEntry(handles)
global input
ret = GC_new(''); % prompt will be handled in the function
if(isempty(ret))
else
    %ret
    input.samplelist = [input.samplelist; ret];
    data = table2cell(input.samplelist(:,1))';
    set(handles.listbox_samplelist,'String',data);
    update_boxes(get(handles.listbox_samplelist,'Value'), handles);
    save_entry(handles);
    save_list_to_disk();
end


function save_entry(handles)
global input
id = get(handles.listbox_samplelist,'Value');
input.samplelist(id,1) = {get(handles.edit_ID, 'String')};
input.samplelist(id,2) = {str2double(get(handles.edit_date, 'String'))};
input.samplelist(id,3) = {str2double(get(handles.edit_area, 'String'))};
input.samplelist(id,4) = {get(handles.edit_desc, 'String')};
input.samplelist(id,5) = {str2double(get(handles.edit_U2RHE, 'String'))};
input.samplelist(id,6) = {str2double(get(handles.edit_GCoffset, 'String'))};
input.samplelist(id,7) = {str2double(get(handles.edit_GCinttime, 'String'))};
input.samplelist(id,8) = {get(handles.checkbox_GCbinning, 'Value')};
input.samplelist(id,9) = {str2double(get(handles.edit_Ru, 'String'))};
input.samplelist(id,10) = {str2double(get(handles.edit_compensation, 'String'))};
input.samplelist(id,11) = {get(handles.checkbox_GCandEC, 'Value')};


function save_list_to_disk()
global input
sample_database = input.samplelist;
save('sample_database.mat','sample_database');


function pushbutton5_Callback(~, ~, ~)
save_list_to_disk();


function changeCWD(handles)
global input
newFolder = uigetdir();
if(newFolder == 0)   
else
    cd(newFolder);
    input.cwd = newFolder;
    set(handles.text_CWD,'String',input.cwd);
    loadsamplelist(handles);
end


function changesettingfile(handles)
global GC_usersetting
file = uigetfile('./*.m','Select a File');
if(file == 0)
    
else
    [~,name,~]= fileparts(file);
    set(handles.text_settingfile,'String',name);
    GC_usersetting = name;
end


function pushbutton_help_Callback(~, ~, ~)
msgbox(['(1) Choose working directory (and settings).' newline ...
        '(2) Add new dataset with "New Entry".' newline  ...
        '(3) Press calculate.' newline ...
        'Edits are not permanent if they are not first saved (Save edit (tmp) to enble them and later do disk.' newline ...
        'If an entry is deleted its not deleted from the database on the disk until the database is saved to disk.' newline ...
        'Reload button reloads database from disk.' newline ...
        'See Tooltips for further information.'],'Help')

    
function pushbutton_changeCQD_Callback(~, ~, handles)
changeCWD(handles);


function pushbutton_changesettings_Callback(~, ~, handles)
changesettingfile(handles);


function pushbutton_delete_Callback(~, ~, handles)
delete_entry(handles);


function delete_entry(handles)
global input
if(isempty(input.samplelist))
else
    itemtodelete = get(handles.listbox_samplelist,'Value');
	input.samplelist([itemtodelete],:) = [];
    if(size(input.samplelist,1)>0)
        data = table2cell(input.samplelist(:,1))';
        if ~(itemtodelete<=size(input.samplelist,1) && itemtodelete>1)
            itemtodelete = 1;
        end
        set(handles.listbox_samplelist,'Value',itemtodelete);
    else
        data = '';
    end
    set(handles.listbox_samplelist,'String',data);
    update_boxes(get(handles.listbox_samplelist,'Value'), handles);
end
