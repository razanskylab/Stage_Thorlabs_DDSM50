% File: Home.m
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Moves stage to its home position

function Home(ts)              % Home device (must be done before any device move
	
	if ts.deviceNET.CanHome
		fprintf('[ThorlabsStage] Homing device.\n');
		workDone = ts.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
		ts.deviceNET.Home(workDone); % Home devce via .NET interface
		ts.deviceNET.Wait(ts.TIMEOUTMOVE); % Wait for move to finish
		ts.Update_Status(); % Update status variables from device

		% check if homing was successfull
		if ~ts.isHomed
			error('Homing was not successfull');
		end
	else
		error('[ThorlabsStage] Cannot home device.');
	end

	
end