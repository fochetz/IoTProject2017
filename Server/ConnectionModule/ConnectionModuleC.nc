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
		call ConnectionModule.sendConnack(device);
		


	}

	bool command ConnectionModule.isConnected(uint8_t id) {

		return connectedDevices[id-2];

	}



	event message_t* ConnectionReceive.receive(message_t* buf, void* payload, uint8_t len) {

		if (len!=sizeof(simple_msg_t)){
			printfDebug("<CM> Something wrong in CONNECT packet\n");
		}
		else {
			simple_msg_t* mess = (simple_msg_t*)payload;
			printfDebug("<CM> CONNECT received from %d\n", mess->senderId);
			signal ConnectionModule.OnConnectReceived(mess->senderId);
		}
		return buf;

	}

	void command ConnectionModule.sendConnack(uint8_t destinationId) {

		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;

		if (radioBusy == FALSE) {
 			radioBusy = TRUE;
 			if (call ConnackSender.send(destinationId,&packet,sizeof(simple_msg_t))==SUCCESS) 				{
				printfDebug("<CM> CONNACK sent to Node %d\n", destinationId);
			}
		}
		

	}

	event void ConnackSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			radioBusy = FALSE;
    		}
    		//radioBusy = FALSE;
	}
	
}
