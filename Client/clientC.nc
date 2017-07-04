/**

 *  Source file for implementation of module sendAckC in which

 *  the node 1 send a request to node 2 until it receives a response.

 *  The reply message contains a reading from the Fake Sensor.

 *

 *  @author Luca Pietro Borsani

 */



#include "client.h"

#include "Timer.h"

#include "printf.h"



module clientC {



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

  task void sendConnect();

  /*--------------------------------------------------------------
  TASK SEND CONNECT
  ----------------------------------------------------------------*/
  task void sendConnect()
  {
	my_msg_t* mess=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
	mess->msg_type = CONNECT;
	mess->sender_id = TOS_NODE_ID;
	mess->msg_id = counter++;
	if(call AMSend.send(SERVER_NODE_ID,&packet,sizeof(my_msg_t)) == SUCCESS){
		printf("Node %d: Succesfully send connect message to MQTT!\n",TOS_NODE_ID);
    }

  }
  //***************** Boot interface ********************//

  event void Boot.booted() {

	dbg("boot","Application booted.\n");

	printf("%d node Booted\n",TOS_NODE_ID);

	call SplitControl.start();

  }



  //***************** SplitControl interface ********************//

  event void SplitControl.startDone(error_t err){

      

    if(err == SUCCESS) {
	printf("Client Node %d, Radio ON!\n", TOS_NODE_ID);
    call MilliTimer.startPeriodic( 800 );
    }
    else
	{		
	  call SplitControl.start();
	}



  }

  

  event void SplitControl.stopDone(error_t err){}



  //***************** MilliTimer interface ********************//

  event void MilliTimer.fired() {

	post sendConnect();

  }

  



  //********************* AMSend interface ****************//

  event void AMSend.sendDone(message_t* buf,error_t err) {



    if(&packet == buf && err == SUCCESS ) {
		
		//packet successfully sent
    }



  }



  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {



	my_msg_t* mess=(my_msg_t*)payload;

	rec_id = mess->msg_id;
	if ( mess->msg_type == CONNACK ) {
		printf("Client Node %d: received connack\n", TOS_NODE_ID);
		call MilliTimer.stop();
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

		

	  dbg("radio_send", "Packet passed to lower layer successfully!\n");

	  dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );

	  dbg_clear("radio_pack","\t Source: %hhu \n ", call AMPacket.source( &packet ) );

	  dbg_clear("radio_pack","\t Destination: %hhu \n ", call AMPacket.destination( &packet ) );

	  dbg_clear("radio_pack","\t AM Type: %hhu \n ", call AMPacket.type( &packet ) );

	  dbg_clear("radio_pack","\t\t Payload \n" );

	  dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", mess->msg_type);

	  dbg_clear("radio_pack", "\t\t msg_id: %hhu \n", mess->msg_id);

	  dbg_clear("radio_pack", "\t\t value: %hhu \n", mess->value);

	  dbg_clear("radio_send", "\n ");

	  dbg_clear("radio_pack", "\n");



        }



  }



}


