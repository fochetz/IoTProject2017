#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"


configuration ClientAppC {}

implementation {

  	components MainC, ClientC as App;

	components ConnectionModuleAppC;
	components SubscribeModuleAppC;
	components PublishModuleAppC;

  	components ActiveMessageC;
  	components new TimerMilliC() as ConnectionTimer;
 	components new TimerMilliC() as SubscribeTimer;
	components new TimerMilliC() as SensorTimer;
  	components new FakeSensorC();
  	components SerialPrintfC;
  	components SerialStartC;

  	//Boot interface
  	App.Boot -> MainC.Boot;

  	//Radio Control
  	App.SplitControl -> ActiveMessageC;

  	//Timer interface
  	App.ConnectionTimer -> ConnectionTimer;
  	App.SubscribeTimer -> SubscribeTimer;

	//Fake Sensor read
	App.TempRead -> FakeSensorC.TempRead;
	App.HumRead -> FakeSensorC.HumRead;
	App.LumRead -> FakeSensorC.LumRead;

	App.ConnectionModule -> ConnectionModuleAppC;
	App.SubscribeModule -> SubscribeModuleAppC;
	App.PublishModule -> PublishModuleAppC;
	
	App.SensorTimer -> SensorTimer;


}

