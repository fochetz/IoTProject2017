#include "packets.h"

module SubscribeModuleC
{

	provides interface SubscribeModule;
	uses {
 		interface Receive as SubackReceive;
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

		sub_msg_t* mess=(sub_msg_t*)(call Packet.getPayload(&packet,sizeof(sub_msg_t)));
		mess->senderId = TOS_NODE_ID;
		mess->topics = topic;
		mess->qos = qos;
		//set acknowledgement
		call PacketAcknowledgements.requestAck( &packet );
		if(call SubscribeSender.send(1,&packet,sizeof(sub_msg_t)) == SUCCESS){
		printf("DEBUG: |NODE %d| <SM> Sending SUBSCRIBE to PANC\n", TOS_NODE_ID);
		

		}
	}
	
	void command SubscribeModule.setTopic(uint8_t topics, uint8_t QOS)
	{
		topic=topics;
		qos=QOS;
	}
	
	
	bool command SubscribeModule.isSubscribed(){
		return isSubscribe;
	}
	
	
	event message_t* SubackReceive.receive(message_t* buf, void* payload, uint8_t len) {
		if(len == sizeof(simple_msg_t))
		{
			isSubscribe=1;
			printf("DEBUG: |NODE %d| <SM>  SUBSCRIBE ack received from PANC\n", TOS_NODE_ID);
		}
		return buf;
	}
	
	
	event void SubscribeSender.sendDone(message_t* buf,error_t err) {
		if(&packet == buf && err == SUCCESS ) {
			/*if ( call PacketAcknowledgements.wasAcked( buf ) ) {				
				printf("DEBUG: |NODE %d| <SM>  SUBSCRIBE ack received from PANC\n", TOS_NODE_ID);
				isSubscribe=1;
			}*/	
		}
	}

}
