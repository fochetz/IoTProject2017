#include "packets.h"

module SubscribeModuleC
{

	provides interface SubscribeModule;
	uses {
		interface AMSend as SubscribeSender;
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
	}

}

implementation{
	bool isSubscribe=0;
	message_t packet;
	uint8_t topic;
	uint8_t qos;
	
	void command SubscribeModule.sendSubscribe() {
		
		if (!topic) {
			printfDebug("<SM> Not sending SUBSCRIBE. No topics selected");
		}
		else {
			
			sub_msg_t* mess=(sub_msg_t*)(call Packet.getPayload(&packet,sizeof(sub_msg_t)));
			mess->senderId = TOS_NODE_ID;
			mess->topics = topic;
			mess->qos = qos&topic;
			//set acknowledgement
			
			call PacketAcknowledgements.requestAck( &packet );
			if(call SubscribeSender.send(PANC_ID,&packet,sizeof(sub_msg_t)) == SUCCESS){
				printfDebug("<SM> Sending SUBSCRIBE to PANC\n");
			}
		}
	}
	
	void command SubscribeModule.setTopic(uint8_t topics, uint8_t QOS)
	{
		printfH("Setting subscriptions THL: %d%d%d QOS %d%d%d\n",(topics&TEMP_MASK)&&1, (topics&HUMI_MASK)&&1, (topics&LUMI_MASK)&&1 ,(QOS&TEMP_MASK)&&1, (QOS&HUMI_MASK)&&1, (QOS&LUMI_MASK)&&1);
		topic=topics;
		qos=QOS;
	}
	
	
	bool command SubscribeModule.isSubscribed(){
		return isSubscribe;
	}
	
	
	event void SubscribeSender.sendDone(message_t* buf,error_t err) {
		if(&packet == buf && err == SUCCESS ) {
			if ( call PacketAcknowledgements.wasAcked( buf ) ) {				
				printfDebug("<SM>  SUBSCRIBE ack received from PANC\n");
				isSubscribe=1;
				signal SubscribeModule.OnSubscribeToPanc();
			}	
		}
	}

}
