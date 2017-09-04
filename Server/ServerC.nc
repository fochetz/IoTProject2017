#include "packets.h"
#include "Timer.h"

#include "printf.h"



module ServerC {


	uses { 

		interface Boot;
    		interface AMPacket;
		interface Packet;
		//interface PacketAcknowledgements;
	    	interface SplitControl;
		//interface Receive as SubscriptionReceive;
		interface ConnectionModule;
		interface SubscribeModule;
		interface Receive as PublicationReceive;
		interface QueueSender;

	}



} implementation {

	event void ConnectionModule.OnNewDeviceConnected(uint8_t nodeId) {

		printf("|PANC| Node %d connected\n", nodeId);
		

	}
	
	event void SubscribeModule.onNewDeviceSubscribe(uint8_t nodeId, uint8_t topic, uint8_t qos)
	{
		if (call ConnectionModule.isConnected(nodeId)) {

			printf("|PANC| Node %d subscribed to THL: %d%d%d QOS %d%d%d\n", nodeId,(topic&TEMP_MASK)&&1, (topic&HUMI_MASK)&&1, (topic&LUMI_MASK)&&1 ,(qos&TEMP_MASK)&&1, (qos&HUMI_MASK)&&1, (qos&LUMI_MASK)&&1);
			call SubscribeModule.addSubscriber(nodeId,topic,qos);

		}
		else {
			printf("|PANC| Node %d is not connected. Ignoring SUBSCRIBE message", nodeId);
		}

		
	
	}

	//uint8_t counter=0;

	//uint8_t rec_id;

	message_t packet;
    
  //***************** Boot interface ********************//

	event void Boot.booted() {

		printf("DEBUG: Booted. TOS ID: %u\n", TOS_NODE_ID);
		call SplitControl.start();

	}	

  //***************** SplitControl interface ********************//

	event void SplitControl.startDone(error_t err){   

		if(err == SUCCESS) {
			printf("DEBUG: Radio ON.\n");
			printf("|PANC| Device ready\n");
		}
		else {
			call SplitControl.start();
		}

	}

  

	event void SplitControl.stopDone(error_t err){}


	event message_t* PublicationReceive.receive(message_t* buf, void* payload, uint8_t len) {
		
		printf("|PANC| PUBLISH received\n");
		return buf;

	}


}


