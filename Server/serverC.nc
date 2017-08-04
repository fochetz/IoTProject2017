/**

 *  Source file for implementation of module sendAckC in which

 *  the node 1 send a request to node 2 until it receives a response.

 *  The reply message contains a reading from the Fake Sensor.

 *

 *  @author Luca Pietro Borsani

 */



#include "server.h"

#include "Timer.h"

#include "printf.h"



module serverC {



  uses {

	interface Boot;

    	interface AMPacket;

	interface Packet;

	interface PacketAcknowledgements;

    	interface AMSend;

    	interface SplitControl;

    	interface Receive;

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
	printf("This is my tos ID: %u\n", TOS_NODE_ID);
	call SplitControl.start();

  }



  //***************** SplitControl interface ********************//

  event void SplitControl.startDone(error_t err){

      

    if(err == SUCCESS) {
		printf("Server successfully started radio! \n");

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


  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	printf("Server: %d Len, %d ConMSGT\n",len,sizeof(con_msg_t));
	switch(len)
	{
		case sizeof(con_msg_t):
			handle_con_message(payload);
			break;
		default:
			printf("Server: Packet not recognized\n");
			break;
	}
	
    return buf;
}	

  

  //************************* Read interface **********************//

  event void Read.readDone(error_t result, uint16_t data) {

  }



}


