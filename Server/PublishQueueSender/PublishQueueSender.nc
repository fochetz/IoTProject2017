interface PublishQueueSender{
	bool command pushMessage(message_t message ,uint8_t destinationId, bool needAck);
	void command startQueueTimer();
	void command setPacketLenght(uint8_t len);
}
