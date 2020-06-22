% File: Mass_To_PID.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 17th Okt 2018

% Returns PID controller settings for stages
% Changelog:
% 		2018-12-18: Switched from lookup table to linear relationship
% 					for differentialGain and preivativeGain

function params = Mass_To_PID(thorlabsstage, mass)

	if ((mass >= 0) && (mass < 250))
		params.perivativeRecalculationTime = 5;
	elseif ((mass >= 250) && (mass < 500))
		params.perivativeRecalculationTime = 5;
	elseif ((mass >= 500) && (mass < 750))
		params.perivativeRecalculationTime = 6;
	elseif ((mass >= 750) && (mass <= 900))
		params.perivativeRecalculationTime = 7;
	else
		error('Invalid mass range');
	end

	params.derivativeGain = 15250 + mass * 8;
	% if instabilites in velocity occur, increase this term

	params.integralGain = 3800;
	params.proportionalGain = 2400;

	params.outputGain = 3666.7 + mass * 2;
end