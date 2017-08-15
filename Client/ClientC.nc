#include "client.h"

#include "Timer.h"
#include "packets.h"

#include "printf.h"



module ClientC {

	uses {

		interface ConnectionModule;
		interface Boot;
		interface AMPacket;
		interface Packet;
		interface SplitControl;
		interface Timer<TMilli> as MilliTimer;
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumRead;
		interface Read<uint16_t> as LumRead;

	}

} implementation {

	uint8_t counter=0;
	uint8_t rec_id;
	message_t packet;

  //***************** Boot interface ********************//

	event void Boot.booted() {

		dbg("boot","Application booted.\n");

		printf("|Node %d| Booted\n",TOS_NODE_ID);
	//call TempRead.read();
		call SplitControl.start();

	}

	event void ConnectionModule.OnConnackReceived() {
		
		printf("Ack received");

	}

  //***************** SplitControl interface ********************//

	event void SplitControl.startDone(error_t err){

		if(err == SUCCESS) {
			printf("|Node %d| Radio ON.\n", TOS_NODE_ID);
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
		if (call ConnectionModule.isConnected()==0)
			call ConnectionModule.sendConnect();
		else {
			call MilliTimer.stop();
		}
	}

  

  //************************* Read interface **********************//

	event void TempRead.readDone(error_t result, uint16_t data) {

		printf("Temperature read: %d \n",data);	
		call HumRead.read();

	}

	event void LumRead.readDone(error_t result, uint16_t data) {

		printf("Luminosity read: %d \n",data);
		call TempRead.read();

	}

  	event void HumRead.readDone(error_t result, uint16_t data) {

		printf("Humidity read: %d \n",data);
		call LumRead.read();

	}

}


