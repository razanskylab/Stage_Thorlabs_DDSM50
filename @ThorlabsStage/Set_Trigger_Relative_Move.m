function Calibrate_Illumination(ueyecam)
	% Put exposure time to low value

	oldEt = uyecam.exposuretime;

	fprintf('[uEyeCam] Adjusting exposure time.\n');
	ueyecam.exposuretime = 20;
	ueyecam.Acquire();
	while (max(ueyecam.img.Data(:)) == 250)
		ueyecam.exposuretime = ueyecam.exposuretime - 1;
		ueyecam.Acquire();
	end


end