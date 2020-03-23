%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_AgilentloadTCDbin(fid)
    fseek(fid,282,'bof');
    starttime = fread(fid,1,'single','ieee-be')/ 60000;
    endtime = fread(fid,1,'single','ieee-be')/ 60000;
    % 
	fseek(fid,326,'bof');
    strlen = fread(fid,1,'uint8');
    version = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    % filetype
	fseek(fid,347,'bof');
    strlen = fread(fid,1,'uint8');
    filetype = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    % filename
	fseek(fid,858,'bof');
    strlen = fread(fid,1,'uint8');
    filename = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    % date and time
	fseek(fid,2391,'bof');
    strlen = fread(fid,1,'uint8');
    timecodes = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    %model number
	fseek(fid,2492,'bof');
    strlen = fread(fid,1,'uint8');
    instrumentmodel = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    %instrument
	fseek(fid,2533,'bof');
    strlen = fread(fid,1,'uint8');
    instrumentname = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    %method file
	fseek(fid,2574,'bof');
    strlen = fread(fid,1,'uint8');
    methodname = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

	fseek(fid,3089,'bof');
    strlen = fread(fid,1,'uint8');
    programname = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));
    fseek(fid,4125,'bof');
    datarate = fread(fid,1,'uint8'); % datarate?, yes in Hz
	%y-unit?? 
	fseek(fid,4172,'bof');
    strlen = fread(fid,1,'uint8');
    instrumentmodel = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));

    fseek(fid,4213,'bof');
    strlen = fread(fid,1,'uint8');
    signalname = convertCharsToStrings(char(fread(fid,strlen,'char*1',1)));
    % data
    fseek(fid,6144,'bof'); % jump to beginning of data
    yaxis = fread(fid,'double');
    ftell(fid);
    xaxis = linspace(starttime,endtime,length(yaxis));
    y(:,1) = xaxis;
    y(:,2) = yaxis;
    % data
%     fseek(fid,6152,'bof'); % jump to beginning of data
%     yaxis = fread(fid,'double');
%     ftell(fid);
%     xaxis = linspace(0,1/datarate/60*(length(yaxis)-1),length(yaxis));
%     y(:,1) = xaxis;
%     y(:,2) = yaxis;
    %
    timecodes = textscan(timecodes,'%s');
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
	data = {timecode; y};
end
