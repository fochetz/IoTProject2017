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
	
	bool command isSubscribe(uint8_t nodeId, uint8_t topic)
	{
		switch(topic)
		{
			case TEMP_MASK:
				return subscribedTemperatureDevice[nodeId-2];
			case LUMI_MASK:
				return subscribedLuminosityDevice[nodeId-2];
			case HUMI_MASK:
				return subscribedHumidityDevice[nodeId-2];
			default: printf("DEBUG: <SM> Something wrong in isSubscribe\n");
			break;
			
		}
		return false;
	}
	/*-------------------------------------------------------------------
		Add the subscriber to the correct list with qos
	---------------------------------------------------------------------*/
	void command addSubscriber(uinr8_t nodeId, uint8_t topic, uint8_t qos)
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
	}
	
	event message_t* SubscribeReceive.receive(message_t* buf, void* payload, uint8_t len) {
		if(len!=sizeof(sub_msg_t)
		{
			printf("DEBUG: <MM> Error in Subscribe packet\n");
		}
		else
		{
			sub_msg_t* mess= (sub_msg_t*)payload;
			printf("DEBUG: <MM> Subscribe packet succesfully received\n");
			call SubscribeModule.addSubscriber(mess->senderId,mess->topics,mess->qos);
		}
		
		return buf;
	}
	event void SubackSender.sendDone(message_t* buf,error_t err) {

		if (&packet == buf) {
      			radioBusy = FALSE;
    		}
    		//radioBusy = FALSE;
	}
}