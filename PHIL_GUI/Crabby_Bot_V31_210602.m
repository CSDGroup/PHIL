%% GUI INITIALIZATION
function varargout = Stage_Bot_200503(varargin)
clear all
set(0,'units','pixels');
sspix = get(0,'screensize');
H = figure('units','normalized',...
    'outerposition',[0 .05 1 .95],...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Name','Parent',...
    'WindowKeyPressFcn',@keyPressCallback,...
    'WindowKeyReleaseFcn',@keyReleaseCallback);

    function keyPressCallback(hObject,callbackdata)
        if strcmp(callbackdata.Key,'shift')
            GuIformat.ShiftState = 1;
        end
    end

    function keyReleaseCallback(hObject,callbackdata)
        if strcmp(callbackdata.Key,'shift')
            GuIformat.ShiftState = 0;
        end
    end

global GuIformat VIDs BoxInfo Panels CrabModel

if exist(fullfile(cd,'Experiments')) == 0
    mkdir(fullfile(cd,'Experiments'));
end

%% Declare Global variables
GuIformat.LogPath = cd;
GuIformat.ShiftState = 0;
GuIformat.DEBUGMODE = 1;
GuIformat.TESTpause = .05;
GuIformat.STOP = 1;
GuIformat.BOXConnected = 0;
GuIformat.PausePos = 1;

GuIformat.color.c = [215/255 215/255 215/255];
GuIformat.color.o = [150/255 255/255 255/255];
GuIformat.color.i = [102/255 1 12/255];
GuIformat.color.d = [240/255 240/255 240/255];
GuIformat.PAUSE = 0;

GuIformat.StepperDIRS = [1,-1];

GuIformat.StepperCount = 14;
GuIformat.PumpCount = GuIformat.StepperCount - 4;
GuIformat.ReagentCount = GuIformat.PumpCount - 1;

GuIformat.wellcount = 0;
GuIformat.PUMPSTATES = zeros(1,GuIformat.ReagentCount);
GuIformat.LOADSTATES = zeros(1,GuIformat.ReagentCount);

GuIformat.WashWell = [1,1];
GuIformat.PREVIOUSCOMPOSITION = zeros(1,GuIformat.ReagentCount);

%% Declare Stepper Control variables
GuIformat.TopToTop = 1;
VIDs.crrntSTEPS = zeros(1,GuIformat.StepperCount);

VIDs.pulseNAMES = {'X','Y','Z'};
VIDs.MicroStepTypesTxt = {'1','2','4','8','16','32'};
VIDs.MicroStepTypesNum = [1,2,4,8,16,32];
VIDs.MicroStepSETTINGS = [32,32,32,32,32,32,32,32,32,32,32,32,32,32];
VIDs.MicroStepValues = [5,5,5,5,5,5,5,5,5,5,5,5,5,5];
GuIformat.mmPERstep = [87/500, 87/500, 87/500, 87/500, 87/500, 87/500, 87/500];
VIDs.MAXspeed = 1500;
VIDs.MAXacceleration = 1000;
VIDs.StepsPERRev = VIDs.MicroStepSETTINGS*200;

VIDs.Right = [0,1,0,0,0,0,0,0,0,0,0,0,0,0]
VIDs.Left = [0,-1,0,0,0,0,0,0,0,0,0,0,0,0]
VIDs.Forward = [-1,0,0,0,0,0,0,0,0,0,0,0,0,0]
VIDs.Backward = [1,0,0,0,0,0,0,0,0,0,0,0,0,0]
VIDs.Up = [0,0,-1,-1,0,0,0,0,0,0,0,0,0,0];
VIDs.Down = [0,0,1,1,0,0,0,0,0,0,0,0,0,0];

VIDs.PUSH = zeros(GuIformat.PumpCount,GuIformat.StepperCount);

for i = 1:GuIformat.PumpCount
    VIDs.PUSH(i,i+4) = 1;
    
end

VIDs.PULL = -VIDs.PUSH

VIDs.SyrMat = [(5000/16500), (5000/1), (2800/700), (1116/(100000/4))]; %ul/fullsteps for 3ml,15ml,50ml, Peristaltic

%% LOAD SETTINGS
[GuIformat.Configfilename, GuIformat.Configpathname] = uigetfile('*.mat', 'Pick a configuration file');
figure(gcf)
if exist(fullfile(GuIformat.Configpathname,GuIformat.Configfilename))
LoadConfig(GuIformat.Configpathname,GuIformat.Configfilename)
else
    %% PORT SETTINGS
    BoxInfo.PORT = '6';
    
    %% STEPPER ENABLE SETTINGS
    BoxInfo.StepperEnable = ones(1,GuIformat.StepperCount);
    BoxInfo.StepperEnable(8:14) = 0;
    VIDs.StepperEnable = BoxInfo.StepperEnable;
    
    %% STEPPER DIRECTIONS SETTINGS
    BoxInfo.StepDIRValues = 2*ones(1,GuIformat.StepperCount);
    BoxInfo.StepDIRValues(3:4) = 1;
    GuIformat.StepDIRValues = BoxInfo.StepDIRValues;
    
    %% MICROSTEP SETTINGS
    BoxInfo.MicroStepValues = ones(1,GuIformat.StepperCount)*6;
    BoxInfo.MicroStepValues(3:4) = 4;
    BoxInfo.MicroStepValues(5:GuIformat.StepperCount) = 3;
    
    %% SPEED SETTINGS
    BoxInfo.StepperSpeeds = ones(1,GuIformat.StepperCount)*10;
    BoxInfo.StepperSpeeds(1:2) = 6000;
    BoxInfo.StepperSpeeds(3:4) = 2000;
    VIDs.StepperSpeeds = BoxInfo.StepperSpeeds;
    
    %% MAX SPEED SETTINGS
    BoxInfo.StepperMaxSpeeds = ones(1,GuIformat.StepperCount)*100;
    BoxInfo.StepperMaxSpeeds(1:2) = 6000;
    BoxInfo.StepperMaxSpeeds(3:4) = 3000;
    VIDs.StepperMaxSpeeds = BoxInfo.StepperMaxSpeeds;
    
    %% CALIBRATION VOLUME
    BoxInfo.CalibVol = ones(1,GuIformat.StepperCount)*10.5;
    VIDs.CalibVol = BoxInfo.CalibVol;
    
    %% 384 WELL PLATE SETTINGS
    GuIformat.w384POSmm.ymin = -10.2;
    GuIformat.w384POSmm.xmin = 93.6;
    GuIformat.w384POSmm.xdivs = 4.5;
    GuIformat.w384POSmm.ydivs = 4.5;
    for x = 1:24
        for y = 1:16
            GuIformat.w384POSmm.x(x) = GuIformat.w384POSmm.xmin + GuIformat.w384POSmm.xdivs*(x-1);
            GuIformat.w384POSmm.y(y) = GuIformat.w384POSmm.ymin + GuIformat.w384POSmm.ydivs*(y-1);
        end
    end
    BoxInfo.w384POSmm.x = GuIformat.w384POSmm.x;
    BoxInfo.w384POSmm.y = GuIformat.w384POSmm.y;
    
    %% 96 WELL PLATE SETTINGS
    GuIformat.w96POSmm.ymin = -7.96;
    GuIformat.w96POSmm.xmin = 95.9;
    GuIformat.w96POSmm.xdivs = 9;
    GuIformat.w96POSmm.ydivs = 9;
    for x = 1:12
        for y = 1:8
            GuIformat.w96POSmm.x(x) = GuIformat.w96POSmm.xmin + GuIformat.w96POSmm.xdivs*(x-1);
            GuIformat.w96POSmm.y(y) = GuIformat.w96POSmm.ymin + GuIformat.w96POSmm.ydivs*(y-1);
        end
    end
    BoxInfo.w96POSmm.x = GuIformat.w96POSmm.x;
    BoxInfo.w96POSmm.y = GuIformat.w96POSmm.y;
    
    %% HEIGHT SETTINGS
    BoxInfo.ZValues = [0,0,0];
    BoxInfo.ZValues(3) = -6665;
    GuIformat.ZValues = BoxInfo.ZValues;
    
    %% SAVE SETTINGS
    save(fullfile(GuIformat.Configpathname,GuIformat.Configfilename),'BoxInfo')
end

%% Declare Crabby Model
CrabModel.ZmmPerStep = 12/200;
CrabModel.ZmmPerDegree = 12/360;
CrabModel.StepsPerDegree = 200/360;

CrabModel.L1 = 65;
CrabModel.L2 = 145;
CrabModel.R1 = 65;
CrabModel.R2 = 145;
CrabModel.H = 45.0957;
CrabModel.P = 10;

CrabModel.Plate.xmin = - 21;
CrabModel.Plate.xmax = 66;
CrabModel.Plate.ymin = 79.5;
CrabModel.Plate.ymax = 210;
CrabModel.Plate.zmin = 0;
CrabModel.Plate.zmax = 27.75;
VIDs.crrntXYZmm = zeros(1,GuIformat.StepperCount);
VIDs.crrntXYZmm(2) = CrabModel.H/2;

CrabModel.robot = robotics.RigidBodyTree('Dataformat','column','MaxNumBodies',7);

bodyNames = {'b1','b2','b3','b4','b5','b6'};
parentNames = {'base','b1','b2','b3','b4','b5'};
jointNames = {'j1','j2','j3','j4','j5','j6'};
jointTypes = {'revolute','revolute','fixed','revolute','revolute','fixed'};
fixedTforms = {eye(4), ...
    trvec2tform([0 CrabModel.L1 0]), ...
    trvec2tform([CrabModel.L2 0 0]), ...
    trvec2tform([0 0 0]), ...
    trvec2tform([0 -CrabModel.R2 0]), ...
    trvec2tform([-CrabModel.R1 0 0])};
%             HomePos = [-3*pi/4,-pi/4,pi/4,3*pi/4]

for k = 1:6
    
    CrabModel.b = robotics.RigidBody(bodyNames{k});
    CrabModel.b.Joint = robotics.Joint(jointNames{k},jointTypes{k});
    
    if ~strcmp(jointTypes{k},'fixed')
        CrabModel.b.Joint.JointAxis = [0 0 1];
    end
    
    CrabModel.b.Joint.setFixedTransform(fixedTforms{k});
    
    addBody(CrabModel.robot,CrabModel.b,parentNames{k});
end

CrabModel.bn = 'handle';
CrabModel.b = robotics.RigidBody(CrabModel.bn);
setFixedTransform(CrabModel.b.Joint,trvec2tform([0 CrabModel.P 0]));
addBody(CrabModel.robot,CrabModel.b,'b3');

CrabModel.gik = robotics.GeneralizedInverseKinematics('RigidBodyTree',CrabModel.robot);
CrabModel.gik.ConstraintInputs = {'position',...  % Position constraint for closed-loop mechanism
    'position',...  % Position constraint for end-effector
    'joint'};       % Joint limits
CrabModel.gik.SolverParameters.AllowRandomRestart = false;

CrabModel.gik = robotics.GeneralizedInverseKinematics('RigidBodyTree',CrabModel.robot);
CrabModel.gik.ConstraintInputs = {'position',...  % Position constraint for closed-loop mechanism
    'position',...  % Position constraint for end-effector
    'joint'};       % Joint limits
CrabModel.gik.SolverParameters.AllowRandomRestart = false;

% Position constraint 1
CrabModel.positionTarget1 = robotics.PositionTarget('b6');
CrabModel.positionTarget1.TargetPosition = [CrabModel.H 0 0];
CrabModel.positionTarget1.Weights = 50;
CrabModel.positionTarget1.PositionTolerance = 1e-6;

% Joint limit bounds
CrabModel.jointLimBounds = robotics.JointPositionBounds(CrabModel.gik.RigidBodyTree);
CrabModel.jointLimBounds.Bounds(1,:) = [-9*pi/20, 19*pi/20];
CrabModel.jointLimBounds.Bounds(2,:) = [-9*pi/20 , 9*pi/20];
CrabModel.jointLimBounds.Bounds(3,:) = [-9*pi/20 , 9*pi/20];
CrabModel.jointLimBounds.Bounds(4,:) = [-9*pi/20, 9*pi/20];
CrabModel.jointLimBounds.Weights = ones(1,size(CrabModel.gik.RigidBodyTree.homeConfiguration,1))*10;

% Position constraint 2
CrabModel.positionTarget2 = robotics.PositionTarget('handle');
CrabModel.positionTarget2.PositionTolerance = 1e-6;
CrabModel.positionTarget2.Weights = 1;
CrabModel.iniGuess = homeConfiguration(CrabModel.robot);

%% Tabs
Control = uipanel('Visible','on',...
    'Position',[0 0 1 1]);
Panels.TABGROUP = uitabgroup(H,'Visible','on',...
    'Position',[0 .05 1 .925]);

%% CALIBRATION TAB

Panels.CalibrationTAB = uitab('Parent',Panels.TABGROUP,'Title','Setup P.Hi.L.');
Panels.CalibrationPanel = uipanel(Panels.CalibrationTAB,'Visible','on',...
    'Position',[0 0 1 1]);

CalibrationPanel

%% Control Tab
Panels.ControlTAB = uitab('Parent',Panels.TABGROUP,'Title','Control P.Hi.L.');
Panels.ControlPanel = uipanel(Panels.ControlTAB,'Visible','on',...
    'Position',[0 0 1 1]);

DirectControlPanel;
ManualControlPanel;
PlateControlPanel;
ArduinoConnectPanel;
%RunButtonPanel;

%% Scripting Tab

Panels.ScriptingTAB = uitab('Parent',Panels.TABGROUP,'Title','Script Experiment');
Panels.ScriptingPanel = uipanel(Panels.ScriptingTAB,'Visible','on',...
    'Position',[0 0 1 1]);

ScriptingPanel;
Panels.TABGROUP.SelectedTab = Panels.ScriptingTAB;

%% Headless Tab

Panels.HeadlessTAB = uitab('Parent',Panels.TABGROUP,'Title','Headless Mode');
Panels.HeadlessPanel = uipanel(Panels.HeadlessTAB,'Visible','on',...
    'Position',[0 0 1 1]);

HeadlessPanel

%% CLEAR COMMAND LINE
LR2pause()

clc
end

%% PANEL CALIBRATION

function CalibrationPanel
global GuIformat Panels VIDs BoxInfo

%% Setup Parameters
ControlSetup = uipanel(Panels.CalibrationPanel,'Visible','on',...
    'Position',[0 0 1 1]);

SetupTabs = uitabgroup(ControlSetup,'Visible','on',...
    'Position',[0 0 1 1]);

%% General Settings
Setup.General = uitab('Parent',SetupTabs,'Title','General Settings');
GeneralSettingsTotalPanel = uipanel(Setup.General,'Visible','on',...
    'Position',[0 0 1 1]);

%% SMART WASH

stngcnt = 20;
stng = 1;
GeneralSettings(stng) = uipanel(GeneralSettingsTotalPanel,'Visible','on',...
    'Position',[0 (stngcnt-stng)/stngcnt 1 (1/stngcnt)]);

WashParamCount = 5;
SmrtWshTxt = {'','Status','Plate Type','Column','Row'};

for i = 1:WashParamCount
    SmartWashText = uicontrol(GeneralSettings(stng),...
        'Units','normalized',...
        'Style','text',...
        'String',SmrtWshTxt{i},...
        'Position',[(i-1)/WashParamCount 1/2 1/WashParamCount 1/2],...
        'HandleVisibility','off');
end

GuIformat.SmartWashEnableCB = uicontrol(GeneralSettings(stng),...
    'Units','normalized',...
    'Style','checkbox',...
    'Value',1,...
    'String',"Wash between media types?",...
    'Position',[0/WashParamCount 0 1/WashParamCount 1/2],...
    'HandleVisibility','off');
GuIformat.SmartWashTypePUM = uicontrol(GeneralSettings(stng),...
    'Units','normalized',...
    'Style','popupmenu',...
    'Value',2,...
    'String',{'Always','Smart'},...
    'Position',[1/WashParamCount 0 1/WashParamCount 1/2],...
    'HandleVisibility','off');
GuIformat.SmartWashWellPlateType = uicontrol(GeneralSettings(stng),...
    'Units','normalized',...
    'Style','popupmenu',...
    'Value',1,...
    'String',{'96','384'},...
    'Position',[2/WashParamCount 0 1/WashParamCount 1/2],...
    'HandleVisibility','off',...
    'Callback',@SmartWashTypePUM);
    function SmartWashTypePUM(hObject,callbackdata)
        State = get(hObject,'Value');
        if State == 1
            % X
            set(GuIformat.SmartWashWellY,'Value',1);
            set(GuIformat.SmartWashWellY,'String',{'1','2','3','4','5','6','7','8'});
            % Y
            set(GuIformat.SmartWashWellX,'Value',1);
            set(GuIformat.SmartWashWellX,'String',{'1','2','3','4','5','6','7','8','9','10','11','12'});
        elseif State == 2
            % X
            set(GuIformat.SmartWashWellY,'Value',1);
            set(GuIformat.SmartWashWellY,'String',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'});
            % Y
            set(GuIformat.SmartWashWellX,'Value',1);
            set(GuIformat.SmartWashWellX,'String',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'});
        end
        
    end
GuIformat.SmartWashWellX = uicontrol(GeneralSettings(stng),...
    'Units','normalized',...
    'Style','popupmenu',...
    'Value',1,...
    'String',{'1','2','3','4','5','6','7','8','9','10','11','12'},...
    'Position',[3/WashParamCount 0 1/WashParamCount 1/2],...
    'HandleVisibility','off');
GuIformat.SmartWashWellY = uicontrol(GeneralSettings(stng),...
    'Units','normalized',...
    'Style','popupmenu',...
    'Value',1,...
    'String',{'1','2','3','4','5','6','7','8'},...
    'Position',[4/WashParamCount 0 1/WashParamCount 1/2],...
    'HandleVisibility','off');

%% Steppers Settings
Setup.Steppers = uitab('Parent',SetupTabs,'Title','Stepper Settings');
StepperSettingsTotalPanel = uipanel(Setup.Steppers,'Visible','on',...
    'Position',[0 0 1 1]);
StepperSpeedUnits = {'Steps/s','Steps/s','Steps/s','Steps/s','uL/s','uL/s','uL/s','uL/s','uL/s','uL/s','uL/s','uL/s','uL/s','uL/s'};

for i = 1:GuIformat.StepperCount
    StepperSettings(i) = uipanel(StepperSettingsTotalPanel,'Visible','on',...
        'Position',[0 (GuIformat.StepperCount-i)/GuIformat.StepperCount 1 (1/GuIformat.StepperCount)]);
    stngcnt = 8;
    stng = 0;
    
    %% ENABLE SETTING
    GuIformat.StepperEnableCB(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','checkbox',...
        'Value',BoxInfo.StepperEnable(i),...
        'Userdata',i,...
        'String',strcat({'Stepper '},num2str(i),{' Enable'}),...
        'Position',[stng/stngcnt 0 1/stngcnt 1],...
        'HandleVisibility','off',...
        'Callback',@UpdateMotor_Enable);
    
    if BoxInfo.StepperEnable(i) == 1
        nbl = 'On';
    else
        nbl = 'Off';
    end
    
    %% STEPS PER REVOLUTION SETTINGS
    stng = stng + 1;
    StepsPerRevText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'String','Steps per Revolution:',...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.StepsPerRevEDT(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Edit',...
        'Userdata',i,...
        'String','200',...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'HandleVisibility','off',...
        'Enable',nbl,...
        'Callback',@UpdatePUM_GUI);
    
    %% MICROSTEP SETTINGS
    stng = stng + 1;
    MicrostepText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'String','Microstep Setting:',...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.MicrostepPUM(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Popupmenu',...
        'Userdata',i,...
        'String',VIDs.MicroStepTypesTxt,...
        'Value',BoxInfo.MicroStepValues(i),...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'HandleVisibility','off',...
        'Enable',nbl,...
        'Callback',@UpdatePUM_GUI);
    VIDs.MicroStepSETTINGS(i) = VIDs.MicroStepTypesNum(get(GuIformat.MicrostepPUM(i),'Value'));
    
    %% SPEED SETTINGS
    stng = stng + 1;
    SpeedText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'String',strcat({'Speed ('},StepperSpeedUnits{i},{'): '}),...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.StepperSpeedsEDT(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Edit',...
        'Userdata',i,...
        'String',num2str(BoxInfo.StepperSpeeds(i)),...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'HandleVisibility','off',...
        'Enable',nbl,...
        'Callback',@UpdateSettings_GUI);
    
    %% MAX SPEED SETTINGS
    stng = stng + 1;
    MaxSpeedText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'String',strcat({'Max Speed ('},StepperSpeedUnits{i},{'): '}),...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.StepperMaxSpeedsEDT(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Edit',...
        'Userdata',i,...
        'String',num2str(VIDs.StepperMaxSpeeds(i)),...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'HandleVisibility','off',...
        'Enable',nbl,...
        'Callback',@UpdateMaxSettings_GUI);
    
    %% DIRECTION SETTINGS
    stng = stng + 1;
    DirectionText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'String',{' Rotation Compensation:'},...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.DirectionPUM(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Popupmenu',...
        'Userdata',i,...
        'String',{'1','-1'},...
        'Value',BoxInfo.StepDIRValues(i),...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'HandleVisibility','off',...
        'Enable',nbl,...
        'Callback',@UpdateDIRPUM_GUI);
    
    %% CALIBRATE VOLUME
    if i > 4
        Vis = 'On';
    else
        Vis = 'Off';
    end
    stng = stng + 1;
    CalibVolText = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Text',...
        'Visible',Vis,...
        'String',{'Calibration (uL/Revolution): '},...
        'Position',[stng/stngcnt 2/3 1/stngcnt 1/3],...
        'HandleVisibility','off');
    GuIformat.CalibVolEDT(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Edit',...
        'Visible',Vis,...
        'Userdata',i,...
        'String',num2str(VIDs.CalibVol(i)),...
        'Position',[stng/stngcnt 0/3 1/stngcnt 2/3],...
        'Enable',nbl,...
        'HandleVisibility','off');
    
    %% CALIBRATE BUTTON
        stng = stng + 1;
    GuIformat.CalibVolPB(i) = uicontrol(StepperSettings(i),...
        'Units','normalized',...
        'Style','Pushbutton',...
        'Visible',Vis,...
        'Userdata',i,...
        'String','Calibrate',...
        'Position',[stng/stngcnt 0/3 1/stngcnt 3/3],...
        'Enable',nbl,...
        'HandleVisibility','off',...
        'Callback',@CalibratePB_Callback);
    
end

VIDs.StepsPERRev = VIDs.MicroStepSETTINGS*200;

    function UpdatePUM_GUI(hObject,callbackdata)
        Selected = get(hObject,'Userdata');
        Value = get(hObject,'Value');
        SmartHome()
        if ismember(Selected,1:2)
            for i = 1:2
                set(GuIformat.MicrostepPUM(i),'Value',Value)
            end
        elseif ismember(Selected,3:4)
            for i = 3:4
                set(GuIformat.MicrostepPUM(i),'Value',Value)
            end
        elseif ismember(Selected,5:14)
            for i = 5:GuIformat.StepperCount
                set(GuIformat.MicrostepPUM(i),'Value',Value)
            end
        end
        
        UpdateSettings();
    end

    function UpdateSettings_GUI(hObject,callbackdata)
        Selected = get(hObject,'Userdata');
        Speed = str2num(get(hObject,'String'));
        
        if ismember(Selected,1:2)
            for i = 1:2
                set(GuIformat.StepperSpeedsEDT(i),'String',Speed)
            end
        elseif ismember(Selected,3:4)
            for i = 3:4
                set(GuIformat.StepperSpeedsEDT(i),'String',Speed)
            end
        end
        UpdateSettings();
    end

    function UpdateMaxSettings_GUI(hObject,callbackdata)
        Selected = get(hObject,'Userdata');
        Speed = str2num(get(hObject,'String'));
        
        if ismember(Selected,1:2)
            for i = 1:2
                set(GuIformat.StepperMaxSpeedsEDT(i),'String',Speed)
            end
        elseif ismember(Selected,3:4)
            for i = 3:4
                set(GuIformat.StepperMaxSpeedsEDT(i),'String',Speed);
            end
        end
        UpdateSettings();
    end

    function UpdateMotor_Enable(hObject,callbackdata)
        i = get(hObject,'Userdata')
        Value = get(hObject,'Value')
        if Value == 1
            Value = 'On';
        else
            Value = 'Off';
            
        end
        set(GuIformat.MicrostepPUM(i),'Enable',Value)
        set(GuIformat.StepperSpeedsEDT(i),'Enable',Value)
        set(GuIformat.StepperMaxSpeedsEDT(i),'Enable',Value)
        set(GuIformat.DirectionPUM(i),'Enable',Value)
        set(GuIformat.CalibVolEDT(i),'Enable',Value)
        set(GuIformat.CalibVolPB(i),'Enable',Value)
        
        UpdateSettings()
    end

    function UpdateDIRPUM_GUI(hObject,callbackdata)
        UpdateSettings()
    end

    function CalibratePB_Callback(hObject,callbackdata)
        GOTOWELL(96, [6,4], 1)
        DISABLE_ALL;
        i = get(hObject,'Userdata');
        Steps = zeros(1,GuIformat.StepperCount);
        microsteps = VIDs.MicroStepSETTINGS(i);
        StepsPerRev = str2num(get(GuIformat.StepsPerRevEDT(i),'String'));
        uiwait(msgbox('Place pipet tips in 1.5mL tube.','Prepare tube'));
        Steps(i) = 100*StepsPerRev*microsteps;
        Steppers = round(Steps);
        MOVEena(Steppers,1);
        uiwait(msgbox('Unload pumped volume.','Unload Sample'));
        DISABLE_ALL;
        uiwait(msgbox('Measure pumped volume.','Measure volume'));
        definput = {num2str(str2num(get(GuIformat.CalibVolEDT(i),'String'))*100)};
        answer = inputdlg('Enter volume in uL',...
            'Volume',...
            [1 50],...
            definput);
        set(GuIformat.CalibVolEDT(i),'String',str2num(answer{1})/100);
        UpdateSettings;
        LR2pause;
        DISABLE_ALL;
    end
end

%% PANEL CONTROL

function DirectControlPanel
global vc VIDs GuIformat Panels;
Control = uipanel('Visible','on',...
    'Position',[0 .975 1 .025]);
STEPPERSLIST = 'XYZD123';
for i = 1:GuIformat.StepperCount
    GuIformat.StepperPOS(i) = uicontrol(Control,...
        'Units','normalized',...
        'Style','Text',...
        'String',VIDs.crrntSTEPS(i),...
        'Position',[(i-1)/GuIformat.StepperCount .5 1/GuIformat.StepperCount .5],...
        'HandleVisibility','off');
    GuIformat.StepperAngle(i) = uicontrol(Control,...
        'Units','normalized',...
        'Style','Text',...
        'String',VIDs.crrntSTEPS(i),...
        'Position',[(i-1)/GuIformat.StepperCount 0 1/GuIformat.StepperCount .5],...
        'HandleVisibility','off');
end
end

function ManualControlPanel

global VIDs GuIformat Panels;

ControlPos = uipanel(Panels.ControlPanel,...
    'Visible','on',...
    'Position',[0 0 .25 1]);

ControlSyr = uipanel(ControlPos,...
    'Visible','on',...
    'Position',[0 .45 1 .55]);

PumpNames = {'Waste','1','2','3','4','5','6','7','8','9'}

for i = 1:GuIformat.PumpCount
    ControlSyrInd(i) = uipanel(ControlSyr,...
        'Visible','on',...
        'Position',[0 ((GuIformat.PumpCount+1)-i)/(GuIformat.PumpCount+1) 1 1/(GuIformat.PumpCount+1)]);
    GuIformat.SyrType(i) = uicontrol(ControlSyrInd(i),...
        'Units','normalized',...
        'Style','popupmenu',...
        'Value',4,...
        'String',{'3mL','15mL','50mL','Peristaltic'},...
        'Position',[0 0 1/4 1],...
        'HandleVisibility','off');
    GuIformat.SyrAmo(i) = uicontrol(ControlSyrInd(i),...
        'Units','normalized',...
        'Style','Edit',...
        'String','100',...
        'Position',[1/4 0 3/16 1],...
        'HandleVisibility','off');
    GuIformat.SyrTXT(i) = uicontrol(ControlSyrInd(i),...
        'Units','normalized',...
        'Style','text',...
        'String','uL',...
        'Position',[7/16 0 1/16 1],...
        'HandleVisibility','off');
    GuIformat.SyrADD(i) = uicontrol(ControlSyrInd(i),...
        'Units','normalized',...
        'Style','Pushbutton',...
        'String',strcat('ADD',{' '},PumpNames{i}),...
        'Userdata',[i,1],...
        'Position',[2/4 0 1/4 1],...
        'HandleVisibility','off',...
        'BackgroundColor',GuIformat.color.c,...
        'Callback',@ManualADD_PBCallback);
    GuIformat.SyrSUB(i) = uicontrol(ControlSyrInd(i),...
        'Units','normalized',...
        'Style','Pushbutton',...
        'String',strcat('SUBTRACT',{' '},PumpNames{i}),...
        'Userdata',[i,-1],...
        'Position',[3/4 0 1/4 1],...
        'HandleVisibility','off',...
        'BackgroundColor',GuIformat.color.c,...
        'Callback',@ManualADD_PBCallback);
end

    function ManualADD_PBCallback(hObject,callbackdata)
        for q = 1:GuIformat.PumpCount
            set(GuIformat.SyrADD(q),'Enable','Off');
            set(GuIformat.SyrSUB(q),'Enable','Off');
        end
        UpdateMaxSpeed
        NUM = get(hObject,'Userdata');
        PUMP = NUM(1);
        DIRECTION = NUM(2);
        SyrAmo = str2num(get(GuIformat.SyrAmo(PUMP),'String'));
        VOLUMES = zeros(1,GuIformat.ReagentCount);
        SUCTION = 0;
        if PUMP == 1
            SUCTION = DIRECTION*SyrAmo;
        else
            VOLUMES(PUMP-1) = DIRECTION*SyrAmo;
        end
        STYLE = 2;
        SyringeMove(VOLUMES,SUCTION,STYLE,1)
        UpdateSettings
        for q = 1:GuIformat.PumpCount
            set(GuIformat.SyrADD(q),'Enable','On');
            set(GuIformat.SyrSUB(q),'Enable','On');
        end
    end

ControlSyrClean = uipanel(ControlSyr,...
    'Visible','on',...
    'Position',[0 (10-10)/10 1 1/10]);
GuIformat.SyrClean = uicontrol(ControlSyrClean,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Clean',...
    'Position',[0 1/2 1 1/2],...
    'HandleVisibility','off',...
    'Callback',@CleanPumps_PBCallback);
    function CleanPumps_PBCallback(hObject,callbackdata)
        CleanRobot
    end
GuIformat.SyrLoad = uicontrol(ControlSyrClean,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Load',...
    'Position',[0 0 1 1/2],...
    'HandleVisibility','off',...
    'Callback',@LoadPumps_PBCallback);
    function LoadPumps_PBCallback(hObject,callbackdata)
        LoadLiquids
    end


ControlPBs = uipanel(ControlPos,...
    'Visible','on',...
    'Position',[0 .05 1 .4]);

GuIformat.movePB(2,1)= uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Forward',...
    'UserData',VIDs.Forward,...
    'Position',[0/3 2/3 2/3 1/3],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);
GuIformat.movePB(1,1) = uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Left',...
    'UserData',VIDs.Left,...
    'Position',[0/3 1/3 1/3 1/3],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);
GuIformat.movePB(1,2) = uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Right',...
    'UserData',VIDs.Right,...
    'Position',[1/3 1/3 1/3 1/3],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);
GuIformat.movePB(2,2) = uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Backward',...
    'UserData',VIDs.Backward,...
    'Position',[0/3 0/3 2/3 1/3],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);
GuIformat.movePB(3,1) = uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Up',...
    'UserData',VIDs.Up,...
    'Position',[2/3 3/6 1/3 3/6],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);
GuIformat.movePB(3,2) = uicontrol(ControlPBs,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Down',...
    'UserData',VIDs.Down,...
    'Position',[2/3 0/6 1/3 3/6],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ManualMove_PBCallback);

ControlEDTs = uipanel(ControlPos,...
    'Visible','on',...
    'Position',[0 0 1 .05]);

GuIformat.DistTXT = uicontrol(ControlEDTs,...
    'Units','normalized',...
    'Style','text',...
    'String','Distance (mm):',...
    'Position',[0 0 .5 1],...
    'HandleVisibility','off');
GuIformat.DistEDT = uicontrol(ControlEDTs,...
    'Units','normalized',...
    'Style','edit',...
    'String','5',...
    'Position',[.5 0 .5 1],...
    'HandleVisibility','off');

    function ManualMove_PBCallback(hObject,callbackdata)
        GuIformat.STOP = 0;
        Direction = get(hObject,'UserData');
        Distance = str2num(get(GuIformat.DistEDT,'String'));
        Vector = Direction*Distance;
        Location = VIDs.crrntXYZmm + Vector;
        set(hObject,'BackgroundColor',GuIformat.color.o);
        set(hObject,'Enable','Off');
        if Location(1) ~= 0 && Location(2) ~= 0
            Go2XY_mm([Location(1),Location(2)],1);
        end
        
        Go2Z(Location(3));
        
        set(hObject,'BackgroundColor',GuIformat.color.c);
        set(hObject,'Enable','On');
        GuIformat.STOP = 1;
    end

end

function PlateControlPanel

global a VIDs GuIformat BoxInfo Panels;

Control = uipanel(Panels.ControlPanel,...
    'Visible','on',...
    'Position',[.25 0 .75 1]);

%% Maintenance buttons

Maintenance = uipanel(Control,'Visible','on',...
    'Position',[0 0 1 .1]);


Zpos = {'Enclosure Top','Plate Top','Plate Bottom'};

for i = 1:3
    ZBreadthPanel(i) = uipanel(Maintenance,'Visible','on',...
        'Position',[(i-1)/4 0 (1/4) (1)]);
    GuIformat.Zset(i) = uicontrol(ZBreadthPanel(i),...
        'Units','normalized',...
        'Style','Pushbutton',...
        'String',strcat({'Set '},Zpos{i},{' Height'}),...
        'Position',[0 2/3 1 1/3],...
        'Userdata',i,...
        'BackgroundColor',GuIformat.color.c,...
        'HandleVisibility','off',...
        'Callback',@ZlayerSet_Callback);
    GuIformat.Zgo(i) = uicontrol(ZBreadthPanel(i),...
        'Units','normalized',...
        'Style','Pushbutton',...
        'String',strcat({'Go to '},Zpos{i}),...
        'Position',[0 1/3 1 1/3],...
        'Userdata',i,...
        'BackgroundColor',GuIformat.color.c,...
        'HandleVisibility','off',...
        'Callback',@ZlayerGo_Callback);
    GuIformat.Zlayer(i) = uicontrol(ZBreadthPanel(i),...
        'Units','normalized',...
        'Style','Edit',...
        'Userdata',i,...
        'String',GuIformat.ZValues(i),...
        'Position',[0 0/3 1 1/3],...
        'HandleVisibility','off',...
        'Callback',@ZlayerSet_Callback);
end

    function ZlayerGo_Callback(hObject,callbackdata)
        pos = get(hObject,'Userdata');
        GOTOLAYER(pos,0);
    end

    function ZlayerSet_Callback(hObject,callbackdata)
        pos = get(hObject,'Userdata');
        height = VIDs.crrntSTEPS(3);
        set(GuIformat.Zlayer(pos),'String',num2str(height));
        GuIformat.ZValues(pos) = height;
        UpdateSettings;
    end


GuIformat.HOMEPB = uicontrol(Maintenance,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Home XYZ',...
    'Position',[.75 0 .15 1],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@HOME_PBCallback);

    function HOME_PBCallback(hObject,callbackdata)
        HOMEXYZ;
    end

%% Disable Motors
GuIformat.DisablePB = uicontrol(Maintenance,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Disable Motors',...
    'Position',[.9 0 .1 1],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@Disable_PBCallback);

    function Disable_PBCallback(hObject,callbackdata)
        DISABLE_ALL;
    end

%% Tab Group

TABGROUP = uitabgroup(Control,'Visible','on',...
    'Position',[0 .1 1 .9]);

%% 96 Well Plate Buttons
Plate96TAB = uitab('Parent',TABGROUP,'Title','96 Well Plate');
Control96 = uipanel(Plate96TAB,'Visible','on',...
    'Position',[0 .1 1 .9]);

Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

for x = 1:12
    for y = 1:8
        GuIformat.w96(x,y) = uicontrol(Control96,...
            'Units','normalized',...
            'Style','Togglebutton',...
            'String',strcat(Alphabet(y),num2str(x)),...
            'UserData',[96,x,y],...
            'Position',[(x-1)/12 (8-y)/8 1/12 1/8],...
            'HandleVisibility','off',...
            'BackgroundColor',GuIformat.color.c,...
            'Callback',@MoveWellPlate_PBCallback);
    end
end

Setup96 = uipanel(Plate96TAB,'Visible','on',...
    'Position',[0 0 1 .1]);

Calibrate96 = uipanel(Setup96,'Visible','on',...
    'Position',[0 0 1 1]);

WellXOffset = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Text',...
    'String','X Offset (mm):',...
    'Position',[0/5 1/2 1/5 1/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c);
GuIformat.WellXOffset(1) = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Edit',...
    'String','2.5',...
    'Position',[1/5 1/2 1/5 1/2],...
    'HandleVisibility','off');
WellYOffset = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Text',...
    'String','Y Offset (mm):',...
    'Position',[0/5 0/2 1/5 1/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c);
GuIformat.WellYOffset(1) = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Edit',...
    'String','2.5',...
    'Position',[1/5 0/2 1/5 1/2],...
    'HandleVisibility','off');
GuIformat.WellGoBackOffset(1) = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Go Back',...
    'Userdata',96,...
    'Position',[2/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@GoBackOffset_PBCallback);
GuIformat.WellGo2Offset(1) = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Go to Offset',...
    'Userdata',96,...
    'Position',[3/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@Go2Offset_PBCallback);
GuIformat.WellSetOffset(1) = uicontrol(Calibrate96,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Set Offset',...
    'Userdata',96,...
    'Position',[4/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@SetOffset_PBCallback);

%% 384 Well Plate Buttons
Plate384TAB = uitab('Parent',TABGROUP,'Title','384 Well Plate');
Control384 = uipanel(Plate384TAB,'Visible','on',...
    'Position',[0 .1 1 .9]);

Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
for x = 1:24
    for y = 1:16
        GuIformat.w384(x,y) = uicontrol(Control384,...
            'Units','normalized',...
            'Style','Togglebutton',...
            'String',strcat(Alphabet(y),num2str(x)),...
            'UserData',[384,x,y],...
            'Position',[(x-1)/24 (16-y)/16 1/24 1/16],...
            'HandleVisibility','off',...
            'BackgroundColor',GuIformat.color.c,...
            'Callback',@MoveWellPlate_PBCallback);
    end
end

    function MoveWellPlate_PBCallback(hObject,callbackdata)
        set(hObject,'BackgroundColor',GuIformat.color.o);
        DATA = get(hObject,'UserData');
        TYPE = DATA(1);
        WELL = DATA(2:3);
        if GuIformat.ShiftState == 0
            LAYER = 2;
        else
            LAYER = 3;
        end
        
        GOTOWELL(TYPE, WELL, LAYER);
        set(hObject,'BackgroundColor',GuIformat.color.c);
    end

Setup384 = uipanel(Plate384TAB,'Visible','on',...
    'Position',[0 0 1 .1]);

Calibrate384 = uipanel(Setup384,'Visible','on',...
    'Position',[0 0 1 1]);

WellXOffset = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Text',...
    'String','X Offset (mm):',...
    'Position',[0/5 1/2 1/5 1/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c);
GuIformat.WellXOffset(2) = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Edit',...
    'String','2.5',...
    'Position',[1/5 1/2 1/5 1/2],...
    'HandleVisibility','off');
WellYOffset = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Text',...
    'String','Y Offset (mm):',...
    'Position',[0/5 0/2 1/5 1/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c);
GuIformat.WellYOffset(2) = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Edit',...
    'String','2.5',...
    'Position',[1/5 0/2 1/5 1/2],...
    'HandleVisibility','off');
GuIformat.WellGoBackOffset(2) = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Go Back',...
    'Userdata',384,...
    'Position',[2/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@GoBackOffset_PBCallback);
    function GoBackOffset_PBCallback(hObject,callbackdata)
        TYPE = get(hObject,'Userdata')
        if TYPE == 96
            TYPE = 1;
        elseif TYPE == 384
            TYPE = 2;
        end
        Ymm = str2num(get(GuIformat.WellXOffset(TYPE),'String'));
        Xmm = str2num(get(GuIformat.WellYOffset(TYPE),'String'));
        Location(1) = VIDs.crrntXYZmm(1) + Xmm;
        Location(2) = VIDs.crrntXYZmm(2) - Ymm;
        Go2XY_mm(Location,1)
    end
GuIformat.WellGo2Offset(2) = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Go to Offset',...
    'Userdata',384,...
    'Position',[3/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@Go2Offset_PBCallback);
    function Go2Offset_PBCallback(hObject,callbackdata)
        TYPE = get(hObject,'Userdata')
        if TYPE == 96
            TYPE = 1;
        elseif TYPE == 384
            TYPE = 2;
        end
        Ymm = str2num(get(GuIformat.WellXOffset(TYPE),'String'));
        Xmm = str2num(get(GuIformat.WellYOffset(TYPE),'String'));
        Location(1) = VIDs.crrntXYZmm(1) - Xmm;
        Location(2) = VIDs.crrntXYZmm(2) + Ymm;
        Go2XY_mm(Location,1)
    end
GuIformat.WellSetOffset(2) = uicontrol(Calibrate384,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Set Offset',...
    'Userdata',384,...
    'Position',[4/5 0/2 1/5 2/2],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@SetOffset_PBCallback);
    function SetOffset_PBCallback(hObject,callbackdata)
        TYPE = get(hObject,'Userdata')
        if TYPE == 96
            TYPE = 1;
        elseif TYPE == 384
            TYPE = 2;
        end
        Ymm = str2num(get(GuIformat.WellXOffset(TYPE),'String'));
        Xmm = str2num(get(GuIformat.WellYOffset(TYPE),'String'));
        if TYPE == 1
            for x = 1:12
                GuIformat.w96POSmm.x(x) = GuIformat.w96POSmm.x(x) + Ymm;
            end
            for y = 1:8
                GuIformat.w96POSmm.y(y) = GuIformat.w96POSmm.y(y) - Xmm;
            end
        elseif TYPE == 2
            for x = 1:24
                GuIformat.w384POSmm.x(x) = GuIformat.w384POSmm.x(x) + Ymm;
            end
            for y = 1:16
                GuIformat.w384POSmm.y(y) = GuIformat.w384POSmm.y(y) - Xmm;
            end
        end
        UpdateSettings
        HOMEXYZ
    end

end

function ArduinoConnectPanel

global VIDs GuIformat BoxInfo Panels;

ControlBig = uipanel('Visible','on',...
    'Position',[0 0 1 .05]);

Control = uipanel(ControlBig,'Visible','on',...
    'Position',[0 0 0.35 1]);

%% Button Group
GuIformat.PORTtxt = uicontrol(Control,...
    'Units','normalized',...
    'Style','text',...
    'String','Port:',...
    'Position',[0 0 .125 .6],...
    'HandleVisibility','off');
GuIformat.PORTedt = uicontrol(Control,...
    'Units','normalized',...
    'Style','edit',...
    'String',BoxInfo.PORT,...
    'Position',[.125 0 .125 1],...
    'HandleVisibility','off',...
    'Callback',@UpdatePort_GUI);
    function UpdatePort_GUI(hObject,callbackdata)
        UpdateSettings();
    end
GuIformat.DetectPort = uicontrol(Control,...
    'Units','normalized',...
    'Style','togglebutton',...
    'String','Detect Port',...
    'Value',0,...
    'Position',[.25 0 .25 1],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@DetectPort_PBCallback);
    function DetectPort_PBCallback(hObject,callbackdata)
        freeports = seriallist("available");
        [indx,tf] = listdlg('ListString',freeports,'SelectionMode','single')
        if tf == 1
            set(GuIformat.PORTedt,'String',freeports{indx}(4:length(freeports{indx})))
        end
    end
GuIformat.ADConnectPB = uicontrol(Control,...
    'Units','normalized',...
    'Style','togglebutton',...
    'String','Connect',...
    'Value',0,...
    'Position',[.5 0 .25 1],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@ADConnect_PBCallback);
    function ADConnect_PBCallback(hObject,callbackdata)
        State = get(hObject,'Value');
        if State == 0
            HOMEXYZ;
            DISABLE_ALL
            if ~isempty(instrfind)
                DISABLE_ALL;
                fclose(instrfind);
                delete(instrfind);
            end
            set(hObject,'Value',0);
            set(hObject,'String','Connect');
            set(hObject,'BackgroundColor',GuIformat.color.c);
            GuIformat.DEBUGMODE = 1;
        else
            CONN = waitbar(0,'Connecting to Arduino...');
            
            PORT = strcat('COM',get(GuIformat.PORTedt,'String'));
            global a;
            a=serial(PORT); % assign serial port object
            set(a, 'BaudRate', 9600); % set BaudRate to 9600
            set(a, 'Parity', 'none'); % set Parity Bit to None
            set(a, 'DataBits', 8); % set DataBits to 8
            set(a, 'StopBit', 1); % set StopBit to 1
            set(a, 'TimeOut', 60*5); % set StopBit to 1
            %display the properties of serial port object in MATLAB Window
            disp(get(a,{'Type','Name','Port','BaudRate','Parity','DataBits','StopBits','TimeOut'}));
            waitbar(1/3,CONN)
            fopen(a); % Open Serial Port Object
            GuIformat.DEBUGMODE = 0;
            disp('Serial port is opened');
            set(hObject,'Value',1);
            set(hObject,'String','Disconnect');
            set(hObject,'BackgroundColor',GuIformat.color.o);
            pause(2);
            waitbar(2/3,CONN)
            UpdateSettings;
            
            DISABLE_ALL
            close(CONN)
            uiwait(warndlg('PHIL Connected','Connected'));
        end
    end
GuIformat.Connect_HomePB = uicontrol(Control,...
    'Units','normalized',...
    'Style','togglebutton',...
    'String','Home',...
    'Value',0,...
    'Position',[.75 0 .25 1],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@HOMEXYZ_PBCallback);
    function HOMEXYZ_PBCallback(hObject,callbackdata)
        HOMEXYZ;
    end

Configuration = uipanel(ControlBig,'Visible','on',...
    'Position',[.35 0 0.65 1]);

ConfigLoctxt = uicontrol(Configuration,...
    'Units','normalized',...
    'Style','text',...
    'String','Configuration File:',...
    'Position',[0 1/2 3/6 1/2],...
    'HandleVisibility','off');
GuIformat.ConfigLocEDT = uicontrol(Configuration,...
    'Units','normalized',...
    'Style','edit',...
    'String',fullfile(GuIformat.Configpathname,GuIformat.Configfilename),...
    'Position',[0 0 3/6 1/2],...
    'HandleVisibility','off');

GuIformat.ConfigBrowsePB = uicontrol(Configuration,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Browse',...
    'Position',[3/6 0 1/6 1],...
    'HandleVisibility','off',...
    'Callback',@ConfigBrowse_PBCallback);
    function ConfigBrowse_PBCallback(hObject,callbackdata)
        [GuIformat.Configfilename, GuIformat.Configpathname] = uigetfile('*.mat', 'Pick a MATLAB code file');
        set(GuIformat.ConfigLocEDT,'String',fullfile(GuIformat.Configpathname,GuIformat.Configfilename))
    end
GuIformat.ConfigLoadPB = uicontrol(Configuration,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Load Configuration',...
    'Position',[4/6 0 1/6 1],...
    'HandleVisibility','off',...
    'Callback',@ConfigLoad_PBCallback);
    function ConfigLoad_PBCallback(hObject,callbackdata)
        LoadConfig(GuIformat.Configpathname,GuIformat.Configfilename)
        set(GuIformat.ConfigLocEDT,'String',fullfile(GuIformat.Configpathname,GuIformat.Configfilename))
    end
GuIformat.ConfigSavePB = uicontrol(Configuration,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Save Configuration',...
    'Position',[5/6 0 1/6 1],...
    'HandleVisibility','off',...
    'Callback',@ConfigSave_PBCallback);
    function ConfigSave_PBCallback(hObject,callbackdata)
        DATE = datestr(now,'yymmdd');
        [GuIformat.Configfilename,GuIformat.Configpathname] = uiputfile('.mat','File Selection',horzcat(DATE,'_Configuration.mat'));
        UpdateSettings;
        set(GuIformat.ConfigLocEDT,'String',fullfile(GuIformat.Configpathname,GuIformat.Configfilename))
    end

end

%% PANEL SCRIPTING

function ScriptingPanel
global vc VIDs GuIformat Panels Scripting;

Control = uipanel(Panels.ScriptingPanel,...
    'Visible','on',...
    'Position',[0 0 1 1]);

GeneralScripting = uipanel(Control,...
    'Visible','on',...
    'Position',[0 0 .15 1]);

ParameterCount = 30;

%% EXPERIMENT DESCRIPTION
crrntParameter = 1;
EDTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Experiment:',...
    'Position',[0 (ParameterCount - crrntParameter)/ParameterCount 1 1/ParameterCount],...
    'HandleVisibility','off');
crrntParameter = crrntParameter + 1;
InitialsTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','User Initials:',...
    'Position',[0 (ParameterCount - crrntParameter)/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');
Scripting.InitialsEDT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','edit',...
    'Tooltip','Example: PD',...
    'String','',...
    'Position',[.5 ((ParameterCount - crrntParameter))/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');

crrntParameter = crrntParameter + 1;
MicroscopeTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Microscope:',...
    'Position',[0 (ParameterCount - crrntParameter)/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');
Scripting.MicroscopeEDT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','Edit',...
    'String','11',...
    'Position',[.5 ((ParameterCount - crrntParameter))/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');

%% REAGENT NAMES
crrntParameter = crrntParameter + 1;
PumpNameSTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Reagent Names:',...
    'Position',[0 (ParameterCount - crrntParameter)/ParameterCount 1 1/ParameterCount],...
    'HandleVisibility','off');
for REAGENT = 1:GuIformat.ReagentCount
    crrntParameter = crrntParameter + 1;
    
    Scripting.ReagentPanel(REAGENT) = uipanel(GeneralScripting,...
        'Visible','on',...
        'Position',[0 (ParameterCount - crrntParameter)/ParameterCount 1 1/ParameterCount]);
    
    PumpNameTXT = uicontrol(Scripting.ReagentPanel(REAGENT),...
        'Units','normalized',...
        'Style','text',...
        'String',strcat({'Reagent '},num2str(REAGENT)),...
        'Position',[0 0 .25 1],...
        'HandleVisibility','off');
    Scripting.PumpNameEDT(REAGENT) = uicontrol(Scripting.ReagentPanel(REAGENT),...
        'Units','normalized',...
        'Style','edit',...
        'String','',...
        'Position',[.25 0 .75 1],...
        'HandleVisibility','off');
end

%% PLATE TYPE

crrntParameter = crrntParameter + 1;
GeneralSettingsTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Experimental Parameters:',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount 1 1/ParameterCount],...
    'HandleVisibility','off');
crrntParameter = crrntParameter + 1;
PlateTypeTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Plate Type:',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');
Scripting.PlateTypePUM = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','popupmenu',...
    'Tooltip','What kind of plate do you want to use?',...
    'Value',3,...
    'UserData',[2,3;4,6;8,12;16,24;],...
    'String',{'2x3 Wells','4x6 Wells','8x12 Wells','16x24 Wells'},...
    'Position',[.5 ((ParameterCount - crrntParameter))/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off')

%% STEP COUNT
crrntParameter = crrntParameter + 1;
StepCountTXT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','text',...
    'String','Steps:',...
    'Position',[0 (ParameterCount - crrntParameter)/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');
Scripting.StepCountEDT = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','edit',...
    'String','1',...
    'Tooltip','How many times should the robot interact with the plate?',...
    'Position',[.5 ((ParameterCount - crrntParameter))/ParameterCount .5 1/ParameterCount],...
    'HandleVisibility','off');

%% GENERATE TABS
crrntParameter = ParameterCount-6;
Scripting.GenerateTabsPB = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Generate Steps',...
    'Tooltip','Produce an empty protocol using the provided information.',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount 1 2/ParameterCount],...
    'HandleVisibility','off',...
    'Callback',@GenerateScriptingTABS);
    function GenerateScriptingTABS(hObject,callbackdata)
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Scripting.CrrntPMPVal = zeros(1,GuIformat.ReagentCount);
        
        PlateTypeVal = get(Scripting.PlateTypePUM,'Value');
        PlateTypeDims = get(Scripting.PlateTypePUM,'UserData');
        PlateDimensions = PlateTypeDims(PlateTypeVal,:)
        XX = PlateDimensions(2);
        YY = PlateDimensions(1);
        
        
        if PlateTypeVal == 1
            FontSIZE = 16;
            WellVolume = 2000;
            SuctionVolume = 2500;
        elseif PlateTypeVal == 2
            FontSIZE = 12
            WellVolume = 500;
            SuctionVolume = 600;
        elseif PlateTypeVal == 3
            FontSIZE = 8
            WellVolume = 100;
            SuctionVolume = 150;
        elseif PlateTypeVal == 4
            FontSIZE = 6
            WellVolume = 25;
            SuctionVolume = 30;
        elseif PlateTypeVal == 5
            FontSIZE = 8
            WellVolume = 120;
            SuctionVolume = 170;
        end
        
        
        StepCount = str2num(get(Scripting.StepCountEDT,'String'));
        ParameterCount = 40;
        crrntParameter = 1;
        
        clear Scripting.StepGROUP
        Scripting.StepGROUP = uitabgroup(Scripting.ExperimentScripting,'Visible','on',...
            'Position',[0 0 1 1]);
        h = waitbar(0,'Generating Layout...');
        %% SET INPUT NAMES
        for REAGENT = 1:GuIformat.ReagentCount
            String = '';
            set(Scripting.PumpNameEDT(REAGENT),'String', String);
        end
        for STEP = 1:abs(StepCount)
            waitbar(STEP/abs(StepCount),h)
            Scripting.ScriptingTAB(STEP) = uitab('Parent',Scripting.StepGROUP,'Title',strcat('Step ',num2str(STEP)));
            Scripting.SettingsPanel(STEP) = uipanel(Scripting.ScriptingTAB(STEP),...
                'Position',[.8 0 .2 1]);
            
            
            %% PIPETTE TYPE
            ParameterCount = 40;
            crrntParameter = 1;
            PipetteTypeTXT = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','text',...
                'String','Pipette Order:',...
                'Position',[0 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            Scripting.PipetteTypePUM(STEP) = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','popupmenu',...
                'Tooltip','Should the robot remove existing media before adding new media or add and subtract simultaneously?',...
                'Value',1,...
                'String',{'Suction First','Simultaneous','Dynamic'},...
                'Position',[.5 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            
            %% WELL VOLUME
            crrntParameter = crrntParameter + 1;
            WellVolumeTXT = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','text',...
                'String','Volume (uL):',...
                'Position',[0 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            Scripting.WellVolumeEDT(STEP) = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','edit',...
                'Tooltip','What is the total volume you want P.Hi.L. to pipette?',...
                'String',WellVolume,...
                'Position',[.5 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            
            %% SUCTION VOLUME
            crrntParameter = crrntParameter + 1;
            SuctionVolumeTXT = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','text',...
                'String','Suction (uL):',...
                'Position',[0 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            Scripting.SuctionVolumeEDT(STEP) = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','edit',...
                'Tooltip','What is the total volume you want P.Hi.L. to remove?',...
                'String',SuctionVolume,...
                'Position',[.5 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            
            %% REPETITIONS
            crrntParameter = crrntParameter + 1;
            StepRepTXT = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','text',...
                'String','Repetitions:',...
                'Position',[0 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            Scripting.StepRepEDT(STEP) = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','edit',...
                'Tooltip','How many times should the robot repeat this step without a delay?',...
                'String','1',...
                'Position',[.5 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            
            %% STEP DELAY
            crrntParameter = crrntParameter + 1;
            StepDelayTXT = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','text',...
                'String','Step Delay (min):',...
                'Position',[0 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            Scripting.StepDelayEDT(STEP) = uicontrol(Scripting.SettingsPanel(STEP),...
                'Units','normalized',...
                'Style','edit',...
                'Tooltip','How long should P.Hi.L. wait before moving to the next step?',...
                'String','60',...
                'Position',[.5 (ParameterCount-crrntParameter)/ParameterCount .5 1/ParameterCount],...
                'HandleVisibility','off');
            
            %% GENERATE COORDS
            
            Scripting.wellsPanel(STEP) = uipanel(Scripting.ScriptingTAB(STEP),...
                'Position',[0 0 .8 1]);
            Scripting.ButtonsPanel(STEP) = uipanel(Scripting.wellsPanel(STEP),...
                'Position',[.03 0 .97 .97]);
            
            
            Scripting.RowsPanel(STEP) = uipanel(Scripting.wellsPanel(STEP),...
                'Position',[.03 .97 .97 .03],...
                'BackgroundColor',[1 1 1]);
            for x = 1:XX
                RowTXT = uicontrol(Scripting.RowsPanel(STEP),...
                    'Units','normalized',...
                    'Position',[(x-1)/XX 0 1/XX 1],...
                    'Style','Text',...
                    'String',x,...
                    'Enable','On',...
                    'BackgroundColor',[1 1 1]);
            end
            Scripting.ColsPanel(STEP) = uipanel(Scripting.wellsPanel(STEP),...
                'Position',[0 0 .03 .97],...
                'BackgroundColor',[1 1 1]);
            for y = 1:YY
                ColTXT = uicontrol(Scripting.ColsPanel(STEP),...
                    'Units','normalized',...
                    'Position',[0 (YY - y -.5)/YY 1 1/YY],...
                    'Style','Text',...
                    'String',Alphabet(y),...
                    'Enable','On',...
                    'BackgroundColor',[1 1 1]);
            end
            
            %% GENERATE BUTTONS
            for x = 1:XX
                for y = 1:YY
                    USERDATA = zeros(1,GuIformat.ReagentCount+2);
                    USERDATA(1:2) = [x,y];
                    Scripting.wellsPB(x,y,STEP) = uicontrol(Scripting.ButtonsPanel(STEP),...
                        'Units','normalized',...
                        'Position',[(x-1)/XX (YY-y)/YY 1/XX 1/YY],...
                        'Style','pushbutton',...
                        'String',strcat(Alphabet(y),num2str(x)),...
                        'Tooltip',horzcat('Change well'),...
                        'Userdata',USERDATA,...
                        'Enable','On',...
                        'BackgroundColor',[1 1 1],...
                        'FontSize',FontSIZE,...
                        'Callback',@WellSet);
                end
            end
        end
        close(h);
        
    end

    function WellSet(hObject,callbackdata)
        
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Color = zeros(1,GuIformat.ReagentCount);
        for REAGENT = 1:GuIformat.ReagentCount
            pumpNames{REAGENT} = strcat(get(Scripting.PumpNameEDT(REAGENT),'String'),' %:');
        end
        
        crrntPMPUD = get(hObject,'Userdata');
        Xval = Alphabet(crrntPMPUD(2));
        Yval = num2str(crrntPMPUD(1));
        if GuIformat.ShiftState == 0
            for REAGENT = 1:GuIformat.ReagentCount
                definput{REAGENT} = num2str(crrntPMPUD(REAGENT + 2));
            end
            prompt = pumpNames;
            dlgtitle = 'Input';
            dims = [1 35];
            definput = definput;
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            
        else
            for REAGENT = 1:GuIformat.ReagentCount
                definput{REAGENT} = num2str(Scripting.CrrntPMPVal(REAGENT));
            end
            answer = definput;
        end
        
        Total = 0;
        for REAGENT = 1:GuIformat.ReagentCount
            Total = str2num(answer{REAGENT})/100 + Total;
        end
        
        if Total ~= 1
            if Total == 0
                InformTxt = {strcat(Xval,Yval)};
                Scripting.CrrntPMPVal = zeros(1,GuIformat.ReagentCount);
                Impact = 'normal'
                set(hObject,'Userdata',[crrntPMPUD(1),crrntPMPUD(2),Scripting.CrrntPMPVal]);
                set(hObject,'String',InformTxt);
                set(hObject,'FontWeight',Impact);
            else
                f = warndlg('Sum of Percents is not 100.','Warning');
            end
        end
        if Total == 1
            Fraction = zeros(1,GuIformat.ReagentCount);
            count = 0;
            InformTxt = {''};
            for REAGENT = 1:GuIformat.ReagentCount
                Fraction(REAGENT) = str2num(answer{REAGENT});
                Scripting.CrrntPMPVal(REAGENT) = str2num(answer{REAGENT});
                if Fraction(REAGENT) ~= 0
                    count = count + 1;
                    InformTxt{count} = strcat(get(Scripting.PumpNameEDT(REAGENT),'String'),' %: ',num2str(round(Fraction(REAGENT))));
                end
            end
            Impact = 'bold';
            
            set(hObject,'Userdata',[crrntPMPUD(1),crrntPMPUD(2),Scripting.CrrntPMPVal]);
            set(hObject,'String',mLine(InformTxt));
            set(hObject,'FontWeight',Impact);
        end
    end

%% LOAD EXCEL
crrntParameter = ParameterCount-4;
Scripting.LoadExcelPB = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Load Excel',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount 1 2/ParameterCount],...
    'HandleVisibility','off',...
    'Callback',@LoadExcel);

    function LoadExcel(hObject,callbackdata)
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        
        [file,path] = uigetfile('.xls');
        
        [~,~,raw] = xlsread(fullfile(path,file),1)
        
        DATE = raw(2,1);
        INITIALS = raw{2,2};
        MICROSCOPE = raw{2,3};
        PlateTypeVal = raw{2,4};
        PlateTypeVal = PlateTypeVal(1);
        set(Scripting.PlateTypePUM,'Value',PlateTypeVal)
        PlateTypeDims = get(Scripting.PlateTypePUM,'UserData');
        PlateDimensions = PlateTypeDims(PlateTypeVal,:);
        XX = PlateDimensions(2);
        YY = PlateDimensions(1);
        StepCount = raw{2,6};
        StepCount = StepCount(1);
        
        set(Scripting.StepCountEDT,'String', StepCount);
        set(Scripting.InitialsEDT,'String', INITIALS)
        set(Scripting.MicroscopeEDT,'String', MICROSCOPE)
        
        callbackdata = [];
        GenerateScriptingTABS(Scripting.GenerateTabsPB,callbackdata)
        h = waitbar(0,'Filling Layout...');
        
        %% SET INPUT NAMES
        [~,~,raw] = xlsread(fullfile(path,file),2);
        for REAGENT = 1:GuIformat.ReagentCount
            String = raw{((XX + 2) * (REAGENT-1) + 4),1}
            %isempty(raw{((XX + 2) * (REAGENT-1) + 4),1})
            isnan(String)
            if isnan(String)
                String = ''
            end
            set(Scripting.PumpNameEDT(REAGENT),'String', String);
        end
        
        for STEP = 1:abs(StepCount)
            waitbar(STEP/abs(StepCount),h);
            [~,~,raw] = xlsread(fullfile(path,file),STEP + 1);
            
            %% PIPETTE TYPE
            set(Scripting.PipetteTypePUM(STEP),'Value',raw{2,1});
            
            %% WELL VOLUME
            set(Scripting.WellVolumeEDT(STEP),'String',raw{2,2});
            
            %% SUCTION VOLUME
            set(Scripting.SuctionVolumeEDT(STEP),'String',raw{2,5});
            
            %% REPETITIONS
            set(Scripting.StepRepEDT(STEP),'String',raw{2,3});
            
            %% STEP DELAY
            set(Scripting.StepDelayEDT(STEP),'String',raw{2,4});
            
            %% POPULATE BUTTONS
            for x = 1:XX
                for y = 1:YY
                    USERDATA = get(Scripting.wellsPB(x,y,STEP),'Userdata');
                    for REAGENT = 1:GuIformat.ReagentCount
                        USERDATA(REAGENT + 2) = raw{((XX + 2) * (REAGENT-1) + y + 4),x};
                    end
                    set(Scripting.wellsPB(x,y,STEP),'Userdata',USERDATA);
                    Total = sum(USERDATA(3:GuIformat.ReagentCount+2))/100;
                    if Total == 1
                        Fraction = zeros(1,GuIformat.ReagentCount);
                        count = 0;
                        InformTxt = {''};
                        for REAGENT = 1:GuIformat.ReagentCount
                            set(Scripting.wellsPB(x,y,STEP),'FontWeight','Bold')
                            Fraction(REAGENT) = USERDATA(REAGENT + 2)/100;
                            if Fraction(REAGENT) ~= 0
                                count = count + 1;
                                InformTxt{count} = strcat(get(Scripting.PumpNameEDT(REAGENT),'String'),' %: ',num2str(round(Fraction(REAGENT)*100)))
                            end
                        end
                        set(Scripting.wellsPB(x,y,STEP),'String',mLine(InformTxt));
                    end
                end
            end
        end
        
        close(h)
    end

%% SAVE EXCEL
crrntParameter = ParameterCount-2;
Scripting.SaveExcelPB = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','pushbutton',...
    'String','Save Excel',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount 1 2/ParameterCount],...
    'HandleVisibility','off',...
    'Callback',@SaveExcel);

    function SaveExcel(hObject,callbackdata)
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        
        PlateTypeVal = get(Scripting.PlateTypePUM,'Value');
        PlateTypeDims = get(Scripting.PlateTypePUM,'UserData');
        PlateDimensions = PlateTypeDims(PlateTypeVal,:);
        XX = PlateDimensions(2);
        YY = PlateDimensions(1);
        StepCount = str2num(get(Scripting.StepCountEDT,'String'));
        
        DATE = datestr(now,'yymmdd');
        INITIALS = get(Scripting.InitialsEDT,'String');
        MICROSCOPE = get(Scripting.MicroscopeEDT,'String');
        [file,path] = uiputfile('.xls','File Selection',horzcat(DATE,INITIALS,MICROSCOPE,'.xls'));
        h = waitbar(0,'Saving Experiment...');
        XLSX_Cell = cell(((XX + 2) * 5 + XX),24);
        XLSX_Cell{1,1} = 'DATE';
        XLSX_Cell{2,1} = DATE;
        XLSX_Cell{1,2} = 'INITIALS';
        XLSX_Cell{2,2} = INITIALS;
        XLSX_Cell{1,3} = 'MICROSCOPE';
        XLSX_Cell{2,3} = MICROSCOPE;
        XLSX_Cell{1,4} = 'PLATE TYPE';
        XLSX_Cell{2,4} = get(Scripting.PlateTypePUM,'Value');
        
        XLSX_Cell{1,6} = 'STEPS';
        XLSX_Cell{2,6} = StepCount;
        
        if isfile(fullfile(path,file))
            delete(fullfile(path,file));
        end
        xlswrite(fullfile(path,file), XLSX_Cell(:,:), 1, 'A1');
        
        for STEP = 1:abs(StepCount)
            XLSX_Cell = cell(((XX + 2) * GuIformat.ReagentCount + XX),24);
            waitbar(STEP/abs(StepCount),h)
            %% PIPETTE TYPE
            XLSX_Cell{1,1} = 'PIPETTE TYPE';
            XLSX_Cell{2,1} = get(Scripting.PipetteTypePUM(STEP),'Value');
            
            %% WELL VOLUME
            XLSX_Cell{1,2} = 'WELL VOLUME';
            XLSX_Cell{2,2} = str2num(get(Scripting.WellVolumeEDT(STEP),'String'));
            
            %% SUCTION VOLUME
            XLSX_Cell{1,5} = 'SUCTION VOLUME';
            XLSX_Cell{2,5} = str2num(get(Scripting.SuctionVolumeEDT(STEP),'String'));
            
            %% REPETITIONS
            crrntParameter = crrntParameter + 1;
            XLSX_Cell{1,3} = 'REPETITIONS';
            XLSX_Cell{2,3} = str2num(get(Scripting.StepRepEDT(STEP),'String'));
            
            %% STEP DELAY
            XLSX_Cell{1,4} = 'DELAY';
            XLSX_Cell{2,4} = str2num(get(Scripting.StepDelayEDT(STEP),'String'));
            
            %% SAVE BUTTONS
            for x = 1:XX
                for y = 1:YY
                    USERDATA = get(Scripting.wellsPB(x,y,STEP),'Userdata');
                    for REAGENT = 1:GuIformat.ReagentCount
                        XLSX_Cell{((XX + 2) * (REAGENT-1) + 4),1} = get(Scripting.PumpNameEDT(REAGENT),'String');
                        XLSX_Cell{((XX + 2) * (REAGENT-1) + y + 4),x} = USERDATA(REAGENT + 2);
                    end
                end
            end
            xlswrite(fullfile(path,file), XLSX_Cell(:,:), STEP + 1, 'A1');
        end
        close(h)
    end

%% RUN EXPERIMENT
crrntParameter = ParameterCount;
Scripting.RunButton = uicontrol(GeneralScripting,...
    'Units','normalized',...
    'Style','togglebutton',...
    'String','Run',...
    'Position',[0 ((ParameterCount - crrntParameter))/ParameterCount 1 2/ParameterCount],...
    'HandleVisibility','off',...
    'BackgroundColor',GuIformat.color.c,...
    'Callback',@RunExp);
    function RunExp(hObject,Callbackdata)
        
        if get(hObject,'Value')
            set(hObject, 'BackgroundColor',GuIformat.color.o);
            %            TSMessage(strcat({' Experiment Stopped'}),GuIformat.ScriptDir);
            set(hObject, 'String','Stop');
            GuIformat.STOP = 0;
            RunPlateSet(AggregatePlateSet);
            set(hObject, 'BackgroundColor',GuIformat.color.c);
            %            TSMessage(strcat({' Experiment Stopped'}),GuIformat.ScriptDir);
            set(hObject, 'String','Run');
            GuIformat.STOP = 1;
            set(hObject,'Value',0)
        else
            set(hObject, 'BackgroundColor',GuIformat.color.c);
            %            TSMessage(strcat({' Experiment Stopped'}),GuIformat.ScriptDir);
            set(hObject, 'String','Run');
            GuIformat.STOP = 1;
        end
        
        
    end


%% SCRIPTING PANEL
Scripting.ExperimentScripting = uipanel(Control,...
    'Visible','on',...
    'Position',[.15 0 .85 1]);

Scripting.StepGROUP = uitabgroup(Scripting.ExperimentScripting,'Visible','on',...
    'Position',[0 0 1 1]);

callbackdata = [];
GenerateScriptingTABS(Scripting.GenerateTabsPB,callbackdata)
end

%% PANEL HEADLESS

function HeadlessPanel
global vc VIDs GuIformat Panels Scripting;

Control = uipanel(Panels.HeadlessPanel,...
    'Visible','on',...
    'Position',[0 0 1 1]);
cndtncnt = 50;
cndtn = 1;

%% Directory

cndtn = cndtn + 1;
GuIformat.DirTxt = uicontrol(Control,...
    'Units','normalized',...
    'Style','Text',...
    'String','Directory :',...
    'Position',[0 (cndtncnt-cndtn)/cndtncnt .15 1/cndtncnt],...
    'HandleVisibility','off');
GuIformat.DirEDT = uicontrol(Control,...
    'Units','normalized',...
    'Style','Edit',...
    'String',cd,...
    'Enable','Off',...
    'Position',[.15 (cndtncnt-cndtn)/cndtncnt .7 1/cndtncnt],...
    'HandleVisibility','off');
GuIformat.DirTB = uicontrol(Control,...
    'Units','normalized',...
    'Style','Pushbutton',...
    'String','Browse',...
    'Position',[.85 (cndtncnt-cndtn)/cndtncnt .15 1/cndtncnt],...
    'HandleVisibility','off',...
    'Callback',@HeadlessBrowsePB);

    function HeadlessBrowsePB(hObject,callbackdata)
        [filename, pathname] = uigetfile('.xlsx');
        set(GuIformat.DirEDT,'String',pathname);
        
        
        
        Files = dir(fullfile(pathname, '*.xlsx'))
        
        set(GuIformat.FilePUM,'String',{Files.name})
        
        Index = find(contains(get(GuIformat.FilePUM,'String'),filename));
        
        set(GuIformat.FilePUM,'Value',Index);
        
        
    end

%% File

cndtn = cndtn + 1;
GuIformat.FileTxt = uicontrol(Control,...
    'Units','normalized',...
    'Style','Text',...
    'String','File (.csv):',...
    'Position',[0 (cndtncnt-cndtn)/cndtncnt .15 1/cndtncnt],...
    'HandleVisibility','off');
GuIformat.FilePUM = uicontrol(Control,...
    'Units','normalized',...
    'Style','Popupmenu',...
    'String',{''},...
    'Position',[.15 (cndtncnt-cndtn)/cndtncnt .5 1/cndtncnt],...
    'HandleVisibility','off');

%% Refresh Rate

cndtn = cndtn + 1;
GuIformat.RefreshTxt = uicontrol(Control,...
    'Units','normalized',...
    'Style','Text',...
    'String','Scan Rate (s):',...
    'Position',[0 (cndtncnt-cndtn)/cndtncnt .15 1/cndtncnt],...
    'HandleVisibility','off');
GuIformat.RefreshEDT = uicontrol(Control,...
    'Units','normalized',...
    'Style','Edit',...
    'String','30',...
    'Position',[.15 (cndtncnt-cndtn)/cndtncnt .5 1/cndtncnt],...
    'HandleVisibility','off');

%% Run

cndtn = cndtn + 1;
GuIformat.HeadlessRunTB = uicontrol(Control,...
    'Units','normalized',...
    'Style','Togglebutton',...
    'String','Run:',...
    'Position',[0 (cndtncnt-cndtn-1)/cndtncnt 1 2/cndtncnt],...
    'HandleVisibility','off',...
    'Callback',@HeadlessRunTB);

    function HeadlessRunTB(hObject,callbackdata)
        
        if get(hObject,'Value')
            set(hObject, 'BackgroundColor',GuIformat.color.o);
            set(hObject, 'String','Stop');
            GuIformat.STOP = 0;
            START = clock
            display('HERE0')
            HOMEXYZ;
            GuIformat.LOADSTATES = zeros(1,GuIformat.ReagentCount);
            % EXECUTE LOOP
            display('HERE1')
            if GuIformat.STOP == 0
                h = waitbar(0,'Running Headless');
            end
            while GuIformat.STOP == 0
                display('HERE2')
                for qz = 1:100
                    waitbar(qz/100, h,'Running Headless')
                    pause(.01)
                end
                Interval = str2num(get(GuIformat.RefreshEDT,'String'));
                if etime(clock, START) > Interval && GuIformat.STOP == 0
                    START = clock;
                    for qz = 1:100
                        waitbar(qz/100, h,'Scanning for Updates')
                        pause(.01)
                    end
                    pathname = get(GuIformat.DirEDT,'String');
                    xlsxnames = get(GuIformat.FilePUM,'String');
                    xlsxselection = get(GuIformat.FilePUM,'Value');
                    filename = xlsxnames{xlsxselection};
                    xlsxpathname = fullfile(pathname,filename);
                    
                    
                    [~,~,raw] = xlsread(xlsxpathname);
                    
                    C = raw(2:end,:);
                    T = cell2table(C);
                    
                    T.Properties.VariableNames = raw(1,:);
                    %T(ismember(T.Status,'Done'),:)=[];
                    d = datetime('now','Format','yyyy-MM-dd HH:mm:ss','convertFrom','datenum');
                    
                    %T(T.DateTime >= d,:) = [];
                    
                    T = sortrows(T,[1,6,4]);
                    NewCMDs = 0;
                    VOLUMES = zeros(GuIformat.ReagentCount,1);
                    for CMD = 1:length(T.DateTime)
                        d = datetime('now','Format','yyyy-MM-dd HH:mm:ss','convertFrom','datenum');
                        (d + 5*60) > T.DateTime(CMD)
                        if ismember(T.Status(CMD),'Waiting') && (d + (5*60)/(24*60*60)) > T.DateTime(CMD) && GuIformat.STOP == 0
                            VOLUMES = VOLUMES + [T.Volume1(CMD),
                                T.Volume2(CMD),
                                T.Volume3(CMD),
                                T.Volume4(CMD),
                                T.Volume5(CMD),
                                T.Volume6(CMD),
                                T.Volume7(CMD),
                                T.Volume8(CMD),
                                T.Volume9(CMD)]
                        end
                    end
                    
                    if sum(abs(VOLUMES)) > 0 && GuIformat.STOP == 0
                        %LoadPumps(VOLUMES)
                    end
                    
                    for CMD = 1:length(T.DateTime)
                        waitbar(CMD/length(T.DateTime), h, 'Handling Commands')
                        d = datetime('now','Format','yyyy-MM-dd HH:mm:ss','convertFrom','datenum');
                        if ismember(T.Status(CMD),'Waiting') && (d + (0*60)/(24*60*60)) > T.DateTime(CMD) && GuIformat.STOP == 0
                            NewCMDs = 1;
                            if ismember(T.Plate(CMD),'96 Well')
                                TYPE = 96
                            elseif ismember(T.Plate(CMD),'384 Well')
                                TYPE = 384
                            end
                            WELL = [T.Column(CMD),T.Row(CMD)]
                            VOLUMES = [T.Volume1(CMD),
                                T.Volume2(CMD),
                                T.Volume3(CMD),
                                T.Volume4(CMD),
                                T.Volume5(CMD),
                                T.Volume6(CMD),
                                T.Volume7(CMD),
                                T.Volume8(CMD),
                                T.Volume9(CMD)]
                            SUCTION = T.Suction(CMD)
                            STYLE = T.Style(CMD)
                            REPS = T.Repetitions(CMD)
                            
                            
                            STRTD = datetime('now','Format','yyyy-MM-dd HH:mm:ss','convertFrom','datenum');
                            T.Started(CMD) = {string(STRTD)};
                            CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
                            NDD = datetime('now','Format','yyyy-MM-dd HH:mm:ss','convertFrom','datenum');
                            T.Ended(CMD) = {string(NDD)};
                            T.Status(CMD) = {'Done'};
                            %                             if NewCMDs == 1
                            %                                 writetable(T,xlsxpathname)
                            %                             end
                        end
                    end
                    
                    if NewCMDs == 1
                        GOTOLAYER(1,1);
                        LR2pause;
                        ConditionalHome
                        writetable(T,xlsxpathname)
                    end
                    
                end
                
                
                pause(.1)
            end
            if ishandle(h)
                close(h);
            end
            set(hObject, 'BackgroundColor',GuIformat.color.c);
            set(hObject, 'String','Run');
            GuIformat.STOP = 1;
        else
            
            
            set(hObject, 'BackgroundColor',GuIformat.color.c);
            set(hObject, 'String','Run');
            GuIformat.STOP = 1;
        end
        
    end

end

%% UTILITY FUNCTIONS
function StepperEnable = GetStepperEnable
global GuIformat VIDs
StepperEnable = zeros(1,GuIformat.StepperCount);
for i = 1:GuIformat.StepperCount
    StepperEnable(i) = get(GuIformat.StepperEnableCB(i),'Value');
end
end

function StepsPerRev = GetStepsPerRev
global GuIformat VIDs
StepsPerRev = zeros(1,GuIformat.StepperCount);
for i = 1:GuIformat.StepperCount
    StepsPerRev(i) = str2num(get(GuIformat.StepsPerRevEDT(i),'String'));
end
end

function MicroSteps = GetMicroSteps
global GuIformat VIDs
MicroSteps = zeros(1,GuIformat.StepperCount);
for i = 1:GuIformat.StepperCount
    MicroSteps(i) = VIDs.MicroStepTypesNum(get(GuIformat.MicrostepPUM(i),'Value'));
end
end

function StepperDirection = GetStepperDirection
global GuIformat VIDs
StepperDirection = zeros(1,GuIformat.StepperCount);
for i = 1:GuIformat.StepperCount
    StepperDirection(i) = GuIformat.StepperDIRS(get(GuIformat.DirectionPUM(i),'Value'));
end
end

function uLPerRev = GetuLPerRev
global GuIformat VIDs
uLPerRev = zeros(1,GuIformat.StepperCount);
for i = 1:GuIformat.StepperCount
    uLPerRev(i) = str2num(get(GuIformat.CalibVolEDT(i),'String'));
end
end

function [Au, idx ,idx2] = uniquecell(A)
%function [Au, idx, idx2] = uniquecell(A)
%For A a cell array of matrices (or vectors), returns
%Au, which contains the unique matrices in A, idx, which contains
%the indices of the last appearance of each such unique matrix, and
%idx2, which contains th indices such that Au(idx2) == A
%
%Example usage:
%
%A = {[1,2,3],[0],[2,3,4],[2,3,1],[1,2,3],[0]};
%[Au,idx,idx2] = uniquecell(A);
%
%Results in:
%idx = [6,5,4,3]
%Au  = {[0],[1,2,3],[2,3,1],[2,3,4]}
%idx2 = [2,1,4,3,2,1]
%
%Algorithm: uses cellfun to translate numeric matrices into strings
%           then calls unique on cell array of strings and reconstructs
%           the initial matrices
%
%See also: unique
B = cellfun(@(x) num2str(x(:)'),A,'UniformOutput',false);
if nargout > 2
    [~,idx,idx2] = unique(B);
    Au = A(idx);
else
    [~,idx] = unique(B);
    Au = A(idx);
end
end

function CleanRobot()
qwa = waitbar(0,'Please wait...');
count = 0;
global GuIformat
HOMEXYZ
% OldZVals = GuIformat.ZValues
% GuIformat.ZValues(1) = 0;
% GuIformat.ZValues(2) = 0;
% GuIformat.ZValues(3) = 5720;

cleaningVol = 2000

%SPEED([10000,10000,6000,6000,120000,120000,120000,120000,120000,120000,120000,120000,120000,120000])
START = clock;
TYPE = 96;
VOLUMES = -cleaningVol*ones(1,GuIformat.PumpCount);%[-5,-5,-5,-5,-5,-5];
SUCTION = cleaningVol;
STYLE = 2;
REPS = 1;
for j = 1:2
    count = count + 1
    waitbar(count/10,qwa,'Cleaning Tubes');
    WELL = [2,2];
    CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
    pause(120);
    count = count + 1
    waitbar(count/10,qwa,'Rinsing Tubes');
    WELL = [7,2];
    CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
    pause(120);
    count = count + 1
    waitbar(count/10,qwa,'Ethanolling Tubes');
    WELL = [11,2];
    CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
    pause(120);
    count = count + 1
    waitbar(count/10,qwa,'Watering Tubes');
    WELL = [11,7];
    CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
    pause(120);
end

count = count + 1
waitbar(count/10,qwa,'Cleaning Tubes');
% WELL = [2,7];
% CHANGEWELL(TYPE,WELL,5*VOLUMES,5*SUCTION,STYLE,REPS)

UpdateSettings
close(qwa)
% GuIformat.ZValues = OldZVals;
HOMEXYZ;
end

function LoadLiquids()
SPEED([10000,10000,6000,120000,120000,120000,120000,120000,120000,120000])
for i = 1:3
    answer = 'No'
    
    opts.Interpreter = 'tex';
    % Include the desired Default answer
    opts.Default = 'No';
    % Use the TeX interpreter to format the question
    quest = strcat({'Is pump '},num2str(i),{' full?'});
    answer = questdlg(quest,strcat('Pump ',num2str(i)),...
        'Yes','No',opts)
    if strcmp(answer,'No')
        Steppers = zeros(1,10);
        Steppers(i+4) = 30000;
        MOVEena(Steppers,0);
    end
    while strcmp(answer, 'No')
        
        opts.Interpreter = 'tex';
        % Include the desired Default answer
        opts.Default = 'No';
        % Use the TeX interpreter to format the question
        quest = strcat({'Is pump '},num2str(i),{' full?'});
        answer = questdlg(quest,strcat('Pump ',num2str(i)),...
            'Yes','No',opts)
        if strcmp(answer,'No')
            Steppers = zeros(1,10);
            Steppers(i+4) = 3000;
            MOVEena(Steppers,0);
        end
    end
end
UpdateSettings

end

%% ARDUINO FUNCTIONALITY

function MICROSTEPS(Steppers)
global a GuIformat

Steppers = round(Steppers);

COMMAND = 'M';

for i = 1:GuIformat.StepperCount
    
    COMMAND = strcat(COMMAND,'+',num2str(Steppers(i)));
    if abs(Steppers(i)) > 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('MICROSTEP WAITING')
        while fgets(a) ~= '*'
            pause(.001)
        end
        display('MICROSTEP DONE')
        %disp('confirmation found')
    end
else
    pause(GuIformat.TESTpause);
end
for i = 1:GuIformat.StepperCount
    set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
end

end

function ENABLE(Steppers)
global a GuIformat

Steppers = round(Steppers);
Steppers(1:2) = 1;

if sum(abs(Steppers(3:4))) > 0
    Steppers(3:4) = 1;
end
COMMAND = 'E';

for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(Steppers(i)*get(GuIformat.StepperEnableCB(i),'Value')));
    if abs(Steppers(i)) > 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('ENABLE WAITING')
        while fgets(a) ~= '*'
            pause(.001)
        end
        display('ENABLE DONE')
    end
else
    pause(GuIformat.TESTpause);
end

end

function ACCELLERATION(Steppers)
global a GuIformat

StepperEnable = GetStepperEnable;
StepsPerRev = GetStepsPerRev;
MicroSteps = GetMicroSteps;
uLPerRev = GetuLPerRev;

StepsPeruL = StepsPerRev./uLPerRev;
MicroStepsPeruL = StepsPeruL.*MicroSteps;
MicroStepsPeruL(1:4) = 1;

Steppers = Steppers.*MicroStepsPeruL;
Steppers = Steppers.*StepperEnable;


COMMAND = 'A';
for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(Steppers(i)));
    if Steppers(i) ~= 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('ACCELERATION WAITING')
        while fgets(a) ~= '*'
            pause(.001)
        end
        display('ACCELERATION DONE')
        %disp('confirmation found')
    end
else
    pause(GuIformat.TESTpause);
end
for i = 1:GuIformat.StepperCount
    set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
end

end

function SPEED(Steppers)
global a GuIformat VIDs

StepperEnable = GetStepperEnable;
StepsPerRev = GetStepsPerRev;
MicroSteps = GetMicroSteps;
uLPerRev = GetuLPerRev;

StepsPeruL = StepsPerRev./uLPerRev;
MicroStepsPeruL = StepsPeruL.*MicroSteps;
MicroStepsPeruL(1:4) = 1;

Steppers = Steppers.*MicroStepsPeruL;
Steppers = Steppers.*StepperEnable;

COMMAND = 'S';
for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(round(Steppers(i))));
    if Steppers(i) ~= 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('SPEED WAITING')
        while fgets(a) ~= '*'
            pause(.001)
        end
        display('SPEED DONE')
        %disp('confirmation found')
    end
else
    pause(GuIformat.TESTpause);
end
for i = 1:GuIformat.StepperCount
    set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
end

end

function MOVE_Ard(Steppers)
global a GuIformat VIDs
VIDs.crrntSTEPS = round(VIDs.crrntSTEPS + Steppers);

MicroSteps = GetMicroSteps;

for i = 1:GuIformat.StepperCount
    set(GuIformat.StepperPOS(i),'String',num2str(VIDs.crrntSTEPS(i)));
    set(GuIformat.StepperAngle(i),'String',num2str(round(VIDs.crrntSTEPS(i)*(1.8/MicroSteps(i)))));
end

StepperDirection = GetStepperDirection;
StepperEnable = GetStepperEnable;

%Steppers(13:14) = 0;
COMMAND = 'G';
for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(round(Steppers(i)*StepperEnable(i)*StepperDirection(i))));
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('MOVE WAITING')
        while fgets(a) ~= '*'
            pause(.001);
        end
        display('MOVE DONE')
    end
else
    pause(GuIformat.TESTpause);
end



end

function HOMEena(Steppers)
global a GuIformat

Steppers = round(Steppers);

COMMAND = 'E';

for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(Steppers(i)));
    if abs(Steppers(i)) > 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('HOME WAITING')
        while fgets(a) ~= '*'
            pause(.01)
        end
        display('HOME DONE')
    end
else
    pause(GuIformat.TESTpause);
end

HOME_ard(Steppers)

end

function HOME_ard(Steppers)

global a GuIformat

for i = 1:3
    if Steppers(i) < 0
        set(GuIformat.movePB(i,1), 'BackgroundColor',GuIformat.color.o);
    elseif Steppers(i) > 0
        set(GuIformat.movePB(i,2), 'BackgroundColor',GuIformat.color.o);
    end
end

StepperDirection = GetStepperDirection;
StepperEnable = GetStepperEnable;

COMMAND = 'H';
for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(round(Steppers(i)*StepperEnable(i)*StepperDirection(i))));
end
COMMAND = strcat(COMMAND,'*');

if GuIformat.DEBUGMODE == 0
    if sum(abs(Steppers)) > 0
        fwrite(a,COMMAND);
        display('HOME WAITING')
        while fgets(a) ~= '*'
            pause(.001);
        end
        display('HOME DONE')
    end
else
    pause(GuIformat.TESTpause);
end
for i = 1:3
    set(GuIformat.movePB(i,2), 'BackgroundColor',GuIformat.color.c);
    set(GuIformat.movePB(i,1), 'BackgroundColor',GuIformat.color.c);
end

end

function MOVEena(Steppers,Enable)
global GuIformat
ENABLE(Steppers);

MOVE_Ard(Steppers);
if Enable == 0
    ENABLE(zeros(1,GuIformat.StepperCount));
end

end

function DISABLE_ALL()
global a GuIformat

Steppers = zeros(1,GuIformat.StepperCount);

COMMAND = 'E';

for i = 1:GuIformat.StepperCount
    COMMAND = strcat(COMMAND,'+',num2str(Steppers(i)));
    if abs(Steppers(i)) > 0
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.i);
    else
        set(GuIformat.StepperPOS(i),'BackgroundColor',GuIformat.color.d);
    end
end
COMMAND = strcat(COMMAND,'*');
if GuIformat.DEBUGMODE == 0
    fwrite(a,COMMAND);
    display('DISABLE WAITING')
    while fgets(a) ~= '*'
        pause(.01)
    end
    display('DISABLE DONE')
else
    pause(GuIformat.TESTpause);
end

end

%% LOCOMOTION FUNCTIONALITY

function Coords = XYmm2Angles(X,Y)
global CrabModel

desiredEEPosition = [X Y 0]'; % Position is relative to base.
CrabModel.positionTarget2.TargetPosition = desiredEEPosition;

[q, solutionInfo] = CrabModel.gik(CrabModel.iniGuess,CrabModel.positionTarget1,CrabModel.positionTarget2,CrabModel.jointLimBounds);

TestVector = zeros(4,1);
TestVector(1) = 90;
TestVector(2) = 90;
TestVector(3) = 90;
TestVector(4) = 90;
TestVector + q*180/pi;
RightAng = 180 - (540 - sum(TestVector + q*180/pi));

LeftAng = 90 - q(1)*180/pi;

Coords = [LeftAng, RightAng];

end

function Steppers = A2S(Angles)
global GuIformat VIDs CrabModel
Steppers = zeros(1,GuIformat.StepperCount);
MicroSteps = GetMicroSteps;
Steppers = round(Angles.*(MicroSteps*CrabModel.StepsPerDegree));
% for i = 1:GuIformat.StepperCount
%     crrntMicroStep = VIDs.MicroStepTypesNum(get(GuIformat.MicrostepPUM(i),'Value'));
%     Steppers(i) = round(Angles(i)*(StepsPer360d*crrntMicroStep/360));
% end
end

function Angles = S2A(Steppers)
global GuIformat VIDs
Angles = zeros(1,GuIformat.StepperCount);
DegreesPer200Steps = 360;
for i = 1:GuIformat.StepperCount
    crrntMicroStep = VIDs.MicroStepTypesNum(get(GuIformat.MicrostepPUM(i),'Value'));
    Angles(i) = round((Steppers(i)/crrntMicroStep)*(DegreesPer200Steps/200));
end
end

function Go2XY_mm(Location,Enable)
global GuIformat VIDs CrabModel

% if Location(1) < CrabModel.Plate.xmin
%     Location(1) = CrabModel.Plate.xmin;
% end
% if Location(2) < CrabModel.Plate.ymin
%     Location(2) = CrabModel.Plate.ymin + CrabModel.H/2;
% end
%
% if Location(1) > CrabModel.Plate.xmax
%     Location(1) = CrabModel.Plate.xmax;
% end
%
% if Location(2) > CrabModel.Plate.ymax
%     Location(2) = CrabModel.Plate.ymax;
% end
% if Location(3) < CrabModel.Plate.zmin
%     Location(3) = CrabModel.Plate.zmin
% end
% if Location(3) > CrabModel.Plate.zmax
%     Location(3) = CrabModel.Plate.zmax
% end
% if Location(4) < CrabModel.Plate.zmin
%     Location(4) = CrabModel.Plate.zmin
% end
% if Location(4) > CrabModel.Plate.zmax
%     Location(4) = CrabModel.Plate.zmax
% end

Coords = XYmm2Angles(Location(1),Location(2));
Angles = zeros(GuIformat.StepperCount,1);
Angles(1:2) = Coords;

%Go2Z(Location(3))

Go2Angle(Angles);

Xmm = Location(1);
Ymm = Location(2);
VIDs.crrntXYZmm = [Xmm, Ymm, VIDs.crrntXYZmm(3), VIDs.crrntXYZmm(4), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
end

function Go2Z(Height)
global VIDs GuIformat CrabModel

Angles = zeros(1,GuIformat.StepperCount);
Angles(3:4) = (VIDs.crrntXYZmm(3) - Height)/CrabModel.ZmmPerDegree;
Steppers = A2S(Angles);

MOVEena(Steppers,0);
VIDs.crrntXYZmm(3:4) = Height;
end

function Z2zero()
global VIDs GuIformat
Steppers = zeros(1,GuIformat.StepperCount);
Steppers(3:4) = -VIDs.crrntSTEPS(3:4);
MOVEena(Steppers,1);
end

function LR2zero()
global VIDs GuIformat
Steppers = zeros(1,GuIformat.StepperCount);
Steppers(1:2) = -VIDs.crrntSTEPS(1:2);
MOVEena(Steppers,1)
GuIformat.PausePos = 0;
end

function LR2pause()
global GuIformat
GOTOLAYER(1,0);
Z2zero
Angles = zeros(1,GuIformat.StepperCount);
Angles(1:2) = [-86,40];
Go2Angle(Angles);
DISABLE_ALL
GuIformat.PausePos = 1;
end

function Go2Angle(Angles)
global VIDs GuIformat

L = 1;
R = 2;
ArmReal(L) = VIDs.crrntSTEPS(L);
ArmReal(R) = VIDs.crrntSTEPS(R);

Steppers = A2S(Angles);

ArmGoal(L) = Steppers(L);
ArmGoal(R) = Steppers(R);

ArmMove = ArmGoal - ArmReal;
Steppers = zeros(1,GuIformat.StepperCount);
Steppers(1:2) = ArmMove;

MOVEena(Steppers,1);
%UpdateSettings;

end

%% COMPLEX FUNCTIONALITY

function HOMEXYZ()
global GuIformat VIDs
set(GuIformat.HOMEPB,'BackgroundColor',GuIformat.color.o);
set(GuIformat.Connect_HomePB,'BackgroundColor',GuIformat.color.o);
Q = 0;
HXYZ = waitbar(0,'Homing XYZ...');
waitbar(0/10,HXYZ)
%display(horzcat('HERE ', num2str(Q)))
%UpdateMaxSpeed
UpdateSettings;
Z2zero;
waitbar(1/10,HXYZ)
%Go2Z(1)
HOMEena([0,0,900000,900000,0,0,0,0,0,0,0,0,0,0]);
waitbar(2/10,HXYZ)
Go2Z(1)
for j = 3:4
    VIDs.crrntSTEPS(j) = 0;
    VIDs.crrntXYZmm(j) = 0;
    set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));
end
HOMEena([0,0,900000,900000,0,0,0,0,0,0,0,0,0,0]);
waitbar(3/10,HXYZ)
Go2Z(1)
for j = 3:4
    VIDs.crrntSTEPS(j) = 0;
    VIDs.crrntXYZmm(j) = 0;
    set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));
end


if GuIformat.PausePos == 0
    LR2pause;
end


Go2Angle([40,-86,0,0,0,0,0,0,0,0,0,0,0,0]);
HOMEena([0,-90000,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(4/10,HXYZ)
Q = Q + 1;
%display(horzcat('HERE ', num2str(Q)))
j = 2;
TempPos = A2S([0,-86,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

Go2Angle([-86,40,0,0,0,0,0,0,0,0,0,0,0,0]);
HOMEena([-90000,0,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(5/10,HXYZ)

j = 1;
TempPos = A2S([-86,0,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

Go2Angle([40,-86,0,0,0,0,0,0,0,0,0,0,0,0]);
HOME_ard([0,-90000,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(6/10,HXYZ)
Q = Q + 1;
%display(horzcat('HERE ', num2str(Q)))
j = 2;
TempPos = A2S([0,-86,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

Go2Angle([-86,40,0,0,0,0,0,0,0,0,0,0,0,0]);
HOME_ard([-90000,0,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(7/10,HXYZ)
Q = Q + 1;
%display(horzcat('HERE ', num2str(Q)))
j = 1;
TempPos = A2S([-86,0,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

Go2Angle([40,-86,0,0,0,0,0,0,0,0,0,0,0,0]);
HOME_ard([0,-90000,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(8/10,HXYZ)
Q = Q + 1;
%display(horzcat('HERE ', num2str(Q)))
j = 2;
TempPos = A2S([0,-87,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

Go2Angle([-86,40,0,0,0,0,0,0,0,0,0,0,0,0]);
HOME_ard([-9000,0,0,0,0,0,0,0,0,0,0,0,0,0]);
waitbar(9/10,HXYZ)
Q = Q + 1;
%%display(horzcat('HERE ', num2str(Q)))
j = 1;
TempPos = A2S([-87,0,0,0,0,0,0,0,0,0,0,0,0,0]);
VIDs.crrntSTEPS(j) = TempPos(j);
set(GuIformat.StepperPOS(j),'String',num2str(VIDs.crrntSTEPS(j)));

LR2pause;
Q = Q + 1;
%%display(horzcat('HERE ', num2str(Q)))
waitbar(10/10,HXYZ)
DISABLE_ALL;


set(GuIformat.HOMEPB,'BackgroundColor',GuIformat.color.c);
set(GuIformat.Connect_HomePB,'BackgroundColor',GuIformat.color.c);
GuIformat.wellcount = 0;
SaveLog(GuIformat.LogPath,'HOMED')
close(HXYZ);
end

function ConditionalHome()
global GuIformat
if GuIformat.wellcount > 96
    HOMEXYZ;
end
end

function SmartHome()
global GuIformat
GuIformat.PausePos
if GuIformat.PausePos == 0
    HOMEXYZ;
end
end

function GOTOLAYER(LAYER,Enable)
global GuIformat VIDs
Steppers = zeros(1,GuIformat.StepperCount);
Steppers(3:4) = [GuIformat.ZValues(LAYER),GuIformat.ZValues(LAYER)] - VIDs.crrntSTEPS(3:4);
MOVEena([Steppers],Enable);
end

function GOTOWELL(TYPE, WELL, LAYER)
global GuIformat VIDs
UpdateSettings
if TYPE == 96
    Location(2) = GuIformat.w96POSmm.x(WELL(1));
    Location(1) = GuIformat.w96POSmm.y(WELL(2));
elseif TYPE == 384
    Location(2) = GuIformat.w384POSmm.x(WELL(1));
    Location(1) = GuIformat.w384POSmm.y(WELL(2));
end

if GuIformat.PausePos == 1
    GOTOLAYER(1,0);
    LR2zero
end

GOTOLAYER(2,0);

Go2XY_mm(Location,0);
GOTOLAYER(LAYER,0);

if TYPE == 96
    set(GuIformat.w96(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.o);
elseif TYPE == 384
    set(GuIformat.w384(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.o);
end

end

function SyringeMove(VOLUMES,SUCTION,STYLE,REPS)
global a VIDs GuIformat
Steps = zeros(1,GuIformat.StepperCount);

StepsPerRev = GetStepsPerRev;
MicroSteps = GetMicroSteps;
uLPerRev = GetuLPerRev;

StepsPeruL = StepsPerRev./uLPerRev;
MicroStepsPeruL = StepsPeruL.*MicroSteps;

Steps(5) = -SUCTION*MicroStepsPeruL(5);
for i = 1:GuIformat.ReagentCount
    Steps(5+i) = VOLUMES(i)*MicroStepsPeruL(i+5);
end
Steppers = round(Steps);

for s = 5:GuIformat.PumpCount
    if Steppers(s) > 0
        set(GuIformat.SyrADD(s-4),'BackgroundColor',GuIformat.color.o)
    elseif Steppers(s) < 0
        set(GuIformat.SyrSUB(s-4),'BackgroundColor',GuIformat.color.o)
    end
end

for i = 1:REPS
    if STYLE == 2
        Message = strcat({'BEGIN CHANGING VOLUME '},num2str(SUCTION),{' '},num2str(VOLUMES));
        SaveLog(GuIformat.LogPath,Message);
        MOVEena(Steppers,1);
        %UpdateSettings;
    elseif STYLE == 1
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(5) = Steppers(5);
        
        Message = strcat({'BEGIN REMOVING VOLUME '},num2str(SUCTION));
        SaveLog(GuIformat.LogPath,Message);
        MOVEena(tempSteps,1);
        %         if sum(abs(tempSteps)) ~= 0
        %             UpdateSettings;
        %         end
        tempSteps = zeros(1,GuIformat.StepperCount);
        for i = 6:GuIformat.StepperCount
            tempSteps(i) = Steppers(i);
        end
        Message = strcat({'BEGIN ADDING VOLUME '},num2str(VOLUMES));
        SaveLog(GuIformat.LogPath,Message);
        MOVEena(tempSteps,1);
        %         if sum(abs(tempSteps)) ~= 0
        %             UpdateSettings;
        %         end
    elseif STYLE == 3
        %% RISE FAST
        UpdateMaxSpeed
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(3) = round(50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(50*VIDs.MicroStepSETTINGS(4));
        MOVEena(tempSteps,1);
        
        %% SUCK FAST DROPPING
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(3) = round(-50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(-50*VIDs.MicroStepSETTINGS(4));
        tempSteps(5) = round(Steppers(5));
        Message = strcat({'BEGIN REMOVING VOLUME '},num2str(SUCTION));
        SaveLog(GuIformat.LogPath,Message);
        MOVEena(round(tempSteps*2/3),1);
        
        %% SUCK SLOW DROPPING
        UpdateSettings
        MOVEena(round(tempSteps/3),1);
        
        %% PUMP SLOW RISING
        tempSteps = zeros(1,GuIformat.StepperCount);
        for i = 6:GuIformat.StepperCount
            tempSteps(i) = Steppers(i);
        end
        tempSteps(3) = round(50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(50*VIDs.MicroStepSETTINGS(4));
        Message = strcat({'BEGIN ADDING VOLUME '},num2str(VOLUMES));
        SaveLog(GuIformat.LogPath,Message);
        MOVEena(round(tempSteps/3),1);
        
        %% PUMP FAST RISING
        UpdateMaxSpeed
        MOVEena(round(tempSteps*2/3),1);
        
        %% SHAKE
        for i = 1:2
            tempSteps = zeros(1,GuIformat.StepperCount);
            tempSteps(3) = round(-20*VIDs.MicroStepSETTINGS(3));
            tempSteps(4) = round(-20*VIDs.MicroStepSETTINGS(4));
            MOVEena(tempSteps,1);
            tempSteps(3) = round(20*VIDs.MicroStepSETTINGS(3));
            tempSteps(4) = round(20*VIDs.MicroStepSETTINGS(4));
            MOVEena(tempSteps,1);
        end
        UpdateSettings
    end
end

for s = 5:GuIformat.PumpCount
    set(GuIformat.SyrADD(s-4),'BackgroundColor',GuIformat.color.c)
    set(GuIformat.SyrSUB(s-4),'BackgroundColor',GuIformat.color.c)
end

end

function SyringeFast(VOLUMES,SUCTION,STYLE,REPS)
global a VIDs GuIformat
Steps = zeros(1,GuIformat.StepperCount);
i = 1;
SyrType(i) = get(GuIformat.SyrType(i),'Value');
fullstepsPERul(i) = VIDs.SyrMat(SyrType(i));
Steps(4+i) = (-SUCTION/fullstepsPERul(i))*VIDs.MicroStepSETTINGS(i+4);
for i = 1:GuIformat.ReagentCount
    SyrType = get(GuIformat.SyrType(i),'Value');
    fullstepsPERul = VIDs.SyrMat(SyrType);
    Steps(5+i) = (VOLUMES(i)/fullstepsPERul)*VIDs.MicroStepSETTINGS(i+4);
end
Steppers = round(Steps);

for s = 5:GuIformat.PumpCount
    if Steppers(s) > 0
        set(GuIformat.SyrADD(s-4),'BackgroundColor',GuIformat.color.o)
    elseif Steppers(s) < 0
        set(GuIformat.SyrSUB(s-4),'BackgroundColor',GuIformat.color.o)
    end
end

for i = 1:REPS
    if STYLE == 2
        UpdateMaxSpeed
        MOVEena(Steppers,1);
        %UpdateSettings;
    elseif STYLE == 1
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(5) = Steppers(5);
        UpdateMaxSpeed
        MOVEena(tempSteps,1);
        %         if sum(abs(tempSteps)) ~= 0
        %             UpdateSettings;
        %         end
        tempSteps = zeros(1,GuIformat.StepperCount);
        for i = 6:GuIformat.StepperCount
            tempSteps(i) = Steppers(i);
        end
        UpdateMaxSpeed
        MOVEena(tempSteps,1);
        %         if sum(abs(tempSteps)) ~= 0
        %             UpdateSettings;
        %         end
    elseif STYLE == 3
        %% RISE FAST
        UpdateMaxSpeed
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(3) = round(50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(50*VIDs.MicroStepSETTINGS(4));
        MOVEena(tempSteps,1);
        
        %% SUCK FAST DROPPING
        tempSteps = zeros(1,GuIformat.StepperCount);
        tempSteps(3) = round(-50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(-50*VIDs.MicroStepSETTINGS(4));
        tempSteps(5) = round(Steppers(5));
        
        MOVEena(round(tempSteps*2/3),1);
        
        %% SUCK SLOW DROPPING
        UpdateSettings
        MOVEena(round(tempSteps/3),1);
        
        %% PUMP SLOW RISING
        tempSteps = zeros(1,GuIformat.StepperCount);
        for i = 6:GuIformat.StepperCount
            tempSteps(i) = Steppers(i);
        end
        tempSteps(3) = round(50*VIDs.MicroStepSETTINGS(3));
        tempSteps(4) = round(50*VIDs.MicroStepSETTINGS(4));
        MOVEena(round(tempSteps/3),1);
        
        %% PUMP FAST RISING
        UpdateMaxSpeed
        MOVEena(round(tempSteps*2/3),1);
        
        %% SHAKE
        for i = 1:2
            tempSteps = zeros(1,GuIformat.StepperCount);
            tempSteps(3) = round(-20*VIDs.MicroStepSETTINGS(3));
            tempSteps(4) = round(-20*VIDs.MicroStepSETTINGS(4));
            MOVEena(tempSteps,1);
            tempSteps(3) = round(20*VIDs.MicroStepSETTINGS(3));
            tempSteps(4) = round(20*VIDs.MicroStepSETTINGS(4));
            MOVEena(tempSteps,1);
        end
        UpdateSettings
    end
end

for s = 5:GuIformat.PumpCount
    set(GuIformat.SyrADD(s-4),'BackgroundColor',GuIformat.color.c)
    set(GuIformat.SyrSUB(s-4),'BackgroundColor',GuIformat.color.c)
end

end

function LoadPumps(VOLUMES)
global GuIformat
PUMPS = zeros(1,GuIformat.ReagentCount)

for q = 1:GuIformat.ReagentCount
    if GuIformat.LOADSTATES(q) == 0 %Not loaded
        if abs(VOLUMES(q)) > 0 %Needed
            PUMPS(q) = str2num(get(GuIformat.CalibVolEDT(q + 5),'String')); %Load
            GuIformat.LOADSTATES(q) = 1; %Mark loaded
            GuIformat.PUMPSTATES(q) = 1; %Mark loaded
        elseif abs(VOLUMES(q)) == 0 %Not needed
            PUMPS(q) = 0; %Do nothing
            GuIformat.LOADSTATES(q) = 0; %Mark unloaded
            GuIformat.PUMPSTATES(q) = 0; %Mark unloaded
        end
    elseif GuIformat.LOADSTATES(q) == 1 %Loaded
        if abs(VOLUMES(q)) == 0 % Not needed
            PUMPS(q) = -str2num(get(GuIformat.CalibVolEDT(q + 5),'String'))*1.5; %Unload
            GuIformat.LOADSTATES(q) = 0; %Mark unloaded
            GuIformat.PUMPSTATES(q) = 0; %Mark unloaded
        elseif abs(VOLUMES(q)) > 0 % Needed
            PUMPS(q) = 0; %Do nothing
            GuIformat.LOADSTATES(q) = 1; %Mark loaded
            GuIformat.PUMPSTATES(q) = 1; %Mark loaded
        end
    end
end

if sum(abs(PUMPS)) > 0
    UpdateMaxSpeed
    SyringeMove(0.75*PUMPS,0,1,1)
    SyringeMove(0.125*PUMPS,0.5*str2num(get(GuIformat.CalibVolEDT(5),'String')),2,1)
    SyringeMove(0.125*PUMPS,0.5*str2num(get(GuIformat.CalibVolEDT(5),'String')),2,1)
    SyringeMove(zeros(1,GuIformat.ReagentCount),0.3*str2num(get(GuIformat.CalibVolEDT(5),'String')),2,1)
    UpdateSettings
end
end

function PrimePumps(VOLUMES)
global GuIformat
PUMPS = zeros(1,GuIformat.ReagentCount)

for q = 1:GuIformat.ReagentCount
    if GuIformat.PUMPSTATES(q) == 0 %Not loaded
        if abs(VOLUMES(q)) > 0 %Needed
            PUMPS(q) = 2; %Load
            GuIformat.PUMPSTATES(q) = 1; %Mark loaded
        elseif abs(VOLUMES(q)) == 0 %Not needed
            PUMPS(q) = 0; %Do nothing
            GuIformat.PUMPSTATES(q) = 0; %Mark unloaded
        end
    elseif GuIformat.PUMPSTATES(q) == 1 %Loaded
        if abs(VOLUMES(q)) == 0 % Not needed
            PUMPS(q) = -2; %Unload
            GuIformat.PUMPSTATES(q) = 0; %Mark unloaded
        elseif abs(VOLUMES(q)) > 0 % Needed
            PUMPS(q) = 0; %Do nothing
            GuIformat.PUMPSTATES(q) = 1; %Mark loaded
        end
    end
end

if sum(abs(PUMPS)) > 0
    UpdateMaxSpeed
    SyringeMove(PUMPS,20,2,1)
    UpdateSettings
end
end

function WASHTIPS(TYPE,WELL,VOLUMES,REPS)
global GuIformat
volumes = (VOLUMES/sum(abs(VOLUMES)))*100;
suction = 200;
if TYPE == 96
    set(GuIformat.w96(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.o)
elseif TYPE == 384
    set(GuIformat.w384(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.o)
end

GOTOWELL(TYPE, WELL, 3);

for i = 1:REPS
    SyringeFast(volumes,suction,1,1);
end

GOTOLAYER(1,0)

GuIformat.PREVIOUSCOMPOSITION = VOLUMES;

if TYPE == 96
    set(GuIformat.w96(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.c)
elseif TYPE == 384
    set(GuIformat.w384(WELL(1),WELL(2)),'BackgroundColor',GuIformat.color.c)
end
end

function CHANGEWELL(TYPE,WELL,VOLUMES,SUCTION,STYLE,REPS)
global GuIformat;
X = WELL(1);
Y = WELL(2);

%PrimePumps(VOLUMES)

% if get(GuIformat.SmartWashEnableCB,'Value') == 1 && GuIformat.STOP == 0
%     platetypes = [96,384];
%     type = platetypes(get(GuIformat.SmartWashWellPlateType,'Value'));
%     wellx = get(GuIformat.SmartWashWellX,'Value');
%     welly = get(GuIformat.SmartWashWellY,'Value');
%     shouldiwash = 0;
%     if get(GuIformat.SmartWashTypePUM,'Value') == 1 && sum(abs(VOLUMES)) > 0
%         shouldiwash = 1;
%     elseif get(GuIformat.SmartWashTypePUM,'Value') == 2 && isequal(VOLUMES,GuIformat.PREVIOUSCOMPOSITION) ~= 1 && sum(abs(VOLUMES)) > 0
%         shouldiwash = 1;
%     end
%     if shouldiwash == 1
%         WASHTIPS(type,[wellx,welly],VOLUMES,4)
%     end
% end



if sum(abs(VOLUMES) + abs(SUCTION)) > 0
    if TYPE == 96
        set(GuIformat.w96(X,Y),'BackgroundColor',GuIformat.color.i)
    elseif TYPE == 384
        set(GuIformat.w384(X,Y),'BackgroundColor',GuIformat.color.i)
    end
    PAUSEchk
    GuIformat.wellcount = GuIformat.wellcount + 1;
    GOTOWELL(TYPE, WELL, 2)
    if TYPE == 96
        set(GuIformat.w96(X,Y),'BackgroundColor',GuIformat.color.o)
    elseif TYPE == 384
        set(GuIformat.w384(X,Y),'BackgroundColor',GuIformat.color.o)
    end
    Message = strcat({'BEGIN REPLACING COLUMN '},num2str(X),{' ROW '},num2str(Y));
    SaveLog(GuIformat.LogPath,Message);
    GOTOWELL(TYPE, WELL, 3)
    PAUSEchk
    SyringeMove(VOLUMES,SUCTION,STYLE,REPS)
    Message = strcat({'FINISHED REPLACING COLUMN '},num2str(X),{' ROW '},num2str(Y));
    SaveLog(GuIformat.LogPath,Message);
    if TYPE == 96
        set(GuIformat.w96(X,Y),'BackgroundColor',GuIformat.color.c)
    elseif TYPE == 384
        set(GuIformat.w384(X,Y),'BackgroundColor',GuIformat.color.c)
    end
    
end
end

%% EXPERIMENT RUN FUNCTIONALITY

function PlateLayout(TYPE,PLATEimg,SUCTION,STYLE,REPS)
global GuIformat
if TYPE == 96
    XX = 1:12;
    YY = 8:-1:1;
elseif TYPE == 384
    XX = 1:24;
    YY = 16:-1:1;
end

GuIformat.PREVIOUSCOMPOSITION = zeros(1,GuIformat.ReagentCount);

LR2pause;

[Au, idx ,idx2] = uniquecell(PLATEimg);

for nq = 1:length(Au)
    for x = XX
        if mod(x,2) == 0
            YYY = flip(YY);
        else
            YYY = YY;
        end
        for y = YYY
            ConditionalHome
            PAUSEchk
            if PLATEimg{x,y} == Au{nq}
                if GuIformat.STOP == 0 && sum(abs(PLATEimg{x,y})) > 0
                    CHANGEWELL(TYPE,[x,y],PLATEimg{x,y},SUCTION,STYLE,REPS);
                end
            end
        end
    end
end
if GuIformat.STOP == 0
    LR2pause;
end

for x = XX
    for y = YY
        if TYPE == 96
            set(GuIformat.w96(x,y),'BackgroundColor',GuIformat.color.c);
        elseif TYPE == 384
            set(GuIformat.w384(x,y),'BackgroundColor',GuIformat.color.c);
        end
        
    end
end

end

function RunPlateSet(PLATESET)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLATESET structure is set up as:
% PLATESET.TYPE = 96 or 384
% PLATESET.SEQ is a cell array containing plate images ie an array of 4 value vectors containing the volumes to be changed by the pumps
% PLATESET.DELAYS is a sequence of times, in seconds, between each plate image implementation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global GuIformat Scripting

Message = strcat('BEGIN EXPERIMENT');
SaveLog(GuIformat.LogPath,Message);

HOMEXYZ
GuIformat.PUMPSTATES = ones(1,GuIformat.PumpCount)
for STEP = 1:length(PLATESET.DELAYS)
    CRRNTstart = clock;
    if GuIformat.STOP == 0
        h = waitbar(0,horzcat('Processing Step ',num2str(STEP)));
    end
    for REP = 1:1%PLATESET.REPETITIONS(STEP)
        PAUSEchk
        if GuIformat.STOP == 0
            Message = strcat({'BEGIN STEP '},num2str(STEP));
            SaveLog(GuIformat.LogPath,Message);
            set(Scripting.StepGROUP,'SelectedTab',Scripting.ScriptingTAB(STEP))
            PlateLayout(PLATESET.TYPE,PLATESET.SEQ{STEP},PLATESET.SUCTION(STEP),PLATESET.STYLES(STEP),PLATESET.REPETITIONS(STEP));
            Message = strcat({'FINISHED STEP '},num2str(STEP));
            SaveLog(GuIformat.LogPath,Message);
        end
    end
    if ishandle(h)
        close(h);
    end
    if etime(clock, CRRNTstart + PLATESET.DELAYS(STEP)) > 5 && GuIformat.STOP == 0
        HOMEXYZ
    end
    if GuIformat.STOP == 0
        h = waitbar(0,horzcat('Incubation Step ',num2str(STEP)));
    end
    Message = strcat({'BEGIN INCUBATION STEP '},num2str(STEP));
    SaveLog(GuIformat.LogPath,Message);
    while etime(clock, CRRNTstart) < PLATESET.DELAYS(STEP) && GuIformat.STOP == 0
        RATIO = etime(clock, CRRNTstart)/PLATESET.DELAYS(STEP);
        EXCESS = 1 - RATIO;
        for qz = 1:100
            waitbar(RATIO + (EXCESS/100)*qz, h);
            pause(.01)
        end
    end
    Message = strcat({'END INCUBATION STEP '},num2str(STEP));
    SaveLog(GuIformat.LogPath,Message);
    if ishandle(h)
        close(h);
    end
    
end
HOMEXYZ;
Message = strcat({'FINISHED EXPERIMENT'});
SaveLog(GuIformat.LogPath,Message);
end

function PLATESET = AggregatePlateSet()
global Scripting GuIformat;
StepCount = str2num(get(Scripting.StepCountEDT,'String'));
SIZES = get(Scripting.PlateTypePUM,'Userdata');
VALUE = get(Scripting.PlateTypePUM,'Value');
Xsize = SIZES(VALUE,2);
Ysize = SIZES(VALUE,1);



PLATESET.TYPE = Xsize*Ysize;
PLATESET.DELAYS = zeros(1,StepCount);
PLATESET.STYLES = zeros(1,StepCount);
PLATESET.VOLUMES = zeros(1,StepCount);
PLATESET.REPETITIONS = zeros(1,StepCount);
PLATESET.SEQ = cell(1,StepCount);
for STEP = 1:StepCount
    PLATESET.SEQ{STEP} = cell(Xsize,Ysize);
    PLATESET.DELAYS(STEP) = str2num(get(Scripting.StepDelayEDT(STEP),'String'))*60;
    PLATESET.STYLES(STEP) = get(Scripting.PipetteTypePUM(STEP),'Value');
    PLATESET.VOLUMES(STEP) = str2num(get(Scripting.WellVolumeEDT(STEP),'String'));
    PLATESET.SUCTION(STEP) = str2num(get(Scripting.SuctionVolumeEDT(STEP),'String'));
    PLATESET.REPETITIONS(STEP) = str2num(get(Scripting.StepRepEDT(STEP),'String'));
    for x = 1:Xsize
        for y = 1:Ysize
            tmp_WELL = get(Scripting.wellsPB(x,y,STEP),'Userdata');
            tmp_WELL = tmp_WELL(3:GuIformat.ReagentCount+2);
            if sum(abs(tmp_WELL)) > 0
                tmp_WELL = (tmp_WELL/sum(abs(tmp_WELL)))*PLATESET.VOLUMES(STEP);
            end
            tmp_Vols = zeros(1,GuIformat.ReagentCount);
            if sum(abs(tmp_WELL)) > 0
                tmp_Vols = tmp_WELL;%Volume to add
            end
            PLATESET.SEQ{STEP}{x,y} = tmp_Vols;
        end
    end
end

end

function VOLUMES = AggregateVolumes()
global Scripting GuIformat;
StepCount = str2num(get(Scripting.StepCountEDT,'String'));
SIZES = get(Scripting.PlateTypePUM,'Userdata');
VALUE = get(Scripting.PlateTypePUM,'Value');
Xsize = SIZES(VALUE,2);
Ysize = SIZES(VALUE,1);

PLATESET.VOLUMES = zeros(1,StepCount);
PLATESET.REPETITIONS = zeros(1,StepCount);
PLATESET.SEQ = cell(1,StepCount);
VOLUMES = zeros(1,6);
for STEP = 1:StepCount
    PLATESET.SEQ{STEP} = cell(Xsize,Ysize);
    PLATESET.VOLUMES(STEP) = str2num(get(Scripting.WellVolumeEDT(STEP),'String'));
    PLATESET.REPETITIONS(STEP) = str2num(get(Scripting.StepRepEDT(STEP),'String'));
    for x = 1:Xsize
        for y = 1:Ysize
            tmp_WELL = get(Scripting.wellsPB(x,y,STEP),'Userdata');
            tmp_WELL = tmp_WELL(3:GuIformat.ReagentCount+2);
            if sum(abs(tmp_WELL)) > 0
                tmp_WELL = (tmp_WELL/sum(abs(tmp_WELL)))*PLATESET.VOLUMES(STEP);
            end
            tmp_Vols = zeros(1,GuIformat.PumpCount);
            if sum(abs(tmp_WELL)) > 0
                tmp_Vols(2:GuIformat.PumpCount) = tmp_WELL;%Volume to add
            end
            VOLUMES = VOLUMES + tmp_Vols + tmp_Vols*PLATESET.REPETITIONS(STEP);
        end
    end
end
end

%% PAUSE FUNCTION

function PAUSEchk()

global vc VIDs GuIformat

while GuIformat.PAUSE == 1
    pause(.05);
end

end

%% UPDATE SETTINGS

function UpdateSettings()
global VIDs BoxInfo GuIformat;

%DISABLE_ALL

for i = 1:GuIformat.StepperCount
    VIDs.StepperEnable(i) = get(GuIformat.StepperEnableCB(i),'Value');
    BoxInfo.StepperEnable(i) = VIDs.StepperEnable(i);
    
    VIDs.StepsPerRev(i) = str2num(get(GuIformat.StepsPerRevEDT(i),'String'));
    BoxInfo.StepsPerRev(i) = VIDs.StepsPerRev(i);
    
    VIDs.MicroStepValues(i) = get(GuIformat.MicrostepPUM(i),'Value');
    BoxInfo.MicroStepValues(i) = VIDs.MicroStepValues(i);
    VIDs.StepperSpeeds(i) = str2num(get(GuIformat.StepperSpeedsEDT(i),'String'));
    BoxInfo.StepperSpeeds(i) = VIDs.StepperSpeeds(i);
    VIDs.StepperMaxSpeeds(i) = str2num(get(GuIformat.StepperMaxSpeedsEDT(i),'String'));
    BoxInfo.StepperMaxSpeeds(i) = VIDs.StepperMaxSpeeds(i);
    
    VIDs.CalibVol(i) = str2num(get(GuIformat.CalibVolEDT(i),'String'));
    BoxInfo.CalibVol(i) = VIDs.CalibVol(i);
    
    BoxInfo.StepDIRValues(i) = get(GuIformat.DirectionPUM(i),'Value');
    
    VIDs.MicroStepSETTINGS(i) = VIDs.MicroStepTypesNum(get(GuIformat.MicrostepPUM(i),'Value'));
end

MICROSTEPS(VIDs.MicroStepValues);
SPEED(VIDs.StepperSpeeds);
ACCELLERATION(VIDs.StepperSpeeds);
VIDs.StepsPERRev = VIDs.MicroStepSETTINGS*200;
BoxInfo.PORT = get(GuIformat.PORTedt,'String');
BoxInfo.ZValues = GuIformat.ZValues;
BoxInfo.w96POSmm.x = GuIformat.w96POSmm.x;
BoxInfo.w96POSmm.y = GuIformat.w96POSmm.y;
BoxInfo.w384POSmm.x = GuIformat.w384POSmm.x;
BoxInfo.w384POSmm.y = GuIformat.w384POSmm.y;
save(fullfile(GuIformat.Configpathname,GuIformat.Configfilename),'BoxInfo')
end

function UpdateMaxSpeed()
global VIDs BoxInfo GuIformat;

MaxSpeeds = zeros(1,GuIformat.StepperCount);

for i = 1:GuIformat.StepperCount
    if i > 4
        MaxSpeeds(i) = str2num(get(GuIformat.StepperMaxSpeedsEDT(i),'String'));
    else
        MaxSpeeds(i) = str2num(get(GuIformat.StepperSpeedsEDT(i),'String'));
    end
    
end

SPEED(MaxSpeeds);

end

function LoadConfig(pathname,filename)
global GuIformat BoxInfo VIDs
    %% LOAD SETTINGS
    load(fullfile(pathname,filename));
    
    %% 96 WELL PLATE SETTINGS
    GuIformat.w96POSmm.x = BoxInfo.w96POSmm.x;
    GuIformat.w96POSmm.y = BoxInfo.w96POSmm.y;
    
    %% 384 WELL PLATE SETTINGS
    GuIformat.w384POSmm.x = BoxInfo.w384POSmm.x;
    GuIformat.w384POSmm.y = BoxInfo.w384POSmm.y;
    
    %% HEIGHT SETTINGS
    GuIformat.ZValues = BoxInfo.ZValues;
    
    %% STEPPER ENABLE SETTINGS
    VIDs.StepperEnable = BoxInfo.StepperEnable;
    
    %% MICROSTEP SETTINGS
    VIDs.MicroStepValues = BoxInfo.MicroStepValues;
    
    %% COMPENSATION SETTINGS
    GuIformat.StepDIRValues = BoxInfo.StepDIRValues;
    
    %% SPEED SETTINGS
    VIDs.StepperSpeeds = BoxInfo.StepperSpeeds;
    
    %% MAX SPEED SETTINGS
    VIDs.StepperMaxSpeeds = BoxInfo.StepperMaxSpeeds;
    
    %% LOAD VOLUME
    VIDs.CalibVol = BoxInfo.CalibVol;
    
end

%% FORMATTING FUNCTIONS

function RGBs = CMYKZtoRGB(Fraction)
RGBs = zeros(1,3);
RGBs(1) = abs((1 - Fraction(2)) * (1 - Fraction(5)));
RGBs(2) = abs((1 - Fraction(3)) * (1 - Fraction(5)));
RGBs(3) = abs((1 - Fraction(4)) * (1 - Fraction(5)));

end

function String = mLine(Array)
String = '<html>';
for i = 1: length(Array)
    crrntArray = Array{i};
    String = horzcat(String,crrntArray,'<br>');
end

end

%% LOG ACTIONS

function SaveLog(FilePath,Message)

f = date;
[~,~] = mkdir(FilePath,'logs');
message = strcat(datestr(now),{': '},Message);
dlmwrite(fullfile(FilePath,'logs',f),message,'delimiter','','-append');

end