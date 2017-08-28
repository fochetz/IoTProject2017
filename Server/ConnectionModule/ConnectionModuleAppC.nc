#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration ConnectionModuleAppC {

	provides interface ConnectionModule;

}

implementation {

  	components ConnectionModuleC as App;
  	components new AMReceiverC(CONNECT_AM) as ConnectionReceiverC;
  	components SerialPrintfC;
  	components SerialStartC;

	ConnectionModule = App;

  	App.ConnectionReceive -> ConnectionReceiverC;


}

