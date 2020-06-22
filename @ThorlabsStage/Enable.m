% File: Enable.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14.05.2020

% Description enables stage.

function Enable(ts)

	if ~ts.isEnabled
		ts.deviceNET.EnableDevice();
		% Check if it actually worked
		if ~ts.isEnabled
			error('Could not enable device (isEnabled is false).');
		end
	end

end