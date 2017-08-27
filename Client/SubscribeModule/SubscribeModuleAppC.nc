#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration SubscribeModuleAppC {

		provides interface SubscribeModule;

}

implementation {

  	components SubscribeModuleC as App;
  	components new AMSenderC(SUBSCRIBE_AM) as SubscribeSenderC;
  	components new AMReceiverC(SUBACK_AM) as SubackReceiverC;
	components SerialPrintfC;
  	components SerialStartC;
	components ActiveMessageC;

	SubscribeModule = App;

  	App.SubackReceive -> SubackReceiverC;
  	App.SubscribeSender -> SubscribeSenderC;
	App.Packet -> SubscribeSenderC;
  	App.AMPacket -> SubscribeSenderC;
	App.PacketAcknowledgements->ActiveMessageC;
}

