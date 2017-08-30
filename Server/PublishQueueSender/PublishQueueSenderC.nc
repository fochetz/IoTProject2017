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
	message_t messageQueue[MAXQUEUELENGHT];
	uint8_t destinationIdQueue[MAXQUEUELENGHT];
	bool needAckQueue[MAXQUEUELENGHT];
	uint8_t head=0,tail=0;
	uint8_t numberOfPacketInQueue=0;
	uint8_t packetLenght;
	message_t packet;
	
	void command PublishQueueSender.setPacketLenght(uint8_t len)
	{
		packetLenght=len;
	}
	
	bool command PublishQueueSender.pushMessage(message_t* message ,uint8_t destinationId, bool needAck)
	{
		if(numberOfPacketInQueue>=MAXQUEUELENGHT){
			return 0;//max capability of the queue reached, msg can't be added
		}
		memcpy(&messageQueue[tail],message,sizeof(message_t));
		destinationIdQueue[tail]=destinationId;
		needAckQueue[tail]=needAck;
		numberOfPacketInQueue++;tail++;
		printf("|PANC| Publish message succesfully added in queue!\n");
		if(tail==MAXQUEUELENGHT){
			tail=0;
		}
		return 1;
	}
	
	void command PublishQueueSender.startQueueTimer()
	{
		SenderTimer.startPeriodic(TIMEBETWEENMESSAGES);
	}
	event void SenderTimer.fired()
	{
		//pub_msg_t* mess;
		if(numberOfPacketInQueue>0)
		{
			/*mess=(pub_msg_t*)(call Packet.getPayload(&packet,sizeof(pub_msg_t)));
			mess->senderId = senderIdQueue[head];
			mess->topic = topicQueue[head];
			mess->data = dataQueue[head]; 
			mess->qos = qosQueue[head];
			//set acknowledgement
			if(needAckQueue[head]==1){
				call PacketAcknowledgements.requestAck( &packet );
			}*/
			memcpy(&packet,&messageQueue[head],sizeof(message_t));
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
					call PublishQueueSender.pushMessage(&messageQueue[head],destinationIdQueue[head],needAckQueue[head]);
				}
			}
		}
		else
			call PublishQueueSender.pushMessage(&messageQueue[head],destinationIdQueue[head],needAckQueue[head]);
		head++;
		if(head==MAXQUEUELENGHT) head=0;
	}
	
}

