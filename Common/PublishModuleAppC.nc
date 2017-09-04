#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration PublishModuleAppC {

	provides interface PublishModule;

}

implementation {

  	components PublishModuleC as App;
  	components new AMSenderC(PUBLISH_AM) as PublishSenderC;
	components new AMReceiverC(PUBLISH_AM) as PublishReceiverC;
  
  	components SerialPrintfC;
  	components SerialStartC;

	PublishModule = App;

  	//App.ConnackReceive -> ConnackReceiverC;
  	App.PublishSender -> PublishSenderC;
	App.PublishReceive -> PublishReceiverC;
	App.Packet -> PublishSenderC;
  	App.AMPacket -> PublishSenderC;


}
