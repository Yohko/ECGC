%Licence: GNU General Public License version 2 (GPLv2)
function ECdata = GC_EClabASCIIload(fid)
    area = 1;
    areaunit = 'cm²';
    timecode = 0; % for linking EC data with GC data
    h = fgets(fid);
	if(strcmp(h(1:17),'EC-Lab ASCII FILE')==1)
        %'Found additional header'
        h = fgets(fid);
        [headerlines] = strread(h, 'Nb header lines : %d');
        for i=3:headerlines-1
            h = fgets(fid);
            % the time column lists time with reference to "Acquisition
            % started" and not "Technique started"
            if(strfind(h,'Acquisition started on') == 1)
                [month, day, year, hr, minute, seconds] = strread(h, 'Acquisition started on : %d/%d/%d %d:%d:%f');
                % The POSIX time is the number of seconds (including fractional seconds)
                timecode = posixtime(datetime(year,month,day,hr,minute,seconds));
            end
            if(strfind(h,'Electrode surface area :') == 1)
                [area, areaunit] = strread(h, 'Electrode surface area : %f %s');
            end
        end
	else
        %'No additional header'
        fseek(fid,0,'bof');
	end
	h = fgetl(fid);
    columnnames = strsplit(h,'\t')';
    cols = length(columnnames);
    if(isempty(char(columnnames(end))) == 1)
       cols = cols - 1;
    end
    % read the data
    y = textscan(fid,'%f','delimiter','\t','emptyvalue', NaN);
    rows = size(y{1},1)/cols;
    y =[reshape(y{1},[cols,rows])]';
    ECdata = {columnnames; y; timecode; area; areaunit};
end
