%Licence: GNU General Public License version 2 (GPLv2)
function [FileName,PathName,Fileindex] = GC_uigetdir(start_path, dialog_title, filter)
    % slecting multiple directories
    import javax.swing.JFileChooser;
    if nargin == 0 || isempty(start_path) || start_path == 0
        start_path = pwd;
    end
    dir_chooser = javaObjectEDT('javax.swing.JFileChooser', start_path);
    dir_chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    if nargin > 1
        dir_chooser.setDialogTitle(dialog_title);
    end
    dir_chooser.setMultiSelectionEnabled(true);
    status = dir_chooser.showOpenDialog([]);
    DIRcounter = 0;
    if status == JFileChooser.APPROVE_OPTION
        selectedDIR = dir_chooser.getSelectedFiles();
        PathName{size(selectedDIR, 1)}=[];
        FileName{size(selectedDIR, 1)}=[];
        for i=1:size(selectedDIR, 1)
            tmpPathName = char(selectedDIR(i).getAbsolutePath);
            [filepath,name,ext] = fileparts(tmpPathName);
            if ~isempty(regexp(ext,'\.(D)','match','ignorecase'))
                DIRcounter = DIRcounter + 1;
                FileName{DIRcounter} = sprintf('%s%s',name,ext);
                PathName{DIRcounter} = filepath;
            end
        end
        if DIRcounter
            FileName = FileName(1:DIRcounter);
            PathName = sprintf('%s%s',char(PathName(1)),filesep);
            Fileindex = 1;
        else
            FileName = 0;
            PathName = 0;
            Fileindex = 0;
        end
    elseif status == JFileChooser.CANCEL_OPTION
        FileName = 0;
        PathName = 0;
        Fileindex = 0;
    else
        error('Error occured while selecting folders.');
    end
end
