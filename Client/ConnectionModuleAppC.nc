#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration ConnectionModuleAppC {

	provides interface ConnectionModule;

}

implementation {

  	components ConnectionModuleC as App;
  	components new AMSenderC(CONNECT_AM) as ConnectSenderC;
  	components new AMReceiverC(CONNACK_AM) as ConnackReceiverC;
  	components SerialPrintfC;
  	components SerialStartC;

	ConnectionModule = App;

  	App.ConnackReceive -> ConnackReceiverC;
  	App.ConnectSender -> ConnectSenderC;
	App.Packet -> ConnectSenderC;
  	App.AMPacket -> ConnectSenderC;


}
