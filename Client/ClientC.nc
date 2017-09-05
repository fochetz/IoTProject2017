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
	
		call SplitControl.start();

	}

	event void PublishModule.OnPublicationReceive(uint8_t topic, uint16_t value, bool qos, uint8_t senderId) {
			
		printf("|NODE %d| ", TOS_NODE_ID);
		switch(topic) {
			case TEMPERATURE: printf("T: "); break;			
			case HUMIDITY: printf("H: "); break;
			case LUMINOSITY: printf("H: "); break;
			default: printf("NO VALID DATA: "); break;
		}
		printf("%d (NODE %d)\n", value, senderId);	
		
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

		return TOS_NODE_ID%2;		

	}
  	
	uint8_t getTopic() {
		
		return TOS_NODE_ID%4;		
		
	}



  //************************* Read interface **********************//

	event void TempRead.readDone(error_t result, uint16_t data) {

		
		

		if (getTopic()==TEMPERATURE) {
			printf("|NODE %d| T: %d\n", TOS_NODE_ID,data);
			call PublishModule.publish(PANC_ID, TEMPERATURE, data, getQOS(), TOS_NODE_ID);	
		}


	}

	event void LumRead.readDone(error_t result, uint16_t data) {


		if (getTopic()==LUMINOSITY) {			
			printf("|NODE %d| L: %d\n", TOS_NODE_ID,data);
			call PublishModule.publish(PANC_ID, LUMINOSITY, data, getQOS(), TOS_NODE_ID);
		}

	}

  	event void HumRead.readDone(error_t result, uint16_t data) {

		

		if (getTopic()==HUMIDITY) {
			printf("|NODE %d| H: %d\n", TOS_NODE_ID,data);
			call PublishModule.publish(PANC_ID, HUMIDITY, data, getQOS(), TOS_NODE_ID);
		}
		
		
	}

	

}


