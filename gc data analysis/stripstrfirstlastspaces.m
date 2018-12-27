%Licence: GNU General Public License version 2 (GPLv2)
function str = stripstrfirstlastspaces(str)
    len = length(str);
    for i=1:len
        if(isspace(str(i)))
        else
            str = str(i:end);
            break
        end
    end
    len = length(str);
    for i=1:len
        j = length(str)-i+1;
        if(isspace(str(j)))
        else
            str = str(1:j);
            break
        end
    end
end
