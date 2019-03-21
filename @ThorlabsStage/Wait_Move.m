% File: Move_Wait.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 17th Okt 2018

% Description: Waits until current movement is finished

function Move_Wait(thorlabsstage)

	thorlabsstage.deviceNET.Wait(thorlabsstage.TIMEOUTMOVE); % Wait for move to finish

end
