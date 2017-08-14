#include "client.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"


configuration ClientAppC {}

implementation {

  components MainC, ClientC as App;
  components new AMSenderC(CONNECT_AM);
  components new AMReceiverC(AM_MY_MSG);
  components ActiveMessageC;
  components new TimerMilliC();
  components new FakeSensorC();
  components SerialPrintfC;
  components SerialStartC;

  //Boot interface
  App.Boot -> MainC.Boot;

  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;

  //Radio Control
  App.SplitControl -> ActiveMessageC;

  //Interfaces to access package fields
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements->ActiveMessageC;

  //Timer interface
  App.MilliTimer -> TimerMilliC;

  //Fake Sensor read
  App.TempRead -> FakeSensorC.TempRead;
  App.HumRead -> FakeSensorC.HumRead;
  App.LumRead -> FakeSensorC.LumRead;


}

