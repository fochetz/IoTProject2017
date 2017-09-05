#include "packets.h"

module PublishModuleC
{

	provides interface PublishModule;

	uses {
 		interface Receive as PublishReceive;
		interface QueueSender as PublishSender;
		interface AMPacket;
		interface Packet;
	} 

}
implementation
{
	message_t packet;

	void setPublishPacket(uint8_t topic, uint16_t data, bool qos, uint8_t senderId) {
		pub_msg_t* mess=(pub_msg_t*)(call Packet.getPayload(&packet,sizeof(pub_msg_t)));
		mess->topic = topic;
		mess->senderId = senderId;
		mess->data = data;
		mess->qos = qos;
		
	}

	void ackablePublish(uint8_t destination, uint8_t topic, uint16_t data, uint8_t senderId) {
		
		setPublishPacket(topic, data, 1, senderId);
		call PublishSender.pushMessage(&packet, destination, TRUE);

	}

	void publish(uint8_t destination, uint8_t topic, uint16_t data, uint8_t senderId) {

		setPublishPacket(topic, data, 0, senderId);
		call PublishSender.pushMessage(&packet, destination, FALSE);
			
	}


	void command PublishModule.publish(uint8_t destination, uint8_t topic, uint16_t data, bool qos, uint8_t senderId) {
		printf("DEBUG: |NODE %d| Publishing to %d T:%d, D:%d, Q:%d from %d\n",TOS_NODE_ID, destination, topic, data, qos, senderId);
		if (qos)
			ackablePublish(destination, topic, data, senderId);
		else
			publish(destination, topic, data, senderId);
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
