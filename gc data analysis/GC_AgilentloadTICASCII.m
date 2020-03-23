%Licence: GNU General Public License version 2 (GPLv2)
function data = GC_AgilentloadTICASCII(fid)
    timecode = 0; 
    h = fgets(fid);
    timecodes = textscan(h,'%s');
    day = str2double(timecodes{1}{2});
    year = 2000+str2double(timecodes{1}{4});
    tmpstr = timecodes{1}{5};
    hr = str2double(tmpstr(1:2));
    minute = str2double(tmpstr(4:5));
    seconds = 0;
    month = 0;
    switch timecodes{1}{6}
        case 'pm'
            hr = hr+12;
        case 'am'
            if(hr == 12)
                hr = 0;
            end
    end
    switch timecodes{1}{3}
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
    fgets(fid); % 'Start of data points'
    y = textscan(fid,'%f','delimiter',',','emptyvalue', NaN);
    rows = size(y{1},1)/2;
    y =[reshape(y{1},[2,rows])]';
    data = {timecode; y};
end
