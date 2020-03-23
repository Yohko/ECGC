%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_AgilentloadDATAMS(fid)
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
    fseek(fid,1126,'bof'); % 616 + 510
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % tune file directory
    fseek(fid,1636,'bof'); % 616 + 510 + 510
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % MSD tune file
    fseek(fid,2146,'bof'); % 616 + 510 + 510 + 510
    strrep(convertCharsToStrings(char(fread(fid,510/2,'char*1',1))),char(00),'');
    % sample description
    fseek(fid,4236,'bof'); % 616 + 510 + 510 + 510
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
    pointvector = zeros(nscans+1,1); % points for each scan (for each time point)
    TIC = zeros(nscans,2);
    datams = zeros(0,3);    
    fseek(fid,dataoffset,'bof');
	for ii = 1:nscans
        % get the position of the next scan
        npos = ftell(fid) + 2 * fread(fid,1,'uint16','ieee-be');
        % keep a running total of how many measurements
        points = points + (npos - ftell(fid) - 26) / 4;
        pointvector(ii+1) = points;
        % get time, 60000 --> ms to min
        TIC(ii,1) = fread(fid,1,'uint32','ieee-be') / 60000;
        % what are these 12 bytes??
        %disp(ftell(fid))
        fseek(fid,ftell(fid)+12,'bof');
        npts = pointvector(ii+1)-pointvector(ii);
        lastscan = ii+1;
        if(npts<0)
            lastscan = ii;
            break
        else
            % ions and counts
            datapoints = fread(fid,2*npts,'uint16','ieee-be');
            datams((pointvector(ii)+1):(pointvector(ii+1)),2) = datapoints(1:2:(end)); % m/z
            datams((pointvector(ii)+1):pointvector(ii+1),3) = datapoints(2:2:end); % counts
            datams((pointvector(ii)+1):pointvector(ii+1),1) =  TIC(ii,1);
            % what are the next 6bytes?
            %disp(ftell(fid))
            %disp('6bytes at end')
            %fread(fid,3,'uint16','ieee-be')
            fseek(fid,npos-4,'bof');
            TIC(ii,2) = fread(fid,1,'uint32','ieee-be');
        end
        fseek(fid,npos,'bof'); % goto next scan
	end
    
	datams(:,2) = datams(:,2)/20;
    datams(:,3) = bitand(datams(:,3), 16383,'uint16').*8.^ bitshift(datams(:,3),-14,'uint16');
    TIC = TIC(1:(lastscan-1),:);
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
	data = {timecode; datams; TIC};
end
