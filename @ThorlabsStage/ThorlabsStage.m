% File: ThorlabsStage.m @ ThorlabsStage
% Author: Urs Hofmann
% Date: 15th Okt 2018
% Version: 1.0

% Description: Matlab wrapper for the Kinesis .NET interface of thorlabs to control Brushless motor
% based stages

classdef ThorlabsStage < handle 
    
    properties (Constant, Hidden)
       % path to DLL files (edit as appropriate)
       MOTORPATHDEFAULT(1, :) char = 'C:\Program Files\Thorlabs\Kinesis\';
       % DLL files to be loaded
       DEVICEMANAGERDLL(1, :) char = 'Thorlabs.MotionControl.DeviceManagerCLI.dll';
       DEVICEMANAGERCLASSNAME(1, :) char = 'Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI'
       GENERICMOTORDLL(1, :) char = 'Thorlabs.MotionControl.GenericMotorCLI.dll';
       GENERICMOTORCLASSNAME(1, :) char = 'Thorlabs.MotionControl.GenericMotorCLI.GenericMotorCLI';
       BRUSHLESSMOTORDLL(1, :) char = 'Thorlabs.MotionControl.KCube.BrushlessMotorCLI.dll';  
       BRUSHLESSMOTORCLASSNAME(1, :) char = 'Thorlabs.MotionControl.KCube.BrushlessMotorCLI.KCubeBrushlessMotor';
     
       % Default intitial parameters 
       DEFAULTVEL = 10; % default velocity [mm/s]
       DEFAULTACC = 10; % default acceleration [mm/s^2]
       TPOLLING = 250; % Default polling time
       TIMEOUTSETTINGS = 7000; % Default timeout time for settings change
       TIMEOUTMOVE = 100000; % Default time out time for motor move
       MAXVEL = 600; % mm/s
       MAXACC = 5000; % mm/s^2
    end

    properties 
       % These properties are within Matlab wrapper 
       controllername; % Controller Name
       controllerdescription % Controller Description
       stagename(1, :) char; % Stage Name
       isConnected(1, 1) logical = false; % flag set if device connected
       beSilent(1, 1) logical = false; % suppress verbose output
       mass(1, 1) single; % mass the stage needs to carry [g]
       maxvelocity(1, 1) single; % Maximum velocity limit
       minvelocity(1, 1) single; % Minimum velocity limit
       % These are properties within the .NET environment. 
       deviceNET; % Device object within .NET
       deviceInfoNET; % deviceInfo within .NET
       motorSettingsNET; % motorSettings within .NET
       currentDeviceSettingsNET; % currentDeviceSetings within .NET
       homingOffsetDistance;
       serialnumber; % Device serial number
    end

    properties(Dependent)
       vel(1, 1) single; % velocity [mm/s]
       pos(1, 1) single; % position [mm]
       acc(1, 1) single; % acceleration [mm/s^2]
       isEnabled(1, 1) logical;
       isDeviceBusy(1, 1) logical;
       isHomed(1, 1) logical;
       backlash(1, 1) single = 0; % backlash of stage in [mm] usually only due to leadscrew
       homingVel(1, 1) single; % homing velocity of stage [mm/s]
       % posErrorLimit(1, 1) single; % position error limit
    end

    methods

      % Instantiate motor object
      function ThorlabsStage = ThorlabsStage(varargin) 

        % default arguments
        stageId = [];
        flagHome = 0; % perform homing if required

        % user specific input, how to input the argument
        for (iargin = 1:2:nargin)
          switch varargin{iargin}
            case 'stageId'
              stageId = varargin{iargin + 1}; 
            case 'flagHome'
              flagHome = varargin{iargin + 1};
            case 'mass'
              mass = varargin{iargin + 1};  %%problem, property doesn't change 
            otherwise
              error('Invalid option passed during stage construction');
          end
        end

        ThorlabsStage.Load_DLLs(); % Load DLLs (if not already loaded)
        
        if ~isempty(stageId) % stageId not empty, then true
          ThorlabsStage.Connect(stageId)
          
          % first try
          try
            ThorlabsStage.Enable();
          catch
            % second try
            warning('Problem enabling stage, retrying');
            pause(0.5);
            try
              ThorlabsStage.Enable();
            catch
              % thrird try
              warning('Problem enabling stage, retrying');
              pause(0.5);
              ThorlabsStage.Enable();
            end
          end

          if (~ThorlabsStage.isHomed && flagHome)
            ThorlabsStage.Home();
          end
        else
          error('Could not connect to anything here, this is fucked');         
        end

      end

      % Destructor
      function delete(ts)
        if ts.deviceNET.IsConnected
          ts.Disconnect  
        end
      end

      serialNumbers = List_Devices(thorlabsstage);
      Load_DLLs(thorlabsstage);
      Stop(thorlabsstage); % Stop the motor moving (needed if set motor to continous)
      Update_Status(thorlabsstage);
      Connect(thorlabsstage, serialNo);
      Disconnect(thorlabsstage); % closes connection between matlab and stage
      Home(thorlabsstage); % homes at position x = 0
      Reset(thorlabsstage);
      acc = Mass_To_Acc(thorlabsstage, mass);
      Move_No_Wait(thorlabsstage, pos);
      Wait_Move(thorlabsstage); % waits until movement is finished
      matrix = Calib_B_Scan(thorlabsstage, posstart, posend);
      Set_Trigger_Edge(thorlabsstage, startPos, endPos, nCycles);
      Set_Trigger_Relative_Move(thorlabsstage, increment, nCycles);

      function ib = get.isDeviceBusy(ts)
        ib = ts.deviceNET.IsDeviceBusy;
      end

      function ih = get.isHomed(ts)
        status = ts.deviceNET.Status;
        ih = status.IsHomed;
      end

      function set.homingOffsetDistance(ts, hod)
        params = ts.deviceNET.GetHomingParams;
        params.OffsetDistance = hod;
        ts.deviceNET.SetHomingParams(params);
        ts.homingOffsetDistance = hod;
      end

      function hod = get.homingOffsetDistance(ts)
        params = ts.deviceNET.GetHomingParams;
        hod = System.Decimal.ToDouble(params.OffsetDistance);
      end

      % Moves to position and waits until position is reached
      function set.pos(ts, pos)
          try
              workDone = ts.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
              ts.deviceNET.MoveTo(pos, workDone); % Move devce to position via .NET interface
              ts.deviceNET.Wait(ts.TIMEOUTMOVE);              % Wait for move to finish
          catch % Device faile to move
              error(['Unable to Move device ', ts.serialnumber, ' to ', num2str(pos)]);
          end
      end

      % Get current device position [mm]
      function pos = get.pos(ts)
          pos = System.Decimal.ToDouble(ts.deviceNET.Position);
      end

      % backlash [mm]
      function backlash = get.backlash(ts)
        backlash = single(System.Decimal.ToDouble(ts.deviceNET.GetBacklash));
      end

      function set.backlash(ts, backlash)
        ts.deviceNET.SetBacklash(backlash);
      end

      % homing velocity [mm/s]
      function homingVel = get.homingVel(ts)
        homingVel = single(System.Decimal.ToDouble(ts.deviceNET.GetHomingVelocity));
      end
      
      function set.homingVel(ts, homingVel)
        ts.deviceNET.SetHomingVelocity(homingVel);
      end

      % Check if device is already enabled, if so we don't have to do it over and over again
      function ie = get.isEnabled(thorlabsstage)
        ie = thorlabsstage.deviceNET.IsEnabled;
      end

      function set.isEnabled(ts, ie)
        if ie
          ts.Enable();
        else
          ts.Disable();
        end
      end

      % Sets target velocity of the stage
      function set.vel(thorlabsstage, vel)
        velpars = thorlabsstage.deviceNET.GetVelocityParams();
        if isnumeric(vel)
          if (vel <= thorlabsstage.MAXVEL) && (vel > 0)
            velpars.MaxVelocity = vel;
            thorlabsstage.deviceNET.SetVelocityParams(velpars);
          else
            error('Velocity outside of allowed range.');
          end
        else
          error('Invalid datatype.');
        end
      end

      % Read velocity from stage controller
      function vel = get.vel(thorlabsstage)
        velpars = thorlabsstage.deviceNET.GetVelocityParams();
        vel = System.Decimal.ToDouble(velpars.MaxVelocity);
      end

      % Sets acceleration of the stage
      function set.acc(thorlabsstage, acc)
        velpars = thorlabsstage.deviceNET.GetVelocityParams();
        if isnumeric(acc)
          if (acc <= thorlabsstage.MAXACC) && (acc > 0)
            velpars.Acceleration = acc;
            thorlabsstage.deviceNET.SetVelocityParams(velpars);
          else
            error('Acceleration outside of allowed range.');
          end
        else
          error('Invalid datatype.');
        end
      end

      % Read acceleration from stage controller
      function acc = get.acc(thorlabsstage)
        velpars = thorlabsstage.deviceNET.GetVelocityParams();
        acc = System.Decimal.ToDouble(velpars.Acceleration);
      end

      % Set mass and thereby define stage parameters
      % Automatically updates PID settings and maximum acceleration
      function set.mass(thorlabsstage, mass)
        thorlabsstage.acc = thorlabsstage.Mass_To_Acc(mass);
        params = thorlabsstage.Mass_To_PID(mass);

        posLoopParameters = thorlabsstage.deviceNET.GetPosLoopParams()
        posLoopParameters.DerivativeRecalculationTime = params.perivativeRecalculationTime;
        
        posLoopParameters.DerivativeGain = params.derivativeGain;
        posLoopParameters.ProportionalGain = params.proportionalGain;
        posLoopParameters.IntegralGain = params.integralGain;

        posLoopParameters.FactorForOutput = params.outputGain;

        thorlabsstage.deviceNET.SetPosLoopParams(posLoopParameters);

        thorlabsstage.mass = mass;
      end

      % % posErrorLimit
      % function posErrorLimit = get.posErrorLimit(ts)
      %   posErrorLimit = ts.deviceNET.GetPosLoopParams.PositionErrorLimit;
      % end

      % function set.posErrorLimit(ts, posErrorLimit)
      %   % posErrorLimit = ST.deviceNET.GetPosLoopParams.PositionErrorLimit;
      %   posLoopParameters = ts.deviceNET.GetPosLoopParams()
      %   addposLoopParameters.PositionErrorLimit = int32(posErrorLimit);
      %   ts.deviceNET.SetPosLoopParams(posLoopParameters);
      % end
    end
end
