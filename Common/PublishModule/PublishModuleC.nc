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

	bool ackablePublish(uint8_t destination, uint8_t topic, uint16_t data, uint8_t senderId) {
		
		setPublishPacket(topic, data, 1, senderId);
		return call PublishSender.pushMessage(&packet, destination, TRUE);

	}

	bool publish(uint8_t destination, uint8_t topic, uint16_t data, uint8_t senderId) {

		setPublishPacket(topic, data, 0, senderId);
		return call PublishSender.pushMessage(&packet, destination, FALSE);
			
	}


	bool command PublishModule.publish(uint8_t destination, uint8_t topic, uint16_t data, bool qos, uint8_t senderId) {

		//printfDebug("<PM> Publishing to %d T:%d, D:%d, Q:%d from %d\n", destination, topic, data, qos, senderId);
		if (qos)
			return ackablePublish(destination, topic, data, senderId);
		else
			return publish(destination, topic, data, senderId);
	}

	event message_t* PublishReceive.receive(message_t* buf, void* payload, uint8_t len) {
		
		if (len!=sizeof(pub_msg_t)){
			printfDebug("<PM> Something wrong in PUBLISH packet\n");
		}
		else {
			pub_msg_t* mess = (pub_msg_t*)payload;
		
			signal PublishModule.OnPublicationReceive(mess->topic, mess->data, mess->qos, mess->senderId); 
			//TODO: check if node is subscribed to the topic			
			
		}
		return buf;	

	}
}
