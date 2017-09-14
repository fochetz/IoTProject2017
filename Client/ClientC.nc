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
		interface Timer<TMilli> as ConnectionTimer;
		interface Timer<TMilli> as SubscribeTimer;
		interface Timer<TMilli> as SensorTimer;
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumRead;
		interface Read<uint16_t> as LumRead;
		interface PublishModule;

	}

} implementation {

	int counter=0;
	uint8_t rec_id;
	message_t packet;

  //***************** Boot interface ********************//


	event void Boot.booted() {

		printfDebug("Booted\n");
		if (TOS_NODE_ID==PANC_ID) {
			printfH("ERROR: This ID is reserved to PANC\n");
			return;
		}
		call SplitControl.start();

	}

	uint8_t getTopicsToSubscribe() {
		return TOS_NODE_ID%8;
	}

	uint8_t getQosToSubscribe() {
		return (TOS_NODE_ID+2)%8;
	}

	event void PublishModule.OnPublicationReceive(uint8_t topic, uint16_t value, bool qos, uint8_t senderId) {
		
		printReceivedDataNode(topic, value, senderId);	
		
	}

	event void SubscribeModule.OnSubscribeToPanc() {
		printfH("Subscribed to PANC\n");	
		call SubscribeTimer.stop();
		printfH("Starting reading sensors\n");
		call SensorTimer.startPeriodic(SENSOR_TIMER);
	}
	
	
	event void ConnectionModule.OnConnectedToPanc() {
		uint8_t qos,topic;
		topic=getTopicsToSubscribe();
		qos=getQosToSubscribe();
		printfH("Connected to PANC\n");
		call ConnectionTimer.stop();
		if (topic) {
			call SubscribeModule.setTopic(topic,qos);
			call SubscribeModule.sendSubscribe();
			call SubscribeTimer.startPeriodic(1000);
		}

	}

  //***************** SplitControl interface ********************//

	event void SplitControl.startDone(error_t err){

		if(err == SUCCESS) {
	
			printfDebug("Radio ON.\n");
			printfH("Ready\n");
			call ConnectionModule.sendConnect();
    			call MilliTimer.startPeriodic(1000);
		}
		else {		
			call SplitControl.start();
		}

	}

	event void SplitControl.stopDone(error_t err){}

	//***************** MilliTimer interface ********************//

	event void ConnectionTimer.fired() {
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
		//return 1;		

	}
  	
	uint8_t getTopic() {
		
		return TOS_NODE_ID%4;
		//return 1;		
		
	}



  //************************* Read interface **********************//

	event void TempRead.readDone(error_t result, uint16_t data) {
		

		if (getTopic()==TEMPERATURE) {
			printfH("Read n°(%d): T: %d\n", counter ,data);
			if (!(call PublishModule.publish(PANC_ID, TEMPERATURE, data, getQOS(), TOS_NODE_ID))) {
				printfH("(%d) Lost (queue full)\n", counter);
			}
			counter++;	
		}


	}

	event void LumRead.readDone(error_t result, uint16_t data) {


		if (getTopic()==LUMINOSITY) {			
			printfH("Read n°(%d) L: %d\n", counter ,data);
			if (!(call PublishModule.publish(PANC_ID, LUMINOSITY, data, getQOS(), TOS_NODE_ID))) {
				printfH("(%d) Lost (queue full)\n", counter);
			}	
			counter++;
		}

	}

  	event void HumRead.readDone(error_t result, uint16_t data) {

		

		if (getTopic()==HUMIDITY) {
			printfH("Read n°(%d) H: %d\n", counter ,data);
			if (!(call PublishModule.publish(PANC_ID, HUMIDITY, data, getQOS(), TOS_NODE_ID))) {
				printfH("(%d) Lost (queue full)\n", counter);
			}
			counter++;
		}
		
		
	}

	

}


