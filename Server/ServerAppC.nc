#include "server.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration ServerAppC {}

implementation {

  components MainC, ServerC as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(CONNECT_AM) as ConnectionReceiverC;
  components new AMReceiverC(PUBLISH_AM) as PublicationReceiverC;
  components ActiveMessageC;
  components new TimerMilliC();
  components new FakeSensorC();
  components SerialPrintfC;
  components SerialStartC;

  //Boot interface
  App.Boot -> MainC.Boot;

  //Send and Receive interfaces
  App.ConnectionReceive -> ConnectionReceiverC;
  App.PublicationReceive -> PublicationReceiverC;
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
  App.Read -> FakeSensorC;

}

