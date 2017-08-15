#include "server.h"

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

  //Boot interface
  App.Boot -> MainC.Boot;

  //Send and Receive interfaces
  App.ConnectionModule -> ConnectionModuleAppC;
  //App.ConnectionModule -> ConnectionReceiverC;
  App.PublicationReceive -> PublicationReceiverC;

  //Radio Control
  App.SplitControl -> ActiveMessageC;


}

