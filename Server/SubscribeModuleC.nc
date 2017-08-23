#include "packets.h"

module SubscribeModuleC
{

	provides interface SubscribeModule;
	uses {
 		interface Receive as SubscribeReceive;
		interface AMSend as SubackSender;
		interface AMPacket;
		interface Packet;		
		interface PacketAcknowledgements;
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
	
	
	
	void printSubscribeVariable()
	{
		uint8_t i;
		for(i=0; i<N_NODES; i++)
		{
			printf("%d T: %d Qos: %d, H: %d Qos %d, L: %d Qos %d\n",i,subscribedTemperatureDevice[i],subscribedTemperatureDeviceQos[i], subscribedHumidityDevice[i],subscribedHumidityDeviceQos[i],subscribedLuminosityDevice[i],subscribedLuminosityDeviceQos[i]);
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
			default: printf("DEBUG: <SM> Something wrong in isSubscribe\n");
			break;
			
		}
		return 0;
	}

	void command SubscribeModule.sendSubAck(uint8_t nodeId)
	{
		simple_msg_t* mess=(simple_msg_t*)(call Packet.getPayload(&packet,sizeof(simple_msg_t)));
		mess->senderId=TOS_NODE_ID;
		if(call SubackSender.send(nodeId,&packet,sizeof(simple_msg_t)) == SUCCESS){
			printf("DEBUG: |PANC| <SM> Sent SubAck to %d\n", TOS_NODE_ID);
		}
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
		signal SubscribeModule.onNewDeviceSubscribe(nodeId,topic,qos);
		printSubscribeVariable();
	}
	
	event message_t* SubscribeReceive.receive(message_t* buf, void* payload, uint8_t len) {
		if(len!=sizeof(sub_msg_t))
		{
			printf("DEBUG: <MM> Error in Subscribe packet\n");
		}
		else
		{
			sub_msg_t* mess= (sub_msg_t*)payload;
			printf("DEBUG: <SM> Subscribe packet succesfully received\n");
			call SubscribeModule.addSubscriber(mess->senderId,mess->topics,mess->qos);
			call SubscribeModule.sendSubAck(mess->senderId);
		}
		
		return buf;
	}
	event void SubackSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			radioBusy = FALSE;
    		}
    		//radioBusy = FALSE;
	}

	bool command SubscribeModule.getQos(uint8_t nodeId,uint8_t topic)
	{
		switch(topic)
			{
				case TEMPERATURE: return subscribedTemperatureDeviceQos[nodeId-2];
				case LUMINOSITY: return subscribedLuminosityDeviceQos[nodeId-2];
				case HUMIDITY: return subscribedHumidityDeviceQos[nodeId-2];
				default: printf("DEBUG: <SM> GetQos: Topic not recognized! \n");
					 return 0;
			}
	}
}
