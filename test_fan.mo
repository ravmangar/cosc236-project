model test_fan "Free response of room model"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Air "Medium model";

  parameter Integer nAC = 1;
  parameter Integer nDeHum = 1;
  
  
  // booleans to use devices
  parameter Boolean useDehum1 = true;
  parameter Boolean useDehum2 = true;
  parameter Boolean useDehum3 = true; 
  parameter Boolean useDehum4 = true;
  parameter Boolean useDehum5 = true;
  parameter Boolean useDehum6 = true;
  parameter Boolean useDehum7 = true;
  parameter Boolean useDehum8 = true; 
  
  
  parameter Boolean useAC1 = true;
  parameter Boolean useAC2 = true;
  parameter Boolean useAC3 = false;
  parameter Boolean useAC4 = false;
  parameter Boolean useAC5 = false;
  parameter Boolean useAC6 = false;
  parameter Boolean useAC7 = false;
  parameter Boolean useAC8 = false;

  
  
 
  //dehumidifier on time
  parameter Modelica.Units.SI.Time dehumOnTime1  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime1 = 1000 "Dehum off [s]";

  parameter Modelica.Units.SI.Time dehumOnTime2  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime2 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime3  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime3 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime4  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime4 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime5  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime5 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime6  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime6 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime7  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime7 = 1000 "Dehum off [s]";
  
  parameter Modelica.Units.SI.Time dehumOnTime8  = 300  "Dehum on [s]";
  parameter Modelica.Units.SI.Time dehumOffTime8 = 1000 "Dehum off [s]";

  //ac on time
  parameter Modelica.Units.SI.Time AConTime1  = 300;
  parameter Modelica.Units.SI.Time ACoffTime1 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime2  = 300;
  parameter Modelica.Units.SI.Time ACoffTime2 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime3  = 300;
  parameter Modelica.Units.SI.Time ACoffTime3 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime4  = 300;
  parameter Modelica.Units.SI.Time ACoffTime4 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime5  = 300;
  parameter Modelica.Units.SI.Time ACoffTime5 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime6  = 300;
  parameter Modelica.Units.SI.Time ACoffTime6 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime7  = 300;
  parameter Modelica.Units.SI.Time ACoffTime7 = 1000;
  
  parameter Modelica.Units.SI.Time AConTime8  = 300;
  parameter Modelica.Units.SI.Time ACoffTime8 = 1000;



  parameter Buildings.HeatTransfer.Data.Solids.Plywood matWoo(
    x=0.01,
    k=0.11,
    d=544,
    nStaRef=1) "Wood for exterior construction";
  parameter Buildings.HeatTransfer.Data.Solids.Concrete matCon(
    x=0.1,
    k=1.311,
    c=836,
    nStaRef=5) "Concrete";
  parameter Buildings.HeatTransfer.Data.Solids.Generic matIns(
    x=0.087,
    k=0.049,
    c=836.8,
    d=265,
    nStaRef=5) "Steelframe construction with insulation";
  parameter Buildings.HeatTransfer.Data.Solids.GypsumBoard matGyp(
    x=0.0127,
    k=0.16,
    c=830,
    d=784,
    nStaRef=2) "Gypsum board";
  parameter Buildings.HeatTransfer.Data.Solids.GypsumBoard matGyp2(
    x=0.025,
    k=0.16,
    c=830,
    d=784,
    nStaRef=2) "Gypsum board";
  parameter Buildings.HeatTransfer.Data.Solids.Plywood matFur(x=0.15, nStaRef=5)
    "Material for furniture";
  parameter Buildings.HeatTransfer.Data.Solids.Plywood matCarTra(
    x=0.215/0.11,
    k=0.11,
    d=544,
    nStaRef=1) "Wood for floor";
  parameter Buildings.HeatTransfer.Data.Resistances.Carpet matCar "Carpet";
  parameter Buildings.HeatTransfer.Data.GlazingSystems.DoubleClearAir13Clear glaSys(
    UFra=2,
    shade=Buildings.HeatTransfer.Data.Shades.Gray(),
    haveInteriorShade=false,
    haveExteriorShade=false) "Data record for the glazing system";
  parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conExtWal(
    final nLay=3,
    material={matWoo,matIns,matGyp}) "Exterior construction";
  parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conIntWal(
    final nLay=1,
    material={matGyp2}) "Interior wall construction";
  parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conFlo(
    final nLay=1,
    material={matCon}) "Floor construction (opa_a is carpet)";
  parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conFur(
    final nLay=1,
    material={matFur}) "Construction for internal mass of furniture";

  parameter String weaFil = Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
   "Weather data file";
  parameter Modelica.Units.SI.Volume VRoo= 10 * 5 * 2.74 "Room volum";
  parameter Modelica.Units.SI.Height hRoo=2.74 "Room height";
  parameter Modelica.Units.SI.Length hWin=1.5 "Height of windows";
  parameter Real winWalRat(min=0.01,max=0.99) = 0.33
    "Window to wall ratio for exterior walls";
  parameter Modelica.Units.SI.Area AFlo=VRoo/hRoo "Floor area";

  Buildings.ThermalZones.Detailed.MixedAir roo(
    redeclare package Medium = Medium,
    AFlo=AFlo,
    hRoo=hRoo,
    nConExt=0,
    nPorts=2,
    nConExtWin=4,
    datConExtWin(
      layers={conExtWal,conExtWal,conExtWal,conExtWal},
      A={
        49.91*hRoo,
        49.91*hRoo,
        33.27*hRoo,
        33.27*hRoo},
      glaSys={glaSys,glaSys,glaSys,glaSys},
      wWin={
        winWalRat/hWin*49.91*hRoo,
        winWalRat/hWin*49.91*hRoo,
        winWalRat/hWin*33.27*hRoo,
        winWalRat/hWin*33.27*hRoo},
      each hWin=hWin,
      fFra={0.1, 0.1, 0.1, 0.1},
      til={Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall},
      azi={Buildings.Types.Azimuth.N, Buildings.Types.Azimuth.S, Buildings.Types.Azimuth.W, Buildings.Types.Azimuth.E}),
    nConPar=3,
    datConPar(
      layers={conFlo, conFur, conIntWal},
      A={AFlo, AFlo*2, (6.47*2 + 40.76 + 24.13)*2*hRoo},
      til={Buildings.Types.Tilt.Floor, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall}),
    nConBou=0,
    nSurBou=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial) "Floor";

  Modelica.Blocks.Sources.Constant qConGai_flow(k=0) "Convective heat gain";
  Modelica.Blocks.Sources.Constant qRadGai_flow(k=0) "Radiative heat gain";
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1 "Multiplex";
  Modelica.Blocks.Sources.Constant qLatGai_flow(k=0) "Latent heat gain";
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam=weaFil,
      computeWetBulbTemperature=false);
  Modelica.Blocks.Sources.Constant uSha(k=0)
    "Control signal for the shading device";
  Modelica.Blocks.Routing.Replicator replicator(nout=4);



  // ---------Dehumidifier Stuff ----------


  Buildings.Fluid.Humidifiers.Humidifier_u dehum1(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum1 then -0.00001 else 0.0);


  Buildings.Fluid.Humidifiers.Humidifier_u dehum2(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum2 then -0.00001 else 0.0);

  Buildings.Fluid.Humidifiers.Humidifier_u dehum3(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum3 then -0.0009 else 0.0);
  
  Buildings.Fluid.Humidifiers.Humidifier_u dehum4(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum4 then -0.0009 else 0.0);
  
  Buildings.Fluid.Humidifiers.Humidifier_u dehum5(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum5 then -0.0010 else 0.0);
  
  Buildings.Fluid.Humidifiers.Humidifier_u dehum6(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum6 then -0.0010 else 0.0);

  Buildings.Fluid.Humidifiers.Humidifier_u dehum7(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum7 then -0.0005 else 0.0);
  
  Buildings.Fluid.Humidifiers.Humidifier_u dehum8(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50,
  mWat_flow_nominal=if useDehum8 then -0.0005 else 0.0);
  
  // Dehumidifier 1 control
  Modelica.Blocks.Sources.Step dehum1On(height=1, startTime=dehumOnTime1);
  Modelica.Blocks.Sources.Step dehum1Off(height=-1, startTime=dehumOffTime1);
  Modelica.Blocks.Math.Add dehum1Ctrl;

  // Dehumidifier 2 control
  Modelica.Blocks.Sources.Step dehum2On(height=1, startTime=dehumOnTime2);
  Modelica.Blocks.Sources.Step dehum2Off(height=-1, startTime=dehumOffTime2);
  Modelica.Blocks.Math.Add dehum2Ctrl;

  // Dehumidifier 3 control
  Modelica.Blocks.Sources.Step dehum3On(height=1, startTime=dehumOnTime3);
  Modelica.Blocks.Sources.Step dehum3Off(height=-1, startTime=dehumOnTime3);
  Modelica.Blocks.Math.Add dehum3Ctrl;
  
  Modelica.Blocks.Sources.Step dehum4On(height=1, startTime=dehumOnTime4);
  Modelica.Blocks.Sources.Step dehum4Off(height=-1, startTime=dehumOnTime4);
  Modelica.Blocks.Math.Add dehum4Ctrl;
  
  Modelica.Blocks.Sources.Step dehum5On(height=1, startTime=dehumOnTime5);
  Modelica.Blocks.Sources.Step dehum5Off(height=-1, startTime=dehumOnTime5);
  Modelica.Blocks.Math.Add dehum5Ctrl;
  
  Modelica.Blocks.Sources.Step dehum6On(height=1, startTime=dehumOnTime6);
  Modelica.Blocks.Sources.Step dehum6Off(height=-1, startTime=dehumOnTime6);
  Modelica.Blocks.Math.Add dehum6Ctrl;
  
  Modelica.Blocks.Sources.Step dehum7On(height=1, startTime=dehumOnTime7);
  Modelica.Blocks.Sources.Step dehum7Off(height=-1, startTime=dehumOnTime7);
  Modelica.Blocks.Math.Add dehum7Ctrl;
  
  Modelica.Blocks.Sources.Step dehum8On(height=1, startTime=dehumOnTime8);
  Modelica.Blocks.Sources.Step dehum8Off(height=-1, startTime=dehumOnTime8);
  Modelica.Blocks.Math.Add dehum8Ctrl;


  Buildings.Fluid.Sensors.RelativeHumidityTwoPort humSens(
  redeclare package Medium = Medium,
  tau = 0,
  m_flow_nominal = 0.2);

  

  Buildings.Fluid.Movers.FlowControlled_m_flow fan(
  redeclare package Medium = Medium,
  m_flow_nominal=0.2,
  dp_nominal=50)
  "Fan to circulate air";
  
  // Boundary for reference pressure
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium = Medium,
    nPorts=1) 
    "Boundary to set reference pressure";
    
  Modelica.Blocks.Sources.Constant fanCtrl(k=0.2);
  
  
  //stuff to measure power usage for dehumidifier
  
  Modelica.Blocks.Math.Abs absDehum1;
  Modelica.Blocks.Math.Gain powerDehum1(k=2.45e6);

  Modelica.Blocks.Math.Abs absDehum2;
  Modelica.Blocks.Math.Gain powerDehum2(k=2.45e6);

  Modelica.Blocks.Math.Abs absDehum3;
  Modelica.Blocks.Math.Gain powerDehum3(k=2.45e6);
  
  Modelica.Blocks.Math.Abs absDehum4;
  Modelica.Blocks.Math.Gain powerDehum4(k=2.45e6);
  
  Modelica.Blocks.Math.Abs absDehum5;
  Modelica.Blocks.Math.Gain powerDehum5(k=2.45e6);
  
  Modelica.Blocks.Math.Abs absDehum6;
  Modelica.Blocks.Math.Gain powerDehum6(k=2.45e6);
  
  Modelica.Blocks.Math.Abs absDehum7;
  Modelica.Blocks.Math.Gain powerDehum7(k=2.45e6);
  
  Modelica.Blocks.Math.Abs absDehum8;
  Modelica.Blocks.Math.Gain powerDehum8(k=2.45e6);

  
  
  // --------END Dehumidfier Stuff -----------
  
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor tempSense;
  
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow ac1, ac2, ac3, ac4, ac5, ac6, ac7, ac8;
  
  Modelica.Blocks.Sources.Step ac1On (
    height    = if useAC1 then -7000 else 0,
    startTime = AConTime1
  );
  
  
  Modelica.Blocks.Sources.Step ac1Off (
    height    = if useAC1 then +7000 else 0,
    startTime = ACoffTime1
  );
  
  Modelica.Blocks.Math.Add ac1Sum;
  
  
  Modelica.Blocks.Sources.Step ac2On (
    height    = if useAC2 then -7000 else 0,
    startTime = AConTime2
  );
  
  
  Modelica.Blocks.Sources.Step ac2Off (
    height    = if useAC2 then +7000 else 0,
    startTime = ACoffTime2
  );
  
  Modelica.Blocks.Math.Add ac2Sum;
  
  Modelica.Blocks.Sources.Step ac3On (
    height    = if useAC3 then -9000 else 0,
    startTime = AConTime3
  );
  
  
  Modelica.Blocks.Sources.Step ac3Off (
    height    = if useAC3 then +9000 else 0,
    startTime = ACoffTime3
  );
  
  Modelica.Blocks.Math.Add ac3Sum;
  
  
  Modelica.Blocks.Sources.Step ac4On (
    height    = if useAC4 then -9000 else 0,
    startTime = AConTime4
  );
  
  
  Modelica.Blocks.Sources.Step ac4Off (
    height    = if useAC4 then +9000 else 0,
    startTime = ACoffTime4
  );
  
  Modelica.Blocks.Math.Add ac4Sum;
  
  Modelica.Blocks.Sources.Step ac5On (
    height    = if useAC5 then -10000 else 0,
    startTime = AConTime5
  );
  
  
  Modelica.Blocks.Sources.Step ac5Off (
    height    = if useAC5 then +10000 else 0,
    startTime = ACoffTime5
  );
  
  Modelica.Blocks.Math.Add ac5Sum;
  
  Modelica.Blocks.Sources.Step ac6On (
    height    = if useAC6 then -11000 else 0,
    startTime = AConTime6
  );
  
  
  Modelica.Blocks.Sources.Step ac6Off (
    height    = if useAC6 then +11000 else 0,
    startTime = ACoffTime6
  );
  
  Modelica.Blocks.Math.Add ac6Sum;
  
  Modelica.Blocks.Sources.Step ac7On (
    height    = if useAC7 then -10500 else 0,
    startTime = AConTime7
  );
  
  
  Modelica.Blocks.Sources.Step ac7Off (
    height    = if useAC7 then +10500 else 0,
    startTime = ACoffTime7
  );
  
  Modelica.Blocks.Math.Add ac7Sum;
  
  
  Modelica.Blocks.Sources.Step ac8On (
    height    = if useAC8 then -20000 else 0,
    startTime = AConTime8
  );
  
  
  Modelica.Blocks.Sources.Step ac8Off (
    height    = if useAC8 then +20000 else 0,
    startTime = ACoffTime8
  );
  
  Modelica.Blocks.Math.Add ac8Sum;


equation

  connect(qRadGai_flow.y, multiplex3_1.u1[1]);
  connect(qConGai_flow.y, multiplex3_1.u2[1]);

  connect(qLatGai_flow.y, multiplex3_1.u3[1]);
  connect(multiplex3_1.y, roo.qGai_flow);

  connect(weaDat.weaBus, roo.weaBus);
  connect(uSha.y, replicator.u);
  connect(roo.uSha, replicator.y);

  // ---------start dehumidifer connect  logic  ------
  // Dehumidifier 1 logic
  connect(dehum1On.y, dehum1Ctrl.u1);
  connect(dehum1Off.y, dehum1Ctrl.u2);
  connect(dehum1Ctrl.y, dehum1.u);

  // Dehumidifier 2 logic
  connect(dehum2On.y, dehum2Ctrl.u1);
  connect(dehum2Off.y, dehum2Ctrl.u2);
  connect(dehum2Ctrl.y, dehum2.u);

  // Dehumidifier 3 logic
  connect(dehum3On.y, dehum3Ctrl.u1);
  connect(dehum3Off.y, dehum3Ctrl.u2);
  connect(dehum3Ctrl.y, dehum3.u);
  
  
  connect(dehum4On.y, dehum4Ctrl.u1);
  connect(dehum4Off.y, dehum4Ctrl.u2);
  connect(dehum4Ctrl.y, dehum4.u);
  
  
  connect(dehum5On.y, dehum5Ctrl.u1);
  connect(dehum5Off.y, dehum5Ctrl.u2);
  connect(dehum5Ctrl.y, dehum5.u);
  
  connect(dehum6On.y, dehum6Ctrl.u1);
  connect(dehum6Off.y, dehum6Ctrl.u2);
  connect(dehum6Ctrl.y, dehum6.u);
  
  connect(dehum7On.y, dehum7Ctrl.u1);
  connect(dehum7Off.y, dehum7Ctrl.u2);
  connect(dehum7Ctrl.y, dehum7.u);
  
  connect(dehum8On.y, dehum8Ctrl.u1);
  connect(dehum8Off.y, dehum8Ctrl.u2);
  connect(dehum8Ctrl.y, dehum8.u);


  // Create airflow loop through room, fan, and dehumidifier
  // Fan → Humidifier 1 → Humidifier 2 → Humidifier 3 → Sensor → Room inlet
  connect(roo.ports[1], fan.port_a);
  connect(fan.port_b, dehum1.port_a);
  connect(dehum1.port_b, dehum2.port_a);
  connect(dehum2.port_b, dehum3.port_a);
  connect(dehum3.port_b, dehum4.port_a);
  connect(dehum4.port_b, dehum5.port_a);
  connect(dehum5.port_b, dehum6.port_a);
  connect(dehum6.port_b, dehum7.port_a);
  connect(dehum7.port_b, dehum8.port_a);
  
  connect(dehum8.port_b, humSens.port_a);
   
  
  connect(humSens.port_b, roo.ports[2]);
  connect(bou.ports[1], roo.ports[2]);

  
  connect(fanCtrl.y, fan.m_flow_in);
  
  
  // connect power meter for dehumidifier
  // Dehum1 power
  connect(dehum1.mWat_flow, absDehum1.u);
  connect(absDehum1.y, powerDehum1.u);

  // Dehum2 power
  connect(dehum2.mWat_flow, absDehum2.u);
  connect(absDehum2.y, powerDehum2.u);

  // Dehum3 power
  connect(dehum3.mWat_flow, absDehum3.u);
  connect(absDehum3.y, powerDehum3.u);
  
  connect(dehum4.mWat_flow, absDehum4.u);
  connect(absDehum4.y, powerDehum4.u);

  connect(dehum5.mWat_flow, absDehum5.u);
  connect(absDehum5.y, powerDehum5.u);

  connect(dehum6.mWat_flow, absDehum6.u);
  connect(absDehum6.y, powerDehum6.u);

  connect(dehum7.mWat_flow, absDehum7.u);
  connect(absDehum7.y, powerDehum7.u);

  connect(dehum8.mWat_flow, absDehum8.u);
  connect(absDehum8.y, powerDehum8.u);
 
  
  // --------end dehumidifier connect logic -----
  
  // --------start ac connect logic --------
  
  connect(ac1On.y,  ac1Sum.u1); connect(ac1Off.y,  ac1Sum.u2);
  connect(ac1Sum.y, ac1.Q_flow);  connect(ac1.port, roo.heaPorAir);
  
  
  connect(ac2On.y,  ac2Sum.u1); connect(ac2Off.y,  ac2Sum.u2);
  connect(ac2Sum.y, ac2.Q_flow);  connect(ac2.port, roo.heaPorAir);
  
  
  connect(ac3On.y,  ac3Sum.u1); connect(ac3Off.y,  ac3Sum.u2);
  connect(ac3Sum.y, ac3.Q_flow);  connect(ac3.port, roo.heaPorAir);
  
  
  connect(ac4On.y,  ac4Sum.u1); connect(ac4Off.y,  ac4Sum.u2);
  connect(ac4Sum.y, ac4.Q_flow);  connect(ac4.port, roo.heaPorAir);
  
  
  connect(ac5On.y,  ac5Sum.u1); connect(ac5Off.y,  ac5Sum.u2);
  connect(ac5Sum.y, ac5.Q_flow);  connect(ac5.port, roo.heaPorAir);
  
  connect(ac6On.y,  ac6Sum.u1); connect(ac6Off.y,  ac6Sum.u2);
  connect(ac6Sum.y, ac6.Q_flow);  connect(ac6.port, roo.heaPorAir);
  
  connect(ac7On.y,  ac7Sum.u1); connect(ac7Off.y,  ac7Sum.u2);
  connect(ac7Sum.y, ac7.Q_flow);  connect(ac7.port, roo.heaPorAir);
  
  
  connect(ac8On.y,  ac8Sum.u1); connect(ac8Off.y,  ac8Sum.u2);
  connect(ac8Sum.y, ac8.Q_flow);  connect(ac8.port, roo.heaPorAir);
  
  connect(tempSense.port, roo.heaPorAir);
  
  // ----- end ac connect logic
  

end test_fan;