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

		//printf("|PANC| <ConnectionModule> Sending ack to %d\n", destinationId);
		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId = TOS_NODE_ID;
		call PacketAcknowledgements.requestAck( &packet );
		if(call ConnectSender.send(1,&packet,sizeof(simple_msg_t)) == SUCCESS){
			printf("DEBUG: |NODE %d| <CM> Sending CONNECT to PANC\n", TOS_NODE_ID);
		

		}
	}

	bool command ConnectionModule.isConnected() {
		return connected;
	}

	
	event void ConnectSender.sendDone(message_t* buf,error_t err) {
		
		if(&packet == buf && err == SUCCESS ) {
			if ( call PacketAcknowledgements.wasAcked( buf ) ) 
			{				
				printf("DEBUG: |NODE %d| <CM> CONNACK received from PANC\n", TOS_NODE_ID);
				if (call ConnectionModule.isConnected()) {
					printf("DEBUG: |NODE %d| <CM> Is already connected\n", TOS_NODE_ID);
				}
				else {
					signal ConnectionModule.OnConnectedToPanc();
					connected = 1;
				}
			}	
		}

	}
}
