#include "packets.h"
#include "Timer.h"

#include "printf.h"



module ServerC {


	uses { 

		interface Boot;
    		interface AMPacket;
		interface Packet;
	
	    	interface SplitControl;
		
		interface ConnectionModule;
		interface SubscribeModule;
		interface PublishModule;
		interface QueueSender;

	}



} implementation {


	event void PublishModule.OnPublicationReceive(uint8_t topic, uint16_t value, bool qos, uint8_t senderId) {
		
		int i;
		//printf("|NODE %d| Data %d\n", TOS_NODE_ID, senderId);
		printf("|NODE %d| ", TOS_NODE_ID);
		switch(topic) {
			case TEMPERATURE: printf("T: "); break;			
			case HUMIDITY: printf("H: "); break;
			case LUMINOSITY: printf("L: "); break;
			default: printf("NO DATA"); break;
		}
		printf("%d (NODE %d)\n", value, senderId);
		
		for(i = 1; i<N_NODES; i++) {
			
			if (i!=TOS_NODE_ID && i!=senderId && call ConnectionModule.isConnected(i) && call SubscribeModule.isSubscribe(i, topic)) {
				call PublishModule.publish(i, topic, value, call SubscribeModule.getQos(i, topic), senderId);
			}			
			
		}
		
	}

	event void ConnectionModule.OnNewDeviceConnected(uint8_t nodeId) {

		printf("|PANC| Node %d connected\n", nodeId);
		

	}
	
	event void SubscribeModule.OnNewDeviceSubscribe(uint8_t nodeId, uint8_t topic, uint8_t qos)
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




}


