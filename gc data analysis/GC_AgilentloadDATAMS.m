%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_AgilentloadDATAMS(fid)
    % Agilent MassHunter
    data = [];    
    fseek(fid,4,'bof');
    strlen = fread(fid,1,'uint8');
    datatype = convertCharsToStrings(char(fread(fid,strlen,'char*1')));
    % sample description
    fseek(fid,24,'bof');
    strlen = fread(fid,1,'uint8');
    filename = convertCharsToStrings(char(fread(fid,strlen,'char*1')));

    fseek(fid,178,'bof');
    strlen = fread(fid,1,'uint8');
    timestr = convertCharsToStrings(char(fread(fid,strlen,'char*1')));

    fseek(fid,208,'bof');
    strlen = fread(fid,1,'uint8');
    convertCharsToStrings(char(fread(fid,strlen,'char*1'))); % GCMS

    fseek(fid,228,'bof');
    strlen = fread(fid,1,'uint8');
    methodstr = convertCharsToStrings(char(fread(fid,strlen,'char*1')));

    fseek(fid,448,'bof'); % GCMS
    strrep(convertCharsToStrings(char(fread(fid,168/2,'char*1',1))),char(00),'');
    % method directory
    fseek(fid,616,'bof');
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % name of method
    fseek(fid,1126,'bof');
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % tune file directory
    fseek(fid,1636,'bof');
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % MSD tune file
    fseek(fid,2146,'bof');
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % sample description
    fseek(fid,4236,'bof');
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');

    % get offset to data
    fseek(fid,266,'bof');
    dataoffset = 2*fread(fid,1,'uint16','ieee-be')-2;
    % get number of scans
    switch datatype
        case 'GC / MS Data File'
            fseek(fid,322,'bof');
        otherwise
            fseek(fid,280,'bof');
    end
    nscans = fread(fid,1,'uint16','ieee-be');
    
    % MSD data
    fseek(fid,dataoffset,'bof');
    points = 0;
    TIC = zeros(nscans,2);
    BPC = zeros(nscans,2);
    unknown = zeros(nscans,1);
    BPCMz = zeros(nscans,2);
    datams = zeros(0,3);    
    fseek(fid,dataoffset,'bof');
    for ii = 1:nscans     
        % get total of bytes in this scan        
        bytestoread = fread(fid,1,'uint16','ieee-be');
        if(bytestoread ~= 0)
            lastscan = ii+1;
            % calculate position for next scan
            nextpos = ftell(fid) - 2 + 2 * bytestoread;
            % get time, 60000 --> ms to min
            TIC(ii,1) = fread(fid,1,'uint32','ieee-be') / 60000;
            %unknown(ii) = fread(fid,1,'uint16','ieee-be');           
            unknown(ii) = fread(fid,1,'uint32','ieee-be');
            %fread(fid,1,'uint16','ieee-be');
            npts = fread(fid,1,'uint32','ieee-be'); % points for this scan
            points = points + npts; % total MSD points
            BPCMz(ii,2) = fread(fid,1,'uint16','ieee-be');
            BPC(ii,2) = fread(fid,1,'uint16','ieee-be'); % base peak chromatogram??
            % ions and counts
            datapoints = fread(fid,2*npts,'uint16','ieee-be');
            datams(((points-npts)+1):points,2) = datapoints(1:2:(end)); % m/z
            datams(((points-npts)+1):points,3) = datapoints(2:2:end); % counts
            datams(((points-npts)+1):points,1) = TIC(ii,1);
            % what are the next 6bytes?
            %disp(ftell(fid))
            %disp('6bytes at end')
            %fread(fid,1,'uint16','ieee-be')
            fseek(fid,nextpos-4,'bof');
            TIC(ii,2) = fread(fid,1,'uint32','ieee-be');
            fseek(fid,nextpos,'bof'); % goto next scan
        else
            break
        end
    end
    
    datams(:,2) = datams(:,2)/20;
    BPCMz(:,2) = BPCMz(:,2)/20;
    datams(:,3) = bitand(datams(:,3), 16383,'uint16').*8.^ bitshift(datams(:,3),-14,'uint16');
    BPC(:,2) = bitand(BPC(:,2), 16383,'uint16').*8.^ bitshift(BPC(:,2),-14,'uint16');
    BPC(:,1) = TIC(:,1);
    BPCMz(:,1) = TIC(:,1);
    TIC = TIC(1:(lastscan-1),:);
    BPC = BPC(1:(lastscan-1),:);
    BPCMz = BPCMz(1:(lastscan-1),:);
    unknown = unknown(1:(lastscan-1));
    
    %% return data
    timecodes = textscan(timestr,'%s');
    day = str2double(timecodes{1}{1});
    year = 2000+str2double(timecodes{1}{3});
    tmpstr = timecodes{1}{4};
    hr = str2double(tmpstr(1:2));
    minute = str2double(tmpstr(4:5));
    seconds = 0;
    month = 0;
    switch timecodes{1}{5}
        case 'pm'
            hr = hr+12;
        case 'am'
            if(hr == 12)
                hr = 0;
            end
    end
    switch timecodes{1}{2}
        case 'Jan'
            month = 1;
        case 'Feb'
            month = 2;
        case 'Mar'
            month = 3;
        case 'Apr'
            month = 4;
        case 'May'
            month = 5;
        case 'Jun'
            month = 6;
        case 'Jul'
            month = 7;
        case 'Aug'
            month = 8;
        case 'Sep'
            month = 9;
        case 'Oct'
            month = 10;
        case 'Nov'
            month = 11;
        case 'Dec'
            month = 12;
        otherwise
            disp('Unknown Month');
            disp(timecodes{1}{3});
    end
    timecode = posixtime(datetime(year,month,day,hr,minute,seconds));
    data = {timecode; datams; TIC; BPC; BPCMz; unknown};
end
