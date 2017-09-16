#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration SubscribeModuleAppC {

		provides interface SubscribeModule;

}

implementation {

  	components SubscribeModuleC as App;
  	components new AMSenderC(SUBACK_AM) as SubackSenderC;
  	components new AMReceiverC(SUBSCRIBE_AM) as SubscribeReceiverC;
	components SerialPrintfC;
  	components SerialStartC;
	components ActiveMessageC;

	SubscribeModule = App;

  	App.SubscribeReceive -> SubscribeReceiverC;
  	App.SubackSender -> SubackSenderC;
	App.Packet -> SubackSenderC;
  	App.AMPacket -> SubackSenderC;
	
}

