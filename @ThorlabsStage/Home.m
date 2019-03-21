% File: Home.m
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Moves stage to its home position

function Home(thorlabsstage)              % Home device (must be done before any device move
	
	if thorlabsstage.deviceNET.CanHome
		fprintf('[ThorlabsStage] Homing device.\n');
		workDone = thorlabsstage.deviceNET.InitializeWaitHandler();     % Initialise Waithandler for timeout
		thorlabsstage.deviceNET.Home(workDone);                       % Home devce via .NET interface
		thorlabsstage.deviceNET.Wait(thorlabsstage.TIMEOUTMOVE);                  % Wait for move to finish
		thorlabsstage.Update_Status(); % Update status variables from device
	else
		error('[ThorlabsStage] Cannot home device.');
	end
end