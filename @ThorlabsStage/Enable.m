function Enable(thorlabsstage)

	if ~thorlabsstage.isEnabled
		thorlabsstage.deviceNET.EnableDevice;
	end

	% Check if it actually worked
	if ~thorlabsstage.isEnabled
		error('[ThorlabsStage] Could not enable device.');
	end

end