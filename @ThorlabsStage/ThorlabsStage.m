% File: ThorlabsStage.m @ ThorlabsStage
% Author: Urs Hofmann
% Date: 15th Okt 2018
% Version: 1.0

% Description: Matlab wrapper for the Kinesis .NET interface of thorlabs to control Brushless motor
% based stages

classdef ThorlabsStage < handle 
    
    properties (Constant, Hidden)
       % path to DLL files (edit as appropriate)
       MOTORPATHDEFAULT='C:\Program Files\Thorlabs\Kinesis\';

       % DLL files to be loaded
       DEVICEMANAGERDLL='Thorlabs.MotionControl.DeviceManagerCLI.dll';
       DEVICEMANAGERCLASSNAME='Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI'
       GENERICMOTORDLL='Thorlabs.MotionControl.GenericMotorCLI.dll';
       GENERICMOTORCLASSNAME='Thorlabs.MotionControl.GenericMotorCLI.GenericMotorCLI';
     
       BRUSHLESSMOTORDLL='Thorlabs.MotionControl.KCube.BrushlessMotorCLI.dll';  
       BRUSHLESSMOTORCLASSNAME='Thorlabs.MotionControl.KCube.BrushlessMotorCLI.KCubeBrushlessMotor';
     
       % Default intitial parameters 
       DEFAULTVEL=10;           % Default velocity
       DEFAULTACC=10;           % Default acceleration
       TPOLLING=250;            % Default polling time
       TIMEOUTSETTINGS=7000;    % Default timeout time for settings change
       TIMEOUTMOVE=100000;      % Default time out time for motor move
       MAXVEL = 600; % mm/s
       MAXACC = 5000; % mm/s^2
    end
    properties 
       % These properties are within Matlab wrapper 
       serialnumber;                % Device serial number
       controllername;              % Controller Name
       controllerdescription        % Controller Description
       stagename;                   % Stage Name

       isConnected=false;           % Flag set if device connected
       beSilent = 0;
       isHomed;
       isEnabled;

       pos; % position [mm]
       acc; % acceleration [mm/s^2]
       mass; % mass the stage needs to carry [g]
       vel; % velocity [mm/s]

       maxvelocity;                 % Maximum velocity limit
       minvelocity;                 % Minimum velocity limit
       % These are properties within the .NET environment. 
       deviceNET;                   % Device object within .NET
       deviceInfoNET;               % deviceInfo within .NET
       motorSettingsNET;            % motorSettings within .NET
       currentDeviceSettingsNET;    % currentDeviceSetings within .NET

       homingOffsetDistance;
    end
    methods

      % Instantiate motor object
      function ThorlabsStage=ThorlabsStage(varargin) 
        ThorlabsStage.Load_DLLs; % Load DLLs (if not already loaded)
        if (nargin == 1)
          fprintf('[ThorlabsStage] Initialise based on constructor variable.\n');
          if ischar(varargin{1})
            ThorlabsStage.Connect(varargin{1});
          end
        end

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

        if ~ThorlabsStage.isHomed
          ThorlabsStage.Home();
        end
      end

      % Destructor
      function delete(h)
        if h.deviceNET.IsConnected
          h.Disconnect;
        end
      end

      serialNumbers = List_Devices(thorlabsstage);
      Load_DLLs(thorlabsstage);
      Stop(thorlabsstage); % Stop the motor moving (needed if set motor to continous)
      Update_Status(thorlabsstage);
      Connect(thorlabsstage, serialNo);
      Disconnect(thorlabsstage);
      Home(thorlabsstage);
      Reset(thorlabsstage);
      acc = Mass_To_Acc(thorlabsstage, mass);
      Move_No_Wait(thorlabsstage, pos);
      Wait_Move(thorlabsstage); % waits until movement is finished
      matrix = Calib_B_Scan(thorlabsstage, posstart, posend);
      Set_Trigger_Edge(thorlabsstage, startPos, endPos, nCycles);
      Set_Trigger_Relative_Move(thorlabsstage, increment, nCycles);

      function ih = get.isHomed(thorlabsstage)
        status = thorlabsstage.deviceNET.Status;
        ih = status.IsHomed;
      end

      function set.homingOffsetDistance(thorlabsstage, hod)
        params = thorlabsstage.deviceNET.GetHomingParams;
        params.OffsetDistance = hod;
        thorlabsstage.deviceNET.SetHomingParams(params);
        thorlabsstage.homingOffsetDistance = hod;
      end

      function hod = get.homingOffsetDistance(thorlabsstage)
        params = thorlabsstage.deviceNET.GetHomingParams;
        hod = System.Decimal.ToDouble(params.OffsetDistance);
      end

      % Moves to position and waits until position is reached
      function set.pos(thorlabsstage, pos)
          try
              workDone=thorlabsstage.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
              thorlabsstage.deviceNET.MoveTo(pos, workDone); % Move devce to position via .NET interface
              thorlabsstage.deviceNET.Wait(thorlabsstage.TIMEOUTMOVE);              % Wait for move to finish
          catch % Device faile to move
              error(['Unable to Move device ',thorlabsstage.serialnumber,' to ',num2str(pos)]);
          end
      end

      % Check if device is already enabled, if so we don't have to do it over and over again
      function ie = get.isEnabled(thorlabsstage)
        ie = thorlabsstage.deviceNET.IsEnabled;
      end

      % Get current device position
      function pos = get.pos(thorlabsstage)
          pos=System.Decimal.ToDouble(thorlabsstage.deviceNET.Position);
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
        [differentialGain, perivativeRecalculationTime, outputGain] = thorlabsstage.Mass_To_PID(mass);

        posLoopParameters = thorlabsstage.deviceNET.GetPosLoopParams();
        posLoopParameters.DifferentialGain = differentialGain;
        posLoopParameters.PerivativeRecalculationTime = perivativeRecalculationTime;
        posLoopParameters.FactorForOutput = outputGain;

        thorlabsstage.deviceNET.SetPosLoopParams(posLoopParameters);

        thorlabsstage.mass = mass;
      end

    


    end
end
