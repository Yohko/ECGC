%Licence: GNU General Public License version 2 (GPLv2)
function samplelist = GC_load_samplelist()
    try
        load('sample_database.mat','sample_database'); % load old list
        samplelist = sample_database;
    catch
         samplelist = table(); % create a new one
    end
end
