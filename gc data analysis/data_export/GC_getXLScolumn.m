%Licence: GNU General Public License version 2 (GPLv2)
%convert column number to excel column 'letter'
function colstr = GC_getXLScolumn(num)
	colstr = '';
    if num<=0    
       return 
    end
    while num > 0
        m = mod(num-1,26);
        colnum = m+1;
        switch colnum
            case 1
                colchar = 'A';
            case 2
                colchar = 'B';
            case 3
                colchar = 'C';
            case 4
                colchar = 'D';
            case 5
                colchar = 'E';
            case 6
                colchar = 'F';
            case 7
                colchar = 'G';
            case 8
                colchar = 'H';
            case 9
                colchar = 'I';
            case 10
                colchar = 'J';
            case 11
                colchar = 'K';
            case 12
                colchar = 'L';
            case 13
                colchar = 'M';
            case 14
                colchar = 'N';
            case 15
                colchar = 'O';
            case 16
                colchar = 'P';
            case 17
                colchar = 'Q';
            case 18
                colchar = 'R';
            case 19
                colchar = 'S';
            case 20
                colchar = 'T';
            case 21
                colchar = 'U';
            case 22
                colchar = 'V';
            case 23
                colchar = 'W';
            case 24
                colchar = 'X';
            case 25
                colchar = 'Y';
            case 26
                colchar = 'Z';
%            case 0 % for 26
%                colchar = 'Z';               
        end
        colstr = sprintf('%s%s',colchar,colstr);
        num = int32((num-m)/26);
    end
end
