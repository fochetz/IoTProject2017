#include "packets.h"

module ConnectionModuleC
{

	provides interface ConnectionModule;
	uses {
 		interface Receive as ConnackReceive;
		interface AMSend as ConnectSender;
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
	}

}
implementation
{

	bool connected = 0;
	message_t packet;
	bool radioBusy = FALSE;
	
	void command ConnectionModule.sendConnect() {

		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;
		call PacketAcknowledgements.requestAck( &packet );
		if(radioBusy == FALSE && call ConnectSender.send(1,&packet,sizeof(simple_msg_t)) == SUCCESS){
			radioBusy=TRUE;
			printfDebug("<CM> Sending CONNECT to PANC\n");
		}

	}

	bool command ConnectionModule.isConnected() {

		return connected;

	}

	
	event void ConnectSender.sendDone(message_t* buf,error_t err) {
		
		if(&packet == buf && err == SUCCESS ) {
			radioBusy = FALSE;
		}

	}

	event message_t* ConnackReceive.receive(message_t* buf, void* payload, uint8_t len) {
 
 		if (len!=sizeof(simple_msg_t)){
 			printfDebug("<CM> Something wrong in CONNACK packet\n");
 		}
 		else {
 			printfDebug("<CM> CONNACK received from PANC\n");
 			if (call ConnectionModule.isConnected()) {
 				printfDebug("<CM> Is already connected\n");
 			}
 			else {
				signal ConnectionModule.OnConnectedToPanc();
				connected = 1;
			}

		}
		return buf;

	}
}
