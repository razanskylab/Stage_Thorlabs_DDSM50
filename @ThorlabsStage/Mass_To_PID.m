% File: Mass_To_PID.m @ ThorlabsStage
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 17th Okt 2018

% Returns PID controller settings for stages
% Changelog:
% 		2018-12-18: Switched from lookup table to linear relationship
% 					for differentialGain and preivativeGain

function [differentialGain, perivativeRecalculationTime, outputGain] = ...
	Mass_To_PID(thorlabsstage, mass)

	if ((mass >= 0) && (mass < 250))
		perivativeRecalculationTime = 5;
	elseif ((mass >= 250) && (mass < 500))
		perivativeRecalculationTime = 5;
	elseif ((mass >= 500) && (mass < 750))
		perivativeRecalculationTime = 6;
	elseif ((mass >= 750) && (mass <= 900))
		perivativeRecalculationTime = 7;
	else
		error('Invalid mass range');
	end

	differentialGain = 4250 + mass * 2;
	outputGain = 3666.7 + mass * 2.6667;
end