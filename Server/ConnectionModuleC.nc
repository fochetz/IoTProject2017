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
	bool radioBusy = FALSE;

	void command ConnectionModule.addConnectedDevice(uint8_t device) {

		connectedDevices[device-2]=1;
		signal ConnectionModule.OnNewDeviceConnected(device);


	}

	void command ConnectionModule.sendAck(uint8_t destinationId) {

		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;

		if (radioBusy == FALSE) {
			radioBusy = TRUE;
			switch (call ConnackSender.send(destinationId,&packet,sizeof(simple_msg_t))) 				{
				case SUCCESS: call ConnectionModule.addConnectedDevice(destinationId); break;
				default: break;
			}
		}
		else {
			//printf("BUSY\n");

		}
		

	}

	bool command ConnectionModule.isConnected(uint8_t id) {

		return connectedDevices[id-2];

	}



	event message_t* ConnectionReceive.receive(message_t* buf, void* payload, uint8_t len) {

		if (len!=sizeof(simple_msg_t)){
			printf("DEBUG: <CM> Something wrong in CONNECT packet\n");
		}
		else {
			simple_msg_t* mess = (simple_msg_t*)payload;
			printf("DEBUG: <CM> CONNECT received from %d\n", mess->senderId);
			if (call ConnectionModule.isConnected(mess->senderId)) {
				printf("DEBUG: <CM> Node %d is already connected. Ignoring\n", mess->senderId);
			}
			else {

				call ConnectionModule.sendAck(mess->senderId);
				
			}			
			
		}
		return buf;

	}
	
	event void ConnackSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			radioBusy = FALSE;
    		}
    		//radioBusy = FALSE;
	}
}
