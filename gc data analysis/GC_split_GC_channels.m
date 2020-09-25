%Licence: GNU General Public License version 2 (GPLv2)
% extract spectra defined by labels (channel name, m/z etc.) in settings file
function hfigure = GC_split_GC_channels(hfigure)
    CHi = ones(length(hfigure.input.CH),1); % to keep track of spectra
    for ii = 1:size(hfigure.input.spectra,2)
        index = strfind(hfigure.input.spectra(ii).name,'_');
        strtmp = hfigure.input.spectra(ii).name(index(end)+1:end);
        idxnum = find(~isletter(strtmp));
        idxtype = find(isletter(strtmp));
        type = strtmp(idxtype);
        num = strtmp(idxnum);
        for jj = 1:length(hfigure.input.CH)
            if(strcmpi(type,hfigure.input.CH(jj).name) == 1)
                switch hfigure.input.CH(jj).name
                    case 'MSD'
                        idx = find(~isnan(hfigure.input.spectra(ii).spectrum(:,3)) ...
                            & ~isinf(hfigure.input.spectra(ii).spectrum(:,3)) ...
                            & hfigure.input.spectra(ii).spectrum(:,2) < (hfigure.input.CH(jj).mz + hfigure.input.CH(jj).mzplus) ...
                            & hfigure.input.spectra(ii).spectrum(:,2) >= (hfigure.input.CH(jj).mz - hfigure.input.CH(jj).mzminus) ...
                            );
                        tmpspectrum = zeros(length(idx)+1,2);
                        tmptimecount = 1;
                        for ll = 1:length(idx)
                            if(hfigure.input.spectra(ii).spectrum(idx(ll),1)>tmpspectrum(tmptimecount,1))
                                tmptimecount = tmptimecount + 1;
                                tmpspectrum(tmptimecount,1) = hfigure.input.spectra(ii).spectrum(idx(ll),1);
                            end
                            tmpspectrum(tmptimecount,2) = tmpspectrum(tmptimecount,2) + hfigure.input.spectra(ii).spectrum(idx(ll),3);
                        end
                        hfigure.input.CH(jj).spectra(CHi(jj)).spectrum = tmpspectrum(2:tmptimecount,:);
                    otherwise
                        hfigure.input.CH(jj).spectra(CHi(jj)).spectrum = ...
                            hfigure.input.spectra(ii).spectrum;
                end
                hfigure.input.CH(jj).spectra(CHi(jj)).runnum = ...
                    str2double(num);
                hfigure.input.CH(jj).spectra(CHi(jj)).runname = ...
                    hfigure.input.spectra(ii).name(1:index(end)-1);
                hfigure.input.CH(jj).spectra(CHi(jj)).timecode = ...
                    hfigure.input.spectra(ii).timecode;
                CHi(jj) = CHi(jj)+1;
            end
        end
    end
end
