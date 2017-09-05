#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

generic configuration QueueSenderAppC(packet_channel channel) {

		provides interface QueueSender;
		provides interface Packet;

}

implementation {

  	components new QueueSenderC() as App;
  	components new AMSenderC(channel) as PublishQueueSenderC;
	components new TimerMilliC();
	components SerialPrintfC;
  	components SerialStartC;
	components ActiveMessageC;

	QueueSender = App;
	
	App.SenderTimer -> TimerMilliC;
  	App.PublishSender -> PublishQueueSenderC;
	//App.Packet -> PublishQueueSenderC;
  	//App.AMPacket -> PublishQueueSenderC;

	Packet = PublishQueueSenderC;
	App.PacketAcknowledgements->ActiveMessageC;
}


