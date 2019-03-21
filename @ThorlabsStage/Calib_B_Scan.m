function output = Calib_B_Scan(thorlabsstage, posstart, posend)


	matrix = zeros(3,100000);

	thorlabsstage.Home;

	thorlabsstage.pos = posstart;
	thorlabsstage.vel = 10;

	thorlabsstage.Move_No_Wait(posend);
	tic
	counter = 1;
	while thorlabsstage.deviceNET.IsDeviceBusy
		matrix(1,counter) = toc;
		matrix(2,counter) = System.Decimal.ToDouble(thorlabsstage.deviceNET.DevicePosition);
		matrix(3,counter) = toc;
		counter = counter + 1;
	end

	output = matrix(:,1:counter);


end