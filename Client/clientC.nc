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
        interface Read<uint16_t> as TempRead;
	interface Read<uint16_t> as HumRead;
	interface Read<uint16_t> as LumRead;

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
	con_msg_t* mess=(con_msg_t*)(call Packet.getPayload(&packet,sizeof(con_msg_t)));
	mess->msg_type = CONNECT;
	mess->sender_id = TOS_NODE_ID;
	if(call AMSend.send(SERVER_NODE_ID,&packet,sizeof(con_msg_t)) == SUCCESS){
		printf("Node %d: Succesfully send connect message to MQTT!\n",TOS_NODE_ID);
    }

  }
  //***************** Boot interface ********************//

  event void Boot.booted() {

	dbg("boot","Application booted.\n");

	printf("%d node Booted\n",TOS_NODE_ID);
	call TempRead.read();
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

void handle_con_message(void* payload)
{
	con_msg_t* mess = (con_msg_t*)payload;
	if ( mess->msg_type == CONNACK ) {
		printf("Client Node %d: received connack\n", TOS_NODE_ID);
		call MilliTimer.stop();
	}
	
}


  //***************************** Receive interface *****************//

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	switch(len)
	{
		case sizeof(con_msg_t):
			handle_con_message(payload);			
			break;
		default:
			printf("%d: Packet not recognized!\n",TOS_NODE_ID);
			break;
	}
    return buf;
  }

  

  //************************* Read interface **********************//

  event void TempRead.readDone(error_t result, uint16_t data)
  {
	printf("Temperature read: %d \n",data);	
	call HumRead.read();
  }
  event void LumRead.readDone(error_t result, uint16_t data)
  {
	printf("Luminosity read: %d \n",data);
	call TempRead.read();
  }
  event void HumRead.readDone(error_t result, uint16_t data)
  {
	printf("Humidity read: %d \n",data);
	call LumRead.read();
  }



}


