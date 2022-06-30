% File: Connect.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Opens a connection to the device.

function Connect(ts, serialNo)  % Connect device
    
    ts.List_Devices(); % build a device list
    
    if ~ts.isConnected % only do if not connected yet
        fprintf('[ThorlabsStage] Connecting to device %s... ', serialNo)
        tStart = tic();

        % Check if serial numebr is correct
        switch(serialNo(1:2))
            case '28'   % Serial number corresponds to a KBD101
                ts.deviceNET= ...
                    Thorlabs.MotionControl.KCube.BrushlessMotorCLI.KCubeBrushlessMotor.CreateKCubeBrushlessMotor(serialNo);   
            otherwise % Serial number is not a PRM1Z8 or a K10CR1
                error('Stage not recognised');
        end     

        % Conenct to device
        ts.deviceNET.ClearDeviceExceptions(); % Clear device exceptions via .NET interface
        ts.deviceNET.Connect(serialNo); % Connect to device via .NET interface, 
        try
            if ~ts.deviceNET.IsSettingsInitialized() % Wait for IsSettingsInitialized via .NET interface
                ts.deviceNET.WaitForSettingsInitialized(ts.TIMEOUTSETTINGS);
            end
            if ~ts.deviceNET.IsSettingsInitialized() % Cannot initialise device
                warning(['Unable to initialise device ',char(serialNo)]);
            end
            ts.deviceNET.StartPolling(ts.TPOLLING);   % Start polling via .NET interface
            ts.motorSettingsNET  =ts.deviceNET.LoadMotorConfiguration(serialNo); % Get motorSettings via .NET interface
            ts.currentDeviceSettingsNET = ts.deviceNET.MotorDeviceSettings;     % Get currentDeviceSettings via .NET interface
            ts.deviceInfoNET=ts.deviceNET.GetDeviceInfo();                    % Get deviceInfo via .NET interface
            % MotDir = Thorlabs.MotionControl.GenericMotorCLI.Settings.RotationDirections.Forwards; % MotDir is enumeration for 'forwards'
            % h.currentDeviceSettingsNET.Rotation.RotationDirection=MotDir;   % Set motor direction to be 'forwards#
        catch % Cannot initialise device
            error(['Catch: Unable to initialise device ', char(serialNo)]);
        end
        fprintf('done after %.1f sec!\n', toc(tStart));
    else % Device is already connected
        error('Device is already connected.')
    end
    ts.Update_Status();   % Update status variables from device

    if ~ts.isConnected
        error('Could not connect to device');
    end
end