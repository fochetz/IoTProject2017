#include "packets.h"

module SubscribeModuleC
{

	provides interface SubscribeModule;
	uses {
 		interface Receive as SubscribeReceive;
		interface AMPacket;
		interface Packet;		
		interface AMSend as SubackSender;
	}

}
implementation
{
	bool subscribedTemperatureDevice[N_NODES];
	bool subscribedTemperatureDeviceQos[N_NODES];
	bool subscribedHumidityDevice[N_NODES];
	bool subscribedHumidityDeviceQos[N_NODES];
	bool subscribedLuminosityDevice[N_NODES];
	bool subscribedLuminosityDeviceQos[N_NODES];
	bool radioBusy = 0;	
	message_t packet;
	
	void printSubscribeValueForTopic(uint8_t nodeId, uint8_t topic) {
		
		if (call SubscribeModule.isSubscribe(nodeId, topic)) {
			
			printf("%d",call SubscribeModule.getQos(nodeId, topic));			
			
		} else {
			
			printf("X");			
			
		}
		
	}
	
	void printSubscribeVariable()
	{
		
		uint8_t i;
		printfDebug("          TEM   HUM   LUM\n");
		
		
		for(i=0; i<N_NODES; i++) {
			if (call SubscribeModule.isSubscribe(i+2, TEMPERATURE) || call SubscribeModule.isSubscribe(i+2, HUMIDITY) || call SubscribeModule.isSubscribe(i+2, LUMINOSITY)) {
			printfDebug(" NODE %d:    ", i+2);
			printSubscribeValueForTopic(i+2, TEMPERATURE);
			printf("     ");
			printSubscribeValueForTopic(i+2, HUMIDITY);
			printf("     ");
			printSubscribeValueForTopic(i+2, LUMINOSITY);
			
			printf("\n");
			}			

			

		}

	}

	
		

	bool command SubscribeModule.isSubscribe(uint8_t nodeId, uint8_t topic)
	{
		switch(topic)
		{
			case TEMPERATURE:
				return subscribedTemperatureDevice[nodeId-2];
			case LUMINOSITY:
				return subscribedLuminosityDevice[nodeId-2];
			case HUMIDITY:
				return subscribedHumidityDevice[nodeId-2];
			default: printfDebug("<SM> Something wrong in isSubscribe\n");
			break;
			
		}
		return 0;
	}
	/*-------------------------------------------------------------------
		Add the subscriber to the correct list with qos
	---------------------------------------------------------------------*/
	void command SubscribeModule.addSubscriber(uint8_t nodeId, uint8_t topic, uint8_t qos)
	{

		if((topic&TEMP_MASK)==TEMP_MASK)
		{
			subscribedTemperatureDevice[nodeId-2]=1;
			if((qos&TEMP_MASK)==TEMP_MASK)
			{
				subscribedTemperatureDeviceQos[nodeId-2]=1;
			}
			else
			{
				subscribedTemperatureDeviceQos[nodeId-2]=0;
			}
		}
		if((topic&LUMI_MASK)==LUMI_MASK)
		{
			subscribedLuminosityDevice[nodeId-2]=1;
			if((qos&LUMI_MASK)==LUMI_MASK)
			{
				subscribedLuminosityDeviceQos[nodeId-2]=1;
			}
			else
			{
				subscribedLuminosityDeviceQos[nodeId-2]=0;
			}
		}
		if((topic&HUMI_MASK)==HUMI_MASK)
		{
			subscribedHumidityDevice[nodeId-2]=1;
			if((qos&HUMI_MASK)==HUMI_MASK)
			{
				subscribedHumidityDeviceQos[nodeId-2]=1;
			}
			else
			{
				subscribedHumidityDeviceQos[nodeId-2]=0;
			}
		}
		
		printSubscribeVariable();
	}
	
	event message_t* SubscribeReceive.receive(message_t* buf, void* payload, uint8_t len) {

		if(len!=sizeof(sub_msg_t)) {
			printfDebug("<SM> Error in Subscribe packet\n");
		}
		else {
			sub_msg_t* mess= (sub_msg_t*)payload;
			printfDebug("<SM> Subscribe packet succesfully received\n");
			signal SubscribeModule.OnSubscribeReceived(mess->senderId,mess->topics,mess->qos);
		}
		return buf;

	}

	bool command SubscribeModule.getQos(uint8_t nodeId,uint8_t topic)
	{

		switch(topic)
			{
				case TEMPERATURE: return subscribedTemperatureDeviceQos[nodeId-2];
				case LUMINOSITY: return subscribedLuminosityDeviceQos[nodeId-2];
				case HUMIDITY: return subscribedHumidityDeviceQos[nodeId-2];
				default: printfDebug("<SM> GetQos: Topic not recognized! \n");
					 return 0;
			}

	}

	
	void command SubscribeModule.sendSuback(uint8_t destinationId) {

		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		
		mess->senderId = TOS_NODE_ID;
		if (radioBusy == FALSE) {
 			radioBusy = TRUE;
 			if (call SubackSender.send(destinationId,&packet,sizeof(simple_msg_t)) == SUCCESS) {
				printfDebug("<SM> SUBACK sent to Node %d\n", destinationId);
			}
		}
		

	}

	event void SubackSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			radioBusy = FALSE;
    		}

	}

}
