% File: Reset.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Resets stage.

function Reset(ts) % Reset device
  ts.deviceNET.ClearDeviceExceptions(); % Clear exceptions via .NET interface
	ts.deviceNET.ResetConnection(ts.serialnumber); % Reset connection via .NET interface
	ts.deviceNET.ResetStageToDefaults();
end