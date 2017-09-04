#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration ServerAppC {
}

implementation {

  components MainC, ServerC as App;
  components new AMReceiverC(PUBLISH_AM) as PublicationReceiverC;
  components ActiveMessageC;
  components SerialPrintfC;
  components SerialStartC;
  components ConnectionModuleAppC;
  components SubscribeModuleAppC;
  components new QueueSenderAppC(PUBLISH_AM) as PublishQueueSender;

  //Boot interface
  App.Boot -> MainC.Boot;

  //Send and Receive interfaces
  App.ConnectionModule -> ConnectionModuleAppC;
  App.SubscribeModule -> SubscribeModuleAppC;
  //App.ConnectionModule -> ConnectionReceiverC;
  App.PublicationReceive -> PublicationReceiverC;
  App.QueueSender -> PublishQueueSender;

  //Radio Control
  App.SplitControl -> ActiveMessageC;


}

