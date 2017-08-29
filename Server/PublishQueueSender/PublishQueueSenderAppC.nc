#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration PublishQueueSenderAppC {

		provides interface PublishQueueSender;

}

implementation {

  	components PublishQueueSenderC as App;
  	components new AMSenderC(PUBLISH_AM) as PublishSenderC;
	components new TimerMilliC();
	components SerialPrintfC;
  	components SerialStartC;
	components ActiveMessageC;

	PublishQueueSender = App;
	App.SenderTimer = TimerMilliC;
  	App.PublishSender -> PublishSenderC;
	App.Packet -> PublishSenderC;
  	App.AMPacket -> PublishSenderC;
	App.PacketAcknowledgements->ActiveMessageC;
}

