#include "packets.h"
#define MAXQUEUELENGHT 15
#define TIMEBETWEENMESSAGES 300

module PublishQueueSenderModuleC
{

	provides interface PublishQueueSender;
	uses {
		interface AMSend as PublishSender;
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
		nterface Timer<TMilli> as SenderTimer;
	}

}

implementation{
	uint8_t topicQueue[MAXQUEUELENGHT];
	uint8_t destinationIdQueue[MAXQUEUELENGHT];
	uint8_t senderIdQueue[MAXQUEUELENGHT];
	uint8_t qosQueue[MAXQUEUELENGHT];
	uint16_t dataQueue[MAXQUEUELENGHT];
	bool needAckQueue[MAXQUEUELENGHT];
	uint8_t head=0,tail=0;
	uint8_t numberOfPacketInQueue=0;
	message_t packet;
	
	
	
	bool command PublishQueueSender.pushMessage(uint8_t topic,uint8_t qos, uint16_t value, bool needAck, uint8_t destinationId, uint8_t senderId)
	{
		if(numberOfPacketInQueue>=MAXQUEUELENGHT){
			return 0;//max capability of the queue reached, msg can't be added
		}
		topicQueue[tail]=topic;
		qosQueue[tail]=qos;
		destinationIdQueue[tail]=destinationId;
		dataQueue[tail]=value;
		needAckQueue[tail]=needAck;
		senderIdQueue[tail]=senderId;
		numberOfPacketInQueue++;tail++;
		
		if(tail==MAXQUEUELENGHT){
			tail=0;
		}
		return 1;
	}
	
	void command startQueueTimer()
	{
		SenderTimer.startPeriodic(TIMEBETWEENMESSAGES);
	}
	event void SenderTimer.fired()
	{
		pub_msg_t* mess;
		if(numberOfPacketInQueue>0)
		{
			mess=(pub_msg_t*)(call Packet.getPayload(&packet,sizeof(pub_msg_t)));
			mess->senderId = senderIdQueue[head];
			mess->topic = topicQueue[head];
			mess->data = dataQueue[head]; 
			mess->qos = qosQueue[head];
			//set acknowledgement
			if(needAckQueue[head]==1){
				call PacketAcknowledgements.requestAck( &packet );
			}
			if(call PublishSender.send(destinationIdQueue[head]packet,sizeof(pub_msg_t)) == SUCCESS){
				printf("DEBUG: |PANC| <PMQ> Publish message sent from queue\n");
			}
			numberOfPacketInQueue--;
			//decrease numberOfPacketInQueue
		}
	}
	
	
	event void PublishSender.sendDone(message_t* buf,error_t err)
	{
		if(&packet == buf && err == SUCCESS ) {
			if(needAckQueue[head]==1){
				if(call PacketAcknowledgements.wasAcked( buf ))
				{
					printf("DEBUG: |PANC| <PMQ> Publish message, ack received\n");
				}
				else
				{
					call PublishQueueSender.pushMessage(topicQueue[head],qosQueue[head],dataQueue[head],needAckQueue[head],destinationIdQueue[head],senderIdQueue[head]);
				}
			}
		}
		else
			call PublishQueueSender.pushMessage(topicQueue[head],qosQueue[head],dataQueue[head],needAckQueue[head],destinationIdQueue[head],senderIdQueue[head]);
		head++;
		if(head==MAXQUEUELENGHT) head=0;
	}
	
}