% File: Connect.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Opens a connection to the device.

function Connect(thorlabsstage, serialNo)  % Connect device
    
    fprintf('[ThorlabsStage] Connecting to device\n');
    thorlabsstage.List_Devices();    % Use this call to build a device list in case not invoked beforehand
    
    if ~thorlabsstage.isConnected

        % Check if serial numebr is correct
        switch(serialNo(1:2))
            case '28'   % Serial number corresponds to a KBD101
                thorlabsstage.deviceNET= ...
                    Thorlabs.MotionControl.KCube.BrushlessMotorCLI.KCubeBrushlessMotor.CreateKCubeBrushlessMotor(serialNo);   
            otherwise % Serial number is not a PRM1Z8 or a K10CR1
                error('Stage not recognised');
        end     

        % Conenct to device
        thorlabsstage.deviceNET.ClearDeviceExceptions(); % Clear device exceptions via .NET interface
        thorlabsstage.deviceNET.Connect(serialNo); % Connect to device via .NET interface, 
        try
            if ~thorlabsstage.deviceNET.IsSettingsInitialized() % Wait for IsSettingsInitialized via .NET interface
                thorlabsstage.deviceNET.WaitForSettingsInitialized(thorlabsstage.TIMEOUTSETTINGS);
            end
            if ~thorlabsstage.deviceNET.IsSettingsInitialized() % Cannot initialise device
                warning(['Unable to initialise device ',char(serialNo)]);
            end
            thorlabsstage.deviceNET.StartPolling(thorlabsstage.TPOLLING);   % Start polling via .NET interface
            thorlabsstage.motorSettingsNET  =thorlabsstage.deviceNET.LoadMotorConfiguration(serialNo); % Get motorSettings via .NET interface
            thorlabsstage.currentDeviceSettingsNET = thorlabsstage.deviceNET.MotorDeviceSettings;     % Get currentDeviceSettings via .NET interface
            thorlabsstage.deviceInfoNET=thorlabsstage.deviceNET.GetDeviceInfo();                    % Get deviceInfo via .NET interface
            % MotDir = Thorlabs.MotionControl.GenericMotorCLI.Settings.RotationDirections.Forwards; % MotDir is enumeration for 'forwards'
            % h.currentDeviceSettingsNET.Rotation.RotationDirection=MotDir;   % Set motor direction to be 'forwards#
        catch % Cannot initialise device
            error(['Catch: Unable to initialise device ',char(serialNo)]);
        end
    else % Device is already connected
        error('Device is already connected.')
    end
    thorlabsstage.Update_Status();   % Update status variables from device

    if ~thorlabsstage.isConnected
        error('Could not connect to device');
    end
end