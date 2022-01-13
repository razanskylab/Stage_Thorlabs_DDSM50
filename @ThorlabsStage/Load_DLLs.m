% File: Load_DLLs.m @ ThorlabsStage.m
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Loads the DLLs required for stage control.

function Load_DLLs(thorlabsstage) % Load DLLs

    if ~exist(thorlabsstage.DEVICEMANAGERCLASSNAME, 'class')
        try   % Load in DLLs if not already loaded
            fprintf('[ThorlabsStage] Loading general DLLs... ');
            NET.addAssembly([thorlabsstage.MOTORPATHDEFAULT, thorlabsstage.DEVICEMANAGERDLL]);
            NET.addAssembly([thorlabsstage.MOTORPATHDEFAULT, thorlabsstage.GENERICMOTORDLL]);
            NET.addAssembly([thorlabsstage.MOTORPATHDEFAULT, thorlabsstage.BRUSHLESSMOTORDLL]);
            fprintf("done!\n"); 
        catch % DLLs did not load
            error('Unable to load .NET assemblies')
        end
    end    

    if ~exist(thorlabsstage.BRUSHLESSMOTORCLASSNAME, 'class')
        try   % Load in DLLs if not already loaded
            fprintf('[ThorlabsStage] Loading DLLs for brushless motor... ');
            NET.addAssembly([thorlabsstage.MOTORPATHDEFAULT, thorlabsstage.BRUSHLESSMOTORDLL]); 
            fprintf("done!\n");
        catch % DLLs did not load
            error('Unable to load .NET assemblies')
        end
    end
end