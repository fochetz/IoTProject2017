#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration PublishModuleAppC {

	provides interface PublishModule;

}

implementation {

  	components PublishModuleC as App;
  	//components new AMSenderC(PUBLISH_AM) as PublishSenderC;
	components new AMReceiverC(PUBLISH_AM) as PublishReceiverC;
	components new QueueSenderAppC(PUBLISH_AM,sizeof(pub_msg_t)) as PublishQueueSender;
  
  	components SerialPrintfC;
  	components SerialStartC;

	PublishModule = App;

  	//App.ConnackReceive -> ConnackReceiverC;
  	App.PublishSender -> PublishQueueSender;
	App.PublishReceive -> PublishReceiverC;
	App.Packet -> PublishQueueSender;
  	//App.AMPacket -> PublishSenderC;


}
