%Licence: GNU General Public License version 2 (GPLv2)
%load Agilent GC D files (MSD, TCD, FID)
function spectra = GC_dloadAgilent()
    [FileNamecell,PathName,Fileindex] = GC_uigetdir('','Select Agilent GC D files',{'*.d;*.D', 'Agilent GC'});
    spectra = struct([]);
    if(Fileindex == 0)
        return;
    end
    spectra = [];
    for i=1:length(FileNamecell)
        [~,name,~] = fileparts(FileNamecell{i});
        Files=dir(fullfile(sprintf('%s%s%s',PathName,FileNamecell{i},filesep),'*1A.ch'));
        if(~isempty(Files))
            CH1name = Files(1).name(1:end-3);
        else
            Files=dir(fullfile(sprintf('%s%s%s',PathName,FileNamecell{i},filesep),'*2A.ch'));
            if(~isempty(Files))
                CH1name = Files(1).name(1:end-3);
            else
                CH1name = 'notfound';
            end
        end
        Files=dir(fullfile(sprintf('%s%s%s',PathName,FileNamecell{i},filesep),'*1B.ch'));
        if(~isempty(Files))
            CH2name = Files(1).name(1:end-3);
        else
            Files=dir(fullfile(sprintf('%s%s%s',PathName,FileNamecell{i},filesep),'*2B.ch'));
            if(~isempty(Files))
                CH2name = Files(1).name(1:end-3);
            else
                CH2name = 'notfound';
            end
        end
        TICfile = sprintf('%s%s%stic_front.csv',PathName,FileNamecell{i},filesep);
        CH1file = sprintf('%s%s%s%s.ch',PathName,FileNamecell{i},filesep,CH1name);
        CH2file = sprintf('%s%s%s%s.ch',PathName,FileNamecell{i},filesep,CH2name);
        MSDfile = sprintf('%s%s%sdata.ms',PathName,FileNamecell{i},filesep);

        fid=fopen(TICfile);
        dataTIC = GC_AgilentloadTICASCII(fid);
        if(fid ~= -1)
            fclose(fid);
            fclose all;
        end
        if isempty(dataTIC)
            TICfile = sprintf('%s%s%stic_back.csv',PathName,FileNamecell{i},filesep);
            fid=fopen(TICfile);
            dataTIC = GC_AgilentloadTICASCII(fid);
            if(fid ~= -1)
                fclose(fid);
                fclose all;
            end
        end
        
        fid=fopen(CH1file);
        dataCH1 = GC_AgilentloadCHbin(fid);
        if(fid ~= -1)
            fclose(fid);
            fclose all;
        end
        
        fid=fopen(CH2file);
        dataCH2 = GC_AgilentloadCHbin(fid);
        if(fid ~= -1)
            fclose(fid);
            fclose all;
        end
        
        fid=fopen(MSDfile);
        dataMSD = GC_AgilentloadDATAMS(fid);
        if(fid ~= -1)
            fclose(fid);
            fclose all;
        end

        if ~isempty(dataTIC)
            spectra = [spectra, struct('name',sprintf('%s_TIC%d',name,i),'spectrum',dataTIC(2), 'timecode', dataTIC(1))];
        end       
        if ~isempty(dataCH1)
            spectra = [spectra, struct('name',sprintf('%s_%s%d',name,CH1name(isletter(CH1name)),i),'spectrum',dataCH1(2), 'timecode', dataCH1(1))];
        end
        if ~isempty(dataCH2)
            spectra = [spectra, struct('name',sprintf('%s_%s%d',name,CH2name(isletter(CH2name)),i),'spectrum',dataCH2(2), 'timecode', dataCH2(1))];
        end
        if ~isempty(dataMSD)
            spectra = [spectra, struct('name',sprintf('%s_MSD%d',name,i),'spectrum',dataMSD(2), 'timecode', dataMSD(1))];
            spectra = [spectra, struct('name',sprintf('%s_MSDTIC%d',name,i),'spectrum',dataMSD(3), 'timecode', dataMSD(1))];
            spectra = [spectra, struct('name',sprintf('%s_MSDBPC%d',name,i),'spectrum',dataMSD(4), 'timecode', dataMSD(1))];
            spectra = [spectra, struct('name',sprintf('%s_MSDBPCMz%d',name,i),'spectrum',dataMSD(5), 'timecode', dataMSD(1))];
            %spectra = [spectra, struct('name',sprintf('%s_unknown',name),'spectrum',dataMSD(6), 'timecode', dataMSD(1))];
        end
    end
end
