% File: List_Devices.m @ ThorlabsStage
% Auhtor: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Lists the available devices

function serialNumbers = List_Devices(thorlabsstage)  
    
    % thorlabsstage.loaddlls; % Load DLLs
    Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();  % Build device list
    serialNumbersNet = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList(); % Get device list
    serialNumbers=cell(ToArray(serialNumbersNet)); % Convert serial numbers to cell array

end	