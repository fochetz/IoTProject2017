#include "packets.h"

module ConnectionModuleC
{

	provides interface ConnectionModule;
	uses {
 		interface Receive as ConnectionReceive;
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
				call ConnectionModule.addConnectedDevice(mess->senderId);
			}			
			
		}
		return buf;

	}
	
}
