% File: Disconnect.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Closes connection to the stage.

function Disconnect(thorlabsstage) % Disconnect device     
    fprintf(['[ThorlabsStage] Disconnecting device ',thorlabsstage.serialnumber, '... ']);
    thorlabsstage.isConnected = thorlabsstage.deviceNET.IsConnected(); % Update isconnected flag via .NET interface
    if thorlabsstage.isConnected
        try
            thorlabsstage.deviceNET.StopPolling();  % Stop polling device via .NET interface
            thorlabsstage.deviceNET.Disconnect();   % Disconnect device via .NET interface
        catch
            error(['Unable to disconnect device ',thorlabsstage.serialnumber]);
        end
        thorlabsstage.isConnected=false;  % Update internal flag to say device is no longer connected
    else % Cannot disconnect because device not connected
        error('Device not connected, so how should I dosconnect it?.')
    end
    fprintf("done!\n");
end