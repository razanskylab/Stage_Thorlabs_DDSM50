% File: Stop.m
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 15th Okt 2018

% Description: Stops movement of the stage.

function Stop(thorlabsstage)

    thorlabsstage.deviceNET.Stop(thorlabsstage.TIMEOUTMOVE); % Stop motor movement via.NET interface
    thorlabsstage.Update_Status();            % Update status variables from device

end