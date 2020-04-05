%Licence: GNU General Public License version 2 (GPLv2)
function hfigure = GC_split_TCD_FID(hfigure)
    specsize = size(hfigure.input.spectra(1).spectrum,1);
    hfigure.input.CH1 = zeros(specsize,size(hfigure.input.spectra,2)/2);
    hfigure.input.CH2 = zeros(specsize,size(hfigure.input.spectra,2)/2);
    hfigure.input.tR = hfigure.input.spectra(1).spectrum(:,1);
    hfigure.input.runnum = zeros(size(hfigure.input.spectra,2)/2,1);
    hfigure.input.runname = string(zeros(size(hfigure.input.spectra,2)/2,1));
    hfigure.input.timecodes = zeros(size(hfigure.input.spectra,2)/2,1);

    CH2i = 1;
    CH1i = 1;
    for i = 1:size(hfigure.input.spectra,2)
        index = strfind(hfigure.input.spectra(i).name,'_');
        strtmp = hfigure.input.spectra(i).name(index(end)+1:end);
        type = strtmp(1:3);
        num = strtmp(4:end);
        if(strcmpi(type,hfigure.input.ch2name) == 1)
            hfigure.input.CH2(:,CH2i) = hfigure.input.spectra(i).spectrum(1:specsize,2);
            CH2i = CH2i+1;
        elseif(strcmpi(type,hfigure.input.ch1name) == 1)
            hfigure.input.CH1(:,CH1i) = hfigure.input.spectra(i).spectrum(1:specsize,2);
            hfigure.input.runnum(CH1i) = str2double(num);
            hfigure.input.runname(CH1i) = hfigure.input.spectra(i).name(1:index(end)-1);
            hfigure.input.timecodes(CH1i) = hfigure.input.spectra(i).timecode;
            CH1i = CH1i+1;
        end
    end
end
