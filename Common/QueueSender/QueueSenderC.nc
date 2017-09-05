#include "packets.h"
#define MAXQUEUELENGHT 15
#define TIMEBETWEENMESSAGES 300

generic module QueueSenderC(uint8_t packetLenght)
{

	provides interface QueueSender;
	uses {
		interface AMSend as PublishSender;
		//interface AMPacket;
		//interface Packet;
		interface PacketAcknowledgements;
		interface Timer<TMilli> as SenderTimer;
	}

}

implementation{
	message_t messageQueue[MAXQUEUELENGHT];
	uint8_t destinationIdQueue[MAXQUEUELENGHT];
	bool needAckQueue[MAXQUEUELENGHT];
	uint8_t head=0,tail=0;
	uint8_t numberOfPacketInQueue=0;
	message_t packet;
	bool radioBusy=0;
	bool startedTimer=0;
	bool sentOutOfOrderPacketFlag=0;


	void sendPacketFromQueue()
	{
		uint8_t destination=destinationIdQueue[head];
		memcpy(&packet,&messageQueue[head],sizeof(message_t));
		if(call PublishSender.send(destination,&packet,packetLenght) == SUCCESS){
			printf("DEBUG: |NODE %d| <MQ> Message sent from queue\n", TOS_NODE_ID);
			//TODO: cambiare nome nodo in caso sia PANC.
			radioBusy=1;
		}
		numberOfPacketInQueue--;//decrease numberOfPacketInQueue
		sentOutOfOrderPacketFlag=0;	
	}

	//send the messages that don't require an ack and that are pushed while the radio was free

	void sendOutOfOrder(message_t* message, uint8_t destination){
		memcpy(&packet,message,sizeof(message_t));
		if(call PublishSender.send(destination,&packet,packetLenght) == SUCCESS){
			printf("DEBUG: |NODE %d| <MQ> Message sent out of order \n", TOS_NODE_ID);
		//TODO: cambiare nome nodo in caso sia PANC.
			radioBusy=1;
			sentOutOfOrderPacketFlag=1;
		}
	}

	bool command QueueSender.pushMessage(message_t* message ,uint8_t destinationId, bool needAck)
	{
		if(needAck==0 && radioBusy==0)
		{
			sendOutOfOrder(message,destinationId);
			return 1;
		}
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
		if(startedTimer==0) call QueueSender.startQueueTimer();
		//if(numberOfPacketInQueue==1 && radioBusy==0)  sendPacketFromQueue();
		return 1;
	}
	
	void command QueueSender.startQueueTimer()
	{
		call SenderTimer.startPeriodic(TIMEBETWEENMESSAGES);
		startedTimer=1;
	}
	event void SenderTimer.fired()
	{
		//pub_msg_t* mess;
		if(numberOfPacketInQueue>0 && radioBusy==0)
		{
			sendPacketFromQueue();
		}
	}
	
	
	event void PublishSender.sendDone(message_t* buf,error_t err)
	{
		if(sentOutOfOrderPacketFlag==0)
		{
			if(&packet == buf && err == SUCCESS ) {
				if(needAckQueue[head]==1){
					if(call PacketAcknowledgements.wasAcked( buf ))
					{
						printf("DEBUG: |PANC| <PMQ> Publish message, ack received\n");
					}
					else
					{
						call QueueSender.pushMessage(&messageQueue[head],destinationIdQueue[head],needAckQueue[head]);
					}
				}
			}
			else{
				call QueueSender.pushMessage(&messageQueue[head],destinationIdQueue[head],needAckQueue[head]);
			}

			head++;
			if(head==MAXQUEUELENGHT) head=0;
		}
		radioBusy=0;
	}
	
}

