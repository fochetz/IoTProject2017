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

	int counter = 0;
	uint8_t publishTopic[N_NODES+2];

	void printSubscribeData(uint8_t nodeId, uint8_t topic, uint8_t qos) {
	
		printfH("Node %d subscribed to THL: ", nodeId);
		printTopicOrQos(topic);
		printf("; QOS: ");
		printTopicOrQos(qos);	

	}

	event void PublishModule.OnPublicationReceive(uint8_t topic, uint16_t value, bool qos, uint8_t senderId) {
		
		int i;
		//printHeader();
		printReceivedData(topic, value, qos, senderId);
		printf("\n");

		if (!(call ConnectionModule.isConnected(senderId))) {
			printfDebug("Node %d is not connected. Ignoring PUBLISH.\n", senderId);			
			return;
		}

		if (publishTopic[senderId] == NO_TOPIC) {
			publishTopic[senderId] = topic;
			printfDebug("Received first PUBLISH from Node %d\n", senderId);
		}
		else {
			if (publishTopic[senderId]!=topic) {
				
				printfDebug("PUBLISH to multiple topic detected (Node %d)\n", senderId);				
				return;
			}
		}

		for(i = 1; i<=N_NODES; i++) {
			
			if (i!=TOS_NODE_ID && i!=senderId && 
			call ConnectionModule.isConnected(i) && 
			call SubscribeModule.isSubscribe(i, topic)) {
				
				if (call PublishModule.publish(i, topic, value, call SubscribeModule.getQos(i, topic), senderId)) {			
					//printHeader();
					printReceivedData(topic, value, qos, senderId);
					printf(" -> NODE %d QoS %d\n", i,call SubscribeModule.getQos(i, topic));
				}
				else {
					//printHeader();
					printReceivedData(topic, value, qos, senderId);
					printf(" -> NODE %d LOST\n", i);
				}
				
			}
						
			
		}
		counter++;
		
	}

	event void ConnectionModule.OnConnectReceived(uint8_t nodeId) {

		printfH("CONNECT received from Node %d\n", nodeId);
		call ConnectionModule.addConnectedDevice(nodeId);
		//call ConnectionModule.sendConnack(nodeId);
		

	}
	
	event void SubscribeModule.OnSubscribeReceived(uint8_t nodeId, uint8_t topic, uint8_t qos)
	{
		if (call ConnectionModule.isConnected(nodeId)) {
				
			//printfH("Node %d subscribed to THL: %d%d%d QOS %d%d%d\n", nodeId,(topic&TEMP_MASK)&&1, (topic&HUMI_MASK)&&1, (topic&LUMI_MASK)&&1 ,(qos&TEMP_MASK)&&1, (qos&HUMI_MASK)&&1, (qos&LUMI_MASK)&&1);

			printSubscribeData(nodeId, topic, qos);
			printf("\n");
			call SubscribeModule.addSubscriber(nodeId,topic,qos);
			call SubscribeModule.sendSuback(nodeId);

		}
		else {
			printfH("Node %d is not connected. Ignoring SUBSCRIBE message\n", nodeId);
		}

		
	
	}

	message_t packet;
    
  //***************** Boot interface ********************//

	event void Boot.booted() {

		printfDebug("Booted\n");
		if (TOS_NODE_ID!=PANC_ID) {
			printfH("ERROR: This ID is not reserved to PANC.\n");
			return;
		}
		call SplitControl.start();

	}	

  //***************** SplitControl interface ********************//

	event void SplitControl.startDone(error_t err){   

		if(err == SUCCESS) {
			printfDebug("Radio ON\n");
			printfH("Device ready\n");
		}
		else {
			call SplitControl.start();
		}

	}

  

	event void SplitControl.stopDone(error_t err){}




}


