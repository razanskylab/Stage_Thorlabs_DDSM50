% File: Update_Status.m @ Thorlabsstage

function Update_Status(thorlabsstage)

	thorlabsstage.isConnected=logical(thorlabsstage.deviceNET.IsConnected());   % update isconncted flag
	thorlabsstage.serialnumber=char(thorlabsstage.deviceNET.DeviceID);          % update serial number
	thorlabsstage.controllername=char(thorlabsstage.deviceInfoNET.Name);        % update controleller name          
	thorlabsstage.controllerdescription=char(thorlabsstage.deviceInfoNET.Description);  % update controller description
	thorlabsstage.stagename=char(thorlabsstage.motorSettingsNET.DeviceSettingsName);    % update stagename
	% thorlabsstage.pos=System.Decimal.ToDouble(thorlabsstage.deviceNET.Position);   % Read current device position

end