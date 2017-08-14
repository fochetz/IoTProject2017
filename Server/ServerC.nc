#include "server.h"
#include "packets.h"
#include "Timer.h"

#include "printf.h"



module ServerC {



  uses { 

	interface Boot;

    	interface AMPacket;

	interface Packet;

	interface PacketAcknowledgements;

    	interface AMSend;

    	interface SplitControl;

	//interface Receive as SubscriptionReceive;
    	interface Receive as ConnectionReceive;
	interface Receive as PublicationReceive;

    	interface Timer<TMilli> as MilliTimer;

	interface Read<uint16_t>;

  }



} implementation {



  uint8_t counter=0;

  uint8_t rec_id;

  message_t packet;

  //***************** Function send connack ********************//

  void sendConnack(uint8_t client) {
	con_msg_t* mess;
	mess=(con_msg_t*)(call Packet.getPayload(&packet,sizeof(con_msg_t)));
	mess->msg_type = CONNACK;
	mess->sender_id = TOS_NODE_ID;
	if(call AMSend.send(client,&packet,sizeof(con_msg_t)) == SUCCESS){
		printf("Server successfully sent connack message!");
		
	}



 }      
  //***************** Boot interface ********************//

  event void Boot.booted() {
	printf("|PANC| Booted. TOS ID: %u\n", TOS_NODE_ID);
	call SplitControl.start();

  }



  //***************** SplitControl interface ********************//

  event void SplitControl.startDone(error_t err){   

    if(err == SUCCESS) {
		printf("|PANC| Radio ON.\n");

    }
    else{
	call SplitControl.start();
    }
  }

  

  event void SplitControl.stopDone(error_t err){}



  //***************** MilliTimer interface ********************//

    event void MilliTimer.fired() {

  }



  //********************* AMSend interface ****************//

  event void AMSend.sendDone(message_t* buf,error_t err) {



    if(&packet == buf && err == SUCCESS ) {
    }



  }

void handle_con_message(void* payload)
{
	uint8_t addr;
	con_msg_t* mess=(con_msg_t*)payload;
     if ( mess->msg_type == CONNECT ) {
		printf("Server: received Connect request \n");
		addr = mess->sender_id;
		sendConnack(addr);
	       }	

}

   event message_t* ConnectionReceive.receive(message_t* buf, void* payload, uint8_t len) {
	if (len!=sizeof(simple_msg_t)){
		printf("|PANC| Something wrong in CONNECT packet");
	}
	else {
		simple_msg_t* mess = (simple_msg_t*)payload;
		printf("|PANC| CONNECT received from %d\n", mess->sender_id);
	}
	return buf;
}

   event message_t* PublicationReceive.receive(message_t* buf, void* payload, uint8_t len) {
	printf("|PANC| PUBLISH received\n");
	return buf;
}

  

  //************************* Read interface **********************//

  event void Read.readDone(error_t result, uint16_t data) {

  }



}


