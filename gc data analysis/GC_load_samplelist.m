%Licence: GNU General Public License version 2 (GPLv2)
function GC_load_samplelist()
    global input
    try
        load('sample_database.mat'); % load old list
        input.samplelist = sample_database;
    catch
         input.samplelist = table(); % create a new one
    end
end
