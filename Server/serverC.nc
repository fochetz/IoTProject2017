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
	my_msg_t* mess;
	mess=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
	mess->msg_type = CONNACK;
	mess->msg_id = counter++;
	if(call AMSend.send(client,&packet,sizeof(my_msg_t)) == SUCCESS){
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



  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {


	uint8_t addr;
	my_msg_t* mess=(my_msg_t*)payload;
	rec_id = mess->msg_id;
     if ( mess->msg_type == CONNECT ) {
		printf("Server: received Connect request \n");
		addr = mess->sender_id;
		sendConnack(addr);
		/*printf("%d \n",addr);
		mes=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
		mes->msg_type = CONNACK;
		mes->msg_id = counter++;
		if(call AMSend.send(addr,&packet,sizeof(my_msg_t)) == SUCCESS){
			printf("Server successfully sent connack message!");
		}*/
      }	
    return buf;
}	

  

  //************************* Read interface **********************//

  event void Read.readDone(error_t result, uint16_t data) {



	my_msg_t* mess=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));

	mess->msg_type = RESP;

	mess->msg_id = rec_id;

	mess->value = data;

	  

	dbg("radio_send", "Try to send a response to node 1 at time %s \n", sim_time_string());

	call PacketAcknowledgements.requestAck( &packet );

	if(call AMSend.send(1,&packet,sizeof(my_msg_t)) == SUCCESS){
        }



  }



}


