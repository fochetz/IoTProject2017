#include "Timer.h"
#include "packets.h"

#include "printf.h"



module ClientC {

	uses {

		interface ConnectionModule;
		interface SubscribeModule;
		interface Boot;
		interface AMPacket;
		interface Packet;
		interface SplitControl;
		interface Timer<TMilli> as MilliTimer;
		interface Timer<TMilli> as SubscribeTimer;
		interface Timer<TMilli> as SensorTimer;
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumRead;
		interface Read<uint16_t> as LumRead;
		interface PublishModule;

	}

} implementation {

	uint8_t counter=0;
	uint8_t rec_id;
	message_t packet;

  //***************** Boot interface ********************//

	event void Boot.booted() {

		dbg("boot","Application booted.\n");

		printf("DEBUG: |Node %d| Booted\n",TOS_NODE_ID);
	//call TempRead.read();
		call SplitControl.start();

	}
	event void SubscribeModule.OnSubscribeToPanc() {
		printf("|NODE %d| Subscribed to PANC\n", TOS_NODE_ID);	
		call SubscribeTimer.stop();
		printf("|NODE %d| Starting reading sensors\n",TOS_NODE_ID);
		call SensorTimer.startPeriodic(1000);
	}
	
	
	event void ConnectionModule.OnConnectedToPanc() {
		
		printf("|NODE %d| Connected to PANC\n", TOS_NODE_ID);
		call MilliTimer.stop();
		call SubscribeModule.setTopic((TOS_NODE_ID-1)%7,7);
		call SubscribeTimer.startPeriodic(1000);

	}

  //***************** SplitControl interface ********************//

	event void SplitControl.startDone(error_t err){

		if(err == SUCCESS) {
			printf("DEBUG: |Node %d| Radio ON.\n", TOS_NODE_ID);
			printf("|Node %d| Ready\n", TOS_NODE_ID);
    			call MilliTimer.startPeriodic(1000);
		}
		else {		
			call SplitControl.start();
		}

	}

	event void SplitControl.stopDone(error_t err){}

	//***************** MilliTimer interface ********************//

	event void MilliTimer.fired() {
		if (call ConnectionModule.isConnected()==0)
			call ConnectionModule.sendConnect();
	}

	event void SubscribeTimer.fired() {
		if(call SubscribeModule.isSubscribed()==0) {
			call SubscribeModule.sendSubscribe();
		}
	}

	event void SensorTimer.fired() {

		call TempRead.read();
		call LumRead.read();
		call HumRead.read();
		
	}

	bool getQOS() {

		return TRUE;		

	}
  	
	uint8_t getTopic() {
		
		return TOS_NODE_ID%4;		
		
	}

  //************************* Read interface **********************//

	event void TempRead.readDone(error_t result, uint16_t data) {

		
		printf("|NODE %d| Temp: %d\n", TOS_NODE_ID,data);

		if (getTopic()==TEMPERATURE)
			call PublishModule.publish(TEMPERATURE, data, getQOS());	


	}

	event void LumRead.readDone(error_t result, uint16_t data) {

		printf("|NODE %d| Lum: %d\n", TOS_NODE_ID,data);

		if (getTopic()==LUMINOSITY)
			call PublishModule.publish(LUMINOSITY, data, getQOS());

	}

  	event void HumRead.readDone(error_t result, uint16_t data) {

		printf("|NODE %d| Hum: %d\n", TOS_NODE_ID,data);

		if (getTopic()==HUMIDITY)
			call PublishModule.publish(HUMIDITY, data, getQOS());
		
	}

}


