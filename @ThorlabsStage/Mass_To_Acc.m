% File: Mass_To_Acc.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 17thOkt 2018

% Description: Converts the mass [g] the stage needs to carry into a maximum acceleration.

function acc = Mass_To_Acc(thorlabsstage, mass)

	datapoints = [0 5000; 125 2400; 250 1550; 500 925; 750 650; 900 500];

	% Check if mass is within a reasonable range
	if (mass < 0) || (mass > 900)
		error('Invalid mass range');
	end

	acc = interp1(datapoints(:,1), datapoints(:,2), mass);

end