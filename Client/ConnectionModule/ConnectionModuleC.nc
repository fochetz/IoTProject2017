#include "packets.h"

module ConnectionModuleC
{

	provides interface ConnectionModule;
	uses {
 		//interface Receive as ConnackReceive;
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
	
	void command ConnectionModule.sendConnect() {

		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;
		call PacketAcknowledgements.requestAck( &packet );
		if(call ConnectSender.send(1,&packet,sizeof(simple_msg_t)) == SUCCESS){
			//printfDebug("<CM> Sending CONNECT to PANC\n");
		

		}
	}

	bool command ConnectionModule.isConnected() {
		return connected;
	}

	
	event void ConnectSender.sendDone(message_t* buf,error_t err) {
		
		if(&packet == buf && err == SUCCESS ) {
			if ( call PacketAcknowledgements.wasAcked( buf ) ) 
			{				
				//printfDebug("<CM> CONNACK received from PANC\n");
				if (call ConnectionModule.isConnected()) {
					//printfDebug("<CM> Is already connected\n");
				}
				else {
					signal ConnectionModule.OnConnectedToPanc();
					connected = 1;
				}
			}	
		}

	}
}
