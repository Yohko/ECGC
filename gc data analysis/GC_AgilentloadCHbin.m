%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_AgilentloadCHbin(fid)
    if(fid ~= -1)
        CHtype = get_Agilent_CH_type(fid);
        switch CHtype
            case '2' %GC MS
                data = [];
            case '30' % ADC LC
                data = [];
            case '31' % UV spect
                data = [];
            case '8' % GC A Chemstation
                data = read_8(fid);
            case '81' % GC A2 Chemstation
                data = read_81(fid);
            case '179' % GC B 
                data = read_179(fid);
            case '180' % GC B2
                data = [];
            case '181' % GC B3
                data = [];
            case '130' % ADC LC2
                data = [];
            case '131' % ADC UV2
                data = [];
            otherwise
                data = [];
        end
    else
        data = [];
    end
end


function type = get_Agilent_CH_type(fid)
    fseek(fid,0,'bof');
    len = fread(fid,1,'uint8');
    type =convertCharsToStrings(fread(fid,len,'*char',0));
end

%%
function data = read_179(fid)
    fseek(fid,24,'bof');
    CSfileinfo.sample_name0 = read_str(fid, 1);

    fseek(fid,86,'bof');
    CSfileinfo.sample_description0 = read_str(fid, 1);

    fseek(fid,208,'bof');
    CSfileinfo.instrument_model0 = read_str(fid, 1);
    fseek(fid,218,'bof');
    CSfileinfo.instrument_name0 = read_str(fid, 1);

    fseek(fid,252,'bof');
    CSfileinfo.sequence_line = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,254,'bof');
    CSfileinfo.vial = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,256,'bof');
    CSfileinfo.injection = fread(fid,1,'uint16', 'ieee-be');
    
    fseek(fid,260,'bof');
    CSfileinfo.tic_offset = fread(fid,1,'uint32', 'ieee-be');

    fseek(fid,264,'bof');
    CSfileinfo.data_offset = (fread(fid,1,'int32', 'ieee-be')-1) * 512;
    
    fseek(fid,278,'bof');
    CSfileinfo.scans = fread(fid,1,'uint32', 'ieee-be');
    
    fseek(fid,282,'bof');
    CSfileinfo.timestart = fread(fid,1,'single', 'ieee-be')/ 60000; % ms to min
    fseek(fid,286,'bof');
    CSfileinfo.timeend = fread(fid,1,'single', 'ieee-be')/ 60000; % ms to min
   
    fseek(fid,326,'bof');
    CSfileinfo.CHtype = read_str(fid, 2); %179 again

    fseek(fid,347,'bof');
    CSfileinfo.filetype = read_str(fid, 2);

    fseek(fid,858,'bof');
    CSfileinfo.sample_name = read_str(fid, 2);

    fseek(fid,1369,'bof');
    CSfileinfo.sample_description = read_str(fid, 2);

    fseek(fid,1880,'bof');
    CSfileinfo.acq_operator = read_str(fid, 2);
    
    fseek(fid,2391,'bof');
    CSfileinfo.datestr = read_str(fid, 2);

    fseek(fid,2492,'bof');
    CSfileinfo.instrument_model = read_str(fid, 2);

    fseek(fid,2533,'bof');
    CSfileinfo.instrument_name = read_str(fid, 2);

    fseek(fid,2574,'bof');
    CSfileinfo.acq_method = read_str(fid, 2);

    fseek(fid,3089,'bof');
    CSfileinfo.programname = read_str(fid, 2);

    fseek(fid,4125,'bof');
    CSfileinfo.datarate = fread(fid,1,'uint8');
    fseek(fid,4134,'bof');
    CSfileinfo.sigstep_version = fread(fid,1,'int32', 'ieee-be');

    fseek(fid,4172,'bof');
    CSfileinfo.y_unit = read_str(fid, 2);

    fseek(fid,4213,'bof');
    CSfileinfo.devsig_info = read_str(fid, 2);

    fseek(fid,4724,'bof');
    CSfileinfo.sigstep_shift = fread(fid,1,'double', 'ieee-be');
    fseek(fid,4732,'bof');
    CSfileinfo.sigstep_step = fread(fid,1,'double', 'ieee-be');
    
    fseek(fid,CSfileinfo.data_offset,'bof');
    CSfileinfo.data_offset2 = fread(fid,1,'int32', 'ieee-be');

    % data
    % jump to beginning of data (6144)
    fseek(fid,CSfileinfo.data_offset+CSfileinfo.data_offset2,'bof');
    
    
    yaxis = fread(fid,'double');
    %Masshunter display the raw values without sig scaling
    %yaxis = yaxis*sigstep_step+sigstep_shift;
    
    xaxis = linspace(CSfileinfo.timestart,CSfileinfo.timeend,length(yaxis));
    y(:,1) = xaxis;
    y(:,2) = yaxis;

    %DD MMM YY HH:MM PM    
    timecode = to_timecode(CSfileinfo.datestr);
    data = {timecode; y};
    %CSfileinfo
end

%%
function data = read_8(fid)
    CSfileinfo = [];

    fseek(fid,4,'bof'); % 4
    CSfileinfo.filetype = read_str(fid, 1);
    fseek(fid,24,'bof');
    CSfileinfo.sample_name = read_str(fid, 1);
    fseek(fid,86,'bof');
    CSfileinfo.sample_description = read_str(fid, 1);

    fseek(fid,148,'bof');
    CSfileinfo.acq_operator = read_str(fid, 1);

    fseek(fid,178,'bof');
    CSfileinfo.datestr = read_str(fid, 1);
    timecode = to_timecode(CSfileinfo.datestr);
    fseek(fid,208,'bof');
    CSfileinfo.instrument_model = read_str(fid, 1);
    fseek(fid,218,'bof');
    CSfileinfo.instrument_name = read_str(fid, 1);
    fseek(fid,228,'bof');
    CSfileinfo.acq_method = read_str(fid, 1);
    
    fseek(fid,250,'bof');
    CSfileinfo.CHtype = fread(fid,1,'uint16', 'ieee-be'); %8 again

    fseek(fid,252,'bof');
    CSfileinfo.sequence_line = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,254,'bof');
    CSfileinfo.vial = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,256,'bof');
    CSfileinfo.injection = fread(fid,1,'uint16', 'ieee-be');

    fseek(fid,264,'bof');
    CSfileinfo.data_offset = (fread(fid,1,'int32', 'ieee-be')-1) * 512;
    
    fseek(fid,278,'bof');
    CSfileinfo.scans = fread(fid,1,'uint32', 'ieee-be');

    fseek(fid,282,'bof');
    CSfileinfo.timestart = fread(fid,1,'int32', 'ieee-be')/60000; % ms to min
    fseek(fid,286,'bof');
    CSfileinfo.timeend = fread(fid,1,'int32', 'ieee-be')/60000; % ms to min
    
    fseek(fid,532,'bof');
    CSfileinfo.datarate = fread(fid,1,'uint16', 'ieee-be')*10; % check!
    datapoints = (CSfileinfo.timeend-CSfileinfo.timestart)*60*CSfileinfo.datarate-1;

    fseek(fid,542,'bof');
    CSfileinfo.sigstep_version = fread(fid,1,'int32', 'ieee-be');
    switch CSfileinfo.sigstep_version
        case 1
            disp('found 1, check factors')
            CSfileinfo.sigstep_shift = -6.83534921656507e-06;
            CSfileinfo.sigstep_step = 1.33321110058305;
        case 2
            %disp('found 2')
            % calculated via linear fit
            CSfileinfo.sigstep_shift = -6.83534921656507e-06;
            CSfileinfo.sigstep_step = 1.33321110058305;
           % 1.33321110058296
            % 1.33321110047553
        case 3
            disp('found 3, check factors')
            CSfileinfo.sigstep_shift = -6.83534921656507e-06;
            CSfileinfo.sigstep_step = 1.33321110058305;
        otherwise
            fseek(fid,636,'bof');
            CSfileinfo.sigstep_shift = fread(fid,1,'double', 'ieee-be');
            fseek(fid,644,'bof');
            CSfileinfo.sigstep_step = fread(fid,1,'double', 'ieee-be');
    end

    fseek(fid,580,'bof');
    CSfileinfo.y_unit = read_str(fid, 1);
%    fseek(fid,597,'bof');
%    CSfileinfo.devsig_info = read_str(fid, 2);

	fseek(fid,CSfileinfo.data_offset,'bof');
    rawdata = zeros(round(datapoints),1);
    counter = 0;
    
    rawval = 0;
    while ~feof(fid)
        raw1 = fread(fid,1,'int16', 'ieee-be');
        if ~isempty(raw1)
            for i =1:bitand(raw1, 4095, 'int16')
                raw2 = fread(fid,1,'int16', 'ieee-be');
                if ~isempty(raw2)
                    if raw2 ~= -32768
                        rawval = rawval + raw2;
                    else
                        rawval = fread(fid,1,'int32', 'ieee-be');
                    end
                else
                    break
                end
                counter = counter + 1;
                rawdata(counter) = rawval;
            end
        end
    end
    n = length(rawdata);
    % openlab exports this xaxis
    xaxis = (CSfileinfo.timestart+linspace(0,(n-1),n)/CSfileinfo.datarate/60); % sec to min
    % not this
    %xaxis = linspace(CSfileinfo.timestart,CSfileinfo.timeend,n);
    yaxis = rawdata*CSfileinfo.sigstep_step+CSfileinfo.sigstep_shift;
    y(:,1) = xaxis;
    y(:,2) = yaxis;
    data = {timecode; y};
    %CSfileinfo
end

%%
function data = read_81(fid)
    CSfileinfo = [];
    
    fseek(fid,4,'bof');
    CSfileinfo.filetype = read_str(fid, 1);
    fseek(fid,24,'bof');
    CSfileinfo.sample_name = read_str(fid, 1);
    fseek(fid,86,'bof');
    CSfileinfo.sample_description = read_str(fid, 1);
    fseek(fid,148,'bof');
    CSfileinfo.acq_operator = read_str(fid, 1);
    fseek(fid,178,'bof');
    CSfileinfo.datestr = read_str(fid, 1);
    timecode = to_timecode(CSfileinfo.datestr);
    fseek(fid,208,'bof');
    CSfileinfo.instrument_model = read_str(fid, 1);
    fseek(fid,218,'bof');
    CSfileinfo.instrument_name = read_str(fid, 1);
    fseek(fid,228,'bof');
    CSfileinfo.acq_method = read_str(fid, 1);

    fseek(fid,250,'bof');
    CSfileinfo.CHtype = fread(fid,1,'uint16', 'ieee-be'); %81 again

    fseek(fid,252,'bof');
    CSfileinfo.sequence_line = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,254,'bof');
    CSfileinfo.vial = fread(fid,1,'uint16', 'ieee-be');
    fseek(fid,256,'bof');
    CSfileinfo.injection = fread(fid,1,'uint16', 'ieee-be');

    fseek(fid,264,'bof');
    CSfileinfo.data_offset = (fread(fid,1,'int32', 'ieee-be')-1) * 512;

    fseek(fid,278,'bof');
    CSfileinfo.scans = fread(fid,1,'uint32', 'ieee-be');
    
    fseek(fid,282,'bof');
    CSfileinfo.timestart = fread(fid,1,'single', 'ieee-be')/60000; % ms to min
    fseek(fid,286,'bof');
    CSfileinfo.timeend = fread(fid,1,'single', 'ieee-be')/60000; % ms to min
    
    fseek(fid,532,'bof');
    CSfileinfo.datarate = fread(fid,1,'uint16', 'ieee-be');
    datapoints = (CSfileinfo.timeend-CSfileinfo.timestart)*60*CSfileinfo.datarate;
    
    fseek(fid,542,'bof');
    CSfileinfo.sigstep_version = fread(fid,1,'int32', 'ieee-be');

    fseek(fid,580,'bof');
    CSfileinfo.y_unit = read_str(fid, 1);
%    fseek(fid,597,'bof');
%    CSfileinfo.devsig_info = read_str(fid, 2);
    fseek(fid,636,'bof');
    CSfileinfo.sigstep_shift = fread(fid,1,'double', 'ieee-be');
    fseek(fid,644,'bof');
    CSfileinfo.sigstep_step = fread(fid,1,'double', 'ieee-be');
    
	fseek(fid,CSfileinfo.data_offset,'bof');
    rawdata = zeros(round(datapoints),1);
    rawdelta = 0;
    counter = 0;
    
    while ~feof(fid)
        raw1 = fread(fid,1,'int16', 'ieee-be');
        if ~isempty(raw1)
            if raw1 == 32767
                raw1 = fread(fid,1,'int32', 'ieee-be');
                raw2 = fread(fid,1,'uint16', 'ieee-be');
                rawdelta = 0;
                counter = counter + 1;
                rawdata(counter) = raw1 * 65534+raw2;
            else
                rawdelta = rawdelta + raw1;
                counter = counter + 1;
                rawdata(counter) = rawdata(counter-1) + rawdelta;
            end
        end
    end
    n = length(rawdata);
    % openlab exports xaxis as this
    xaxis = (CSfileinfo.timestart+linspace(0,(n-1),n)/CSfileinfo.datarate/60);
    yaxis = rawdata*CSfileinfo.sigstep_step+CSfileinfo.sigstep_shift;

    y(:,1) = xaxis;
    y(:,2) = yaxis;
    data = {timecode; y};
    %CSfileinfo
end


function text = read_str(fid, numchars)
    strlen = fread(fid,1,'uint8');
    if numchars == 1
        text = convertCharsToStrings(fread(fid,strlen,'uint8=>char','ieee-le'));
    elseif numchars == 2
        text = convertCharsToStrings(fread(fid,strlen,'uint16=>char','ieee-le'));
    end
end


function timecode = to_timecode(datestr)
    if contains(datestr,'/')
        % M/DD/YY h:mm:ss PM"
        t = datetime(datestr,'InputFormat',"M/dd/yy h:mm:ss a");
    else
        % DD MMM YY HH:MM PM
        t = datetime(datestr,'InputFormat',"dd MMM yy h:m a");
    end
    timecode = posixtime(t);
end
