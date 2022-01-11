%Licence: GNU General Public License version 2 (GPLv2)
function y = GC_asym_Gauss(x, a0, a1, a2, a3)
    % from Anal. Chem. 1994, 66, 1294-1301
    % ft = fittype('asym_Gauss(x, a0, a1, a2, a3)');
    % a0: peak area
    % a1: elution time
    % a2: width of gaussian
    % a3: exponential damping term
    a2 = a2/2;
    y = a0/2/a3*exp(a2^2/2/a3^2 + (a1 - x)/a3) ...
        .*(erf((x-a1)/(sqrt(2)*a2) - a2/sqrt(2)/a3) + 1);
end
