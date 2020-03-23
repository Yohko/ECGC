%Licence: GNU General Public License version 2 (GPLv2)
function spectra = GC_dloadAgilent()
    [FileNamecell,PathName,Fileindex] = uigetfile({'*.d;*.D', 'Agilent GC'},'Select Agilent GC D files','MultiSelect', 'on');
    FileName = char(FileNamecell); % convert from cell to string list
    spectra = struct([]);
    if(Fileindex == 0)
        return;
    end
    for i=1:size(FileName,1)
        [~,name,~] = fileparts(FileName(i,:));
        if ispc
            % windows
            TICfile = stripstrfirstlastspaces(sprintf('%s%s\\tic_front.csv',PathName,FileName(i,:)));
            TCDfile = stripstrfirstlastspaces(sprintf('%s%s\\TCD1A.ch',PathName,FileName(i,:)));
            MSDfile = stripstrfirstlastspaces(sprintf('%s%s\\data.ms',PathName,FileName(i,:)));
        else
            % macos
            TICfile = stripstrfirstlastspaces(sprintf('%s%s/tic_front.csv',PathName,FileName(i,:)));
            TCDfile = stripstrfirstlastspaces(sprintf('%s%s/TCD1A.ch',PathName,FileName(i,:)));
            MSDfile = stripstrfirstlastspaces(sprintf('%s%s/data.ms',PathName,FileName(i,:)));
        end

        fid=fopen(TICfile);
        dataTIC = GC_AgilentloadTICASCII(fid);
        fclose(fid);
        fclose all;

        fid=fopen(TCDfile);
        dataTCD = GC_AgilentloadTCDbin(fid);
        fclose(fid);
        fclose all;

        fid=fopen(MSDfile);
        dataMSD = GC_AgilentloadDATAMS(fid);
        fclose(fid);
        fclose all;

         if i > 1
             spectra = [spectra, struct('name',sprintf('%s_TIC',name),'spectrum',dataTIC(2), 'timecode', dataTIC(1))];
         else
             spectra = struct('name',sprintf('%s_TIC',name),'spectrum',dataTIC(2), 'timecode', dataTIC(1));
         end
         spectra = [spectra, struct('name',sprintf('%s_TCD',name),'spectrum',dataTCD(2), 'timecode', dataTCD(1))];
         spectra = [spectra, struct('name',sprintf('%s_MSD',name),'spectrum',dataMSD(2), 'timecode', dataMSD(1))];
         spectra = [spectra, struct('name',sprintf('%s_MSDTIC',name),'spectrum',dataMSD(3), 'timecode', dataMSD(1))];
    end
end
