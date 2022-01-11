%Licence: GNU General Public License version 2 (GPLv2)
function y = GC_linoffset_asym_Gauss(x, a0, a1, a2, a3, offset, slope)
    % from Anal. Chem. 1994, 66, 1294-1301
    % ft = fittype('asym_Gauss(x, a0, a1, a2, a3)');
    % a0: peak area
    % a1: elution time
    % a2: width of gaussian
    % a3: exponential damping term
    y = GC_asym_Gauss(x, a0, a1, a2, a3) ...    
      + offset+slope*x;
end
