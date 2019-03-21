% File: Reset.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Resets stage.

function Reset(thorlabsstage)    % Reset device
    thorlabsstage.deviceNET.ClearDeviceExceptions();  % Clear exceptions via .NET interface
	thorlabsstage.deviceNET.ResetConnection(thorlabsstage.serialnumber); % Reset connection via .NET interface
end