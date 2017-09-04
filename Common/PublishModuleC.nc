#include "packets.h"

module PublishModuleC
{

	provides interface PublishModule;

	uses {
 		interface Receive as PublishReceive;
		interface AMSend as PublishSender;
		interface AMPacket;
		interface Packet;
	} 

}
implementation
{
	message_t packet;

	pub_msg_t* getPublishPacket(uint8_t topic, uint16_t data, bool qos, uint8_t senderId) {
		pub_msg_t* mess=(pub_msg_t*)(call Packet.getPayload(&packet,sizeof(pub_msg_t)));
		mess->topic = topic;
		mess->senderId = TOS_NODE_ID;
		mess->data = data;
		mess->qos = qos;
		return mess;
	}

	void ackablePublish(uint8_t topic, uint16_t data, uint8_t senderId) {

		//pub_msg_t* mess = getPublishPacket(topic, data, 1);
		//printf("PROVA: %d\n", mess->data);

	}

	void publish(uint8_t topic, uint16_t data, uint8_t senderId) {

		//pub_msg_t* mess = getPublishPacket(topic, data, 0, senderId);
			
	}


	void command PublishModule.publish(uint8_t topic, uint16_t data, bool qos, uint8_t senderId) {
		printf("DEBUG: |NODE %d| Publishing %d, %d, %d from %d\n",TOS_NODE_ID, topic, data, qos, senderId);
		if (qos)
			ackablePublish(topic, data, senderId);
		else
			publish(topic, data, senderId);
	}

	

	event void PublishSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			//radioBusy = FALSE;
    		}
    		
	}

	event message_t* PublishReceive.receive(message_t* buf, void* payload, uint8_t len) {
		
		if (len!=sizeof(pub_msg_t)){
			printf("DEBUG: <PM> Something wrong in PUBLISH packet\n");
		}
		else {
			pub_msg_t* mess = (pub_msg_t*)payload;
		
			signal PublishModule.OnPublicationReceive(mess->topic, mess->data, mess->qos, mess->senderId); 
			//TODO: check if node is subscribed to the topic			
			
		}
		return buf;	

	}
}
