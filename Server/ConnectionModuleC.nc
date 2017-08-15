#include "packets.h"

module ConnectionModuleC
{

	provides interface ConnectionModule;
	uses {
 		interface Receive as ConnectionReceive;
		interface AMSend as ConnackSender;
		interface AMPacket;
		interface Packet;
	}

}
implementation
{

	bool connectedDevices[N_NODES];
	message_t packet;
	
	void command ConnectionModule.sendAck(uint8_t destinationId) {

		//printf("|PANC| <ConnectionModule> Sending ack to %d\n", destinationId);
		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;
		if(call ConnackSender.send(destinationId,&packet,sizeof(simple_msg_t)) == SUCCESS){
		printf("|PANC| <ConnectionModule> Sending CONNACK to %d\n", destinationId);
		

		}
	}

	bool command ConnectionModule.isConnected(uint8_t id) {
		return connectedDevices[id];
	}



	event message_t* ConnectionReceive.receive(message_t* buf, void* payload, uint8_t len) {

		if (len!=sizeof(simple_msg_t)){
			printf("|PANC| <ConnectionModule> Something wrong in CONNECT packet\n");
		}
		else {
			simple_msg_t* mess = (simple_msg_t*)payload;
			printf("|PANC| <ConnectionModule> CONNECT received from %d\n", mess->senderId);
			if (call ConnectionModule.isConnected(mess->senderId)) {
				printf("|PANC| <ConnectionModule> Node %d is already connected\n", mess->senderId);
			}
			else {
				signal ConnectionModule.OnNewDeviceConnected(mess->senderId);
				connectedDevices[mess->senderId]=1;
			}			
			
		}
		return buf;

	}
	
	event void ConnackSender.sendDone(message_t* buf,error_t err) {

    		if(&packet == buf && err == SUCCESS ) {
			//printf("|PANC| <ConnectionModule> Sending ack to %d\n", destinationId);
    		}

	}
}
