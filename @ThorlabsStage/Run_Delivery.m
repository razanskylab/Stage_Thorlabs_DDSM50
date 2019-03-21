% File: Run_Delivery.m @ BleachingTest
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 18.12.2018
% Version: 1.0

% Description: Moves between individual cells and probes quickly

function Run_Delivery(bt, m)

	bt.Create_File_Name();  % Generate file names later used to store results

	% Prepare ScanSettings variables
	bt.ScanSettings.nPPE = 1;  % only working with one per pulse energy

	% perform FSH	
	bt.OAScan = ThorScan;
	bt.OAScan.ScanSettings.scanName = [bt.ScanSettings.scanName, '_oa_scan'];
	bt.OAScan.ScanSettings.ctr = [25, 25];
	bt.OAScan.ScanSettings.width = [50, 50];
	bt.OAScan.ScanSettings.dr = [0.1, 0.1];
	bt.OAScan.ScanSettings.vel.FastStage = 150;
	bt.OAScan.ScanSettings.sensitivityUs = 1000;
	bt.OAScan.ScanSettings.sensitivityPd = 10000;
	bt.OAScan.ScanSettings.saveRawData = 0;
	bt.OAScan.ScanSettings.saveData = 0;
	bt.OAScan.ScanSettings.nSamples = 2400;
	bt.OAScan.ScanSettings.samplingFreq = 250e6;
	bt.OAScan.ScanSettings.temp = 25;
	bt.OAScan.ScanSettings.doPDComp = 0;
	bt.OAScan.ScanSettings.readSettingsFlag = 0;
	bt.OAScan.ScanSettings.pdCrop = 1:250;
	bt.OAScan.ScanSettings.missedX = 1;
	bt.OAScan.ScanSettings.delayDac = 0;
	bt.OAScan.PostProSettings.flagHilbert = 1;
  	bt.OAScan.PostProSettings.flagFreqFiltering = 1;
  	bt.OAScan.PostProSettings.filterFreq = [0.5e6, 15e6];
  	bt.OAScan.PostProSettings.zCrop = [800, 1500];
  	
  	bt.OAScan.Run(m);  % Run OA scan

  	% Find cells based on resulting OA based MIP
  	bt.Find_Cells(bt.OAScan.Results.mipz, bt.OAScan.ScanSettings.dr(1));

  	bt.Generate_Subsets();  % extract best nCell performing cells
  	bt.Optimize_Path();  % optimize path between cells

  	bt.Prepare_Hardware_Probing(m);  % prepare hardware for probing

end