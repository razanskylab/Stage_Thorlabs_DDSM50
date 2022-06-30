% File: Move_No_Wait.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 17th Okt 2018

% Description: Initializes movmenet without waiting with return.

function Move_No_Wait(thorlabsstage, pos)

	try
      workDone=thorlabsstage.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
      thorlabsstage.deviceNET.MoveTo(pos, workDone); % Move devce to position via .NET interface
  	catch % Device faile to move
      error(['Unable to Move device ',thorlabsstage.serialnumber,' to ',num2str(pos)]);
  	end
end 