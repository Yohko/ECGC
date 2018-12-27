%Licence: GNU General Public License version 2 (GPLv2)
function GCdata=GC_SRIGCload(fid)
    for i=1:18 %ignore first 18 lines
        fgetl(fid);
    end 
    % line 19, date
    h=fgets(fid);
    [month, day, year] = strread(h, '<DATE>=%d-%d-%d');
    % line 20, time
    h=fgets(fid);
	[hr, minute, seconds] = strread(h, '<TIME>=%d:%d:%d');
    % line 21, sampling rate
    h=fgets(fid);
    [rate] =strread(h, '<RATE>=%dHz');
    % line 22, # of data points
    h=fgets(fid);
    [size] = strread(h, '<SIZE>=%d'); 
    for i=23:25 % ignore  lines
        fgetl(fid);
    end    
    % timecode for linking GC data with EC data
    timecode = posixtime(datetime(year,month,day,hr,minute,seconds));
    % data contains two columns
    % first column: raw data
    % second colum: some background was substracted from the raw data in
    % PeakSimple (we don't use this one as we calculate our own background
    % later)
    y = textscan(fid,'%f','delimiter',',','emptyvalue', NaN);
    y =[reshape(y{1},[2,size])]';
    y1=[0:1/rate/60:1/rate/60*(size-1)]';
    y1(:,2)=y(:,1)/1000;
    GCdata= {timecode; y1};
end
