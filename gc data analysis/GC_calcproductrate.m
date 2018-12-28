%Licence: GNU General Public License version 2 (GPLv2)
function GC_calcproductrate()
    global result input cal
    
    CA_flowout = cell2mat(result.CAdata(5));
    
    input.flowrate = mean(CA_flowout);
    input.hr = input.headspacevol/input.flowrate/60*1000;

    result.H2ppm = (result.TCD_H2+cal.H2_offset)/cal.H2_factor;
    result.H2uM = result.H2ppm/24.5;
    result.H2umol = result.H2uM*input.headspacevol;
    result.H2umolhr = result.H2umol/input.hr;

    result.O2ppm = (result.TCD_O2+cal.O2_offset)/cal.O2_factor;
    result.O2uM = result.O2ppm/24.5;
    result.O2umol = result.O2uM*input.headspacevol;
    result.O2umolhr = result.O2umol/input.hr;

    result.COppm = (result.FID_CO+cal.CO_offset)/cal.CO_factor;
    result.COuM = result.COppm/24.5;
    result.COumol = result.COuM*input.headspacevol;
    result.COumolhr = result.COumol/input.hr;

    result.CH4ppm = (result.FID_CH4+cal.CH4_offset)/cal.CH4_factor;
    result.CH4uM = result.CH4ppm/24.5;
    result.CH4umol = result.CH4uM*input.headspacevol;
    result.CH4umolhr = result.CH4umol/input.hr;

    result.C2H4ppm = (result.FID_C2H4+cal.C2H4_offset)/cal.C2H4_factor;
    result.C2H4uM = result.C2H4ppm/24.5;
    result.C2H4umol = result.C2H4uM*input.headspacevol;
    result.C2H4umolhr = result.C2H4umol/input.hr;

    result.C2H6ppm = (result.FID_C2H6+cal.C2H6_offset)/cal.C2H6_factor;
    result.C2H6uM = result.C2H6ppm/24.5;
    result.C2H6umol = result.C2H6uM*input.headspacevol;
    result.C2H6umolhr = result.C2H6umol/input.hr;
end
