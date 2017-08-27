#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration PublishModuleAppC {

	provides interface PublishModule;

}

implementation {

  	components PublishModuleC as App;
  	components new AMSenderC(PUBLISH_AM) as PublishSenderC;
  
  	components SerialPrintfC;
  	components SerialStartC;

	PublishModule = App;

  	//App.ConnackReceive -> ConnackReceiverC;
  	App.PublishSender -> PublishSenderC;
	App.Packet -> PublishSenderC;
  	App.AMPacket -> PublishSenderC;


}
