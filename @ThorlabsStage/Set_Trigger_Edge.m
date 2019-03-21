% File: Set_Trigger.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 18th Okt 2018

% Description: Sets the trigger mode of the stage

function Set_Trigger_Edge(thorlabsstage, startPos, endPos, nCycles)

	% Options for trigger mode
	triggerParamsDeviceUnit = thorlabsstage.deviceNET.GetTriggerParamsParams_DeviceUnit;
	triggerParamsDeviceUnit.CycleCount = nCycles;
	triggerParamsDeviceUnit.TriggerPulseWidth = 10;
	triggerParamsDeviceUnit.TriggerCountRev = 1;
	triggerParamsDeviceUnit.TriggerCountFwd = 1; 
	triggerParamsDeviceUnit.TriggerIntervalRev = abs(startPos - endPos);
	triggerParamsDeviceUnit.TriggerIntervalFwd = abs(startPos - endPos);
	triggerParamsDeviceUnit.TriggerStartPositionRev = endPos;
	triggerParamsDeviceUnit.TriggerStartPositionFwd = startPos;
	thorlabsstage.deviceNET.SetTriggerParamsParams_DeviceUnit(triggerParamsDeviceUnit);
end