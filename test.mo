model test "Free response of room model"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Air "Medium model";

  parameter Integer nAC = 1;


  parameter Modelica.Units.SI.Time onTime1  = 0;
  parameter Modelica.Units.SI.Time offTime1 = 1000;
  parameter Modelica.Units.SI.Time onTime2  = 300;
  parameter Modelica.Units.SI.Time offTime2 = 1000;
  parameter Modelica.Units.SI.Time onTime3  = 300;
  parameter Modelica.Units.SI.Time offTime3 = 1000;
  parameter Modelica.Units.SI.Time onTime4  = 300;
  parameter Modelica.Units.SI.Time offTime4 = 1000;
  parameter Modelica.Units.SI.Time onTime5  = 300;
  parameter Modelica.Units.SI.Time offTime5 = 1000;



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

  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor tempSense;

  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow ac1, ac2, ac3, ac4, ac5;

  
  Modelica.Blocks.Sources.Step ac1On (
    height    = if nAC>=1 then -7000 else 0,
    startTime = onTime1
  );
  
  
  Modelica.Blocks.Sources.Step ac1Off (
    height    = if nAC>=1 then +7000 else 0,
    startTime = offTime1
  );
  
  Modelica.Blocks.Math.Add ac1Sum;
  
  Modelica.Blocks.Sources.Step ac2On (
    height    = if nAC>=2 then -5000 else 0,
    startTime = onTime2
  );
  
  
  Modelica.Blocks.Sources.Step ac2Off (
    height    = if nAC>=2 then +5000 else 0,
    startTime = offTime2
  );
  
  Modelica.Blocks.Math.Add ac2Sum;
  
  
  
  Modelica.Blocks.Sources.Step ac3On (
    height    = if nAC>=3 then -5500 else 0,
    startTime = onTime3
  );
  
  
  Modelica.Blocks.Sources.Step ac3Off (
    height    = if nAC>=3 then +5500 else 0,
    startTime = offTime3
  );
  
  Modelica.Blocks.Math.Add ac3Sum;
  
  
  
  Modelica.Blocks.Sources.Step ac4On (
    height    = if nAC>=4 then -8000 else 0,
    startTime = onTime4
  );
  
  
  Modelica.Blocks.Sources.Step ac4Off (
    height    = if nAC>=4 then +8000 else 0,
    startTime = offTime4
  );
  
  Modelica.Blocks.Math.Add ac4Sum;
  
  
  
  Modelica.Blocks.Sources.Step ac5On (
    height    = if nAC>=5 then -9000 else 0,
    startTime = onTime5
  );
  
  
  Modelica.Blocks.Sources.Step ac5Off (
    height    = if nAC>=5 then +9000 else 0,
    startTime = offTime5
  );
  
  Modelica.Blocks.Math.Add ac5Sum;
  


equation

  connect(qRadGai_flow.y, multiplex3_1.u1[1]);
  connect(qConGai_flow.y, multiplex3_1.u2[1]);

  connect(qLatGai_flow.y, multiplex3_1.u3[1]);
  connect(multiplex3_1.y, roo.qGai_flow);

  connect(weaDat.weaBus, roo.weaBus);
  connect(uSha.y, replicator.u);
  connect(roo.uSha, replicator.y);

 
  //connect(ac1.Q_flow, acPower1.y); connect(ac1.port, roo.heaPorAir);
  
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


  connect(tempSense.port, roo.heaPorAir);

end test;
