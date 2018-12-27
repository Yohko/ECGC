%Licence: GNU General Public License version 2 (GPLv2)
function GC_split_TCD_FID()
    global input
    specsize = size(input.spectra(1).spectrum,1);

    input.FID = zeros(specsize,size(input.spectra,2)/2);
    input.TCD = zeros(specsize,size(input.spectra,2)/2);
    input.tR = input.spectra(1).spectrum(:,1);
    input.runnum = zeros(size(input.spectra,2)/2,1);
    input.runname = string(zeros(size(input.spectra,2)/2,1));
    input.timecodes = zeros(size(input.spectra,2)/2,1);

    TCDi = 1;
    FIDi = 1;
    for i = 1:size(input.spectra,2)
        index = strfind(input.spectra(i).name,'_');
        strtmp = input.spectra(i).name(index(end)+1:end);
        type = strtmp(1:3);
        num = strtmp(4:end);
        if(strcmpi(type,'TCD') == 1)
            input.TCD(:,TCDi) = input.spectra(i).spectrum(1:specsize,2);
            TCDi = TCDi+1;
        elseif(strcmpi(type,'FID') == 1)
            input.FID(:,FIDi) = input.spectra(i).spectrum(1:specsize,2);
            input.runnum(FIDi) = str2num(num);
            input.runname(FIDi) = input.spectra(i).name(1:index(end)-1);
            input.timecodes(FIDi) = input.spectra(i).timecode;
            FIDi = FIDi+1;
        end
    end
end
