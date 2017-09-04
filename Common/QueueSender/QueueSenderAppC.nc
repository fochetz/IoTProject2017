#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

generic configuration QueueSenderAppC(packet_channel channel) {

		provides interface QueueSender;

}

implementation {

  	components new QueueSenderC() as App;
  	components new AMSenderC(channel) as PublishSenderC;
	components new TimerMilliC();
	components SerialPrintfC;
  	components SerialStartC;
	components ActiveMessageC;

	QueueSender = App;
	App.SenderTimer -> TimerMilliC;
  	App.PublishSender -> PublishSenderC;
	App.Packet -> PublishSenderC;
  	App.AMPacket -> PublishSenderC;
	App.PacketAcknowledgements->ActiveMessageC;
}


