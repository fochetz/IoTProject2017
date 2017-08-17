#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"


configuration ClientAppC {}

implementation {

  components MainC, ClientC as App;
	components ConnectionModuleAppC;
  components ActiveMessageC;
  components new TimerMilliC();
  components new FakeSensorC();
  components SerialPrintfC;
  components SerialStartC;

  //Boot interface
  App.Boot -> MainC.Boot;

  //Radio Control
  App.SplitControl -> ActiveMessageC;

  //Timer interface
  App.MilliTimer -> TimerMilliC;

  //Fake Sensor read
  App.TempRead -> FakeSensorC.TempRead;
  App.HumRead -> FakeSensorC.HumRead;
  App.LumRead -> FakeSensorC.LumRead;

	App.ConnectionModule -> ConnectionModuleAppC;


}

