#include "packets.h"

module PublishModuleC
{

	provides interface PublishModule;

	uses {
 		//interface Receive as ConnackReceive;
		interface AMSend as PublishSender;
		interface AMPacket;
		interface Packet;
	} 

}
implementation
{
	message_t packet;

	pub_msg_t* getPublishPacket(uint8_t topic, uint8_t data, bool qos) {
		pub_msg_t* mess=(pub_msg_t*)(call Packet.getPayload(&packet,sizeof(pub_msg_t)));
		mess->topic = topic;
		mess->senderId = TOS_NODE_ID;
		mess->data = data;
		mess->qos = qos;
		return mess;
	}

	void ackablePublish(uint8_t topic, uint8_t data) {

		pub_msg_t* mess = getPublishPacket(topic, data, 1);
		//printf("PROVA: %d\n", mess->data);

	}

	void publish(uint8_t topic, uint8_t data) {

		pub_msg_t* mess = getPublishPacket(topic, data, 0);
			
	}


	void command PublishModule.publish(uint8_t topic, uint8_t data, bool qos) {
		printf("%d, %d, %d\n", topic, data, qos);
		if (qos)
			ackablePublish(topic, data);
		else
			publish(topic, data);
	}

	

	event void PublishSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			//radioBusy = FALSE;
    		}
    		
	}
}
