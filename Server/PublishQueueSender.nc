interface PublishQueueSender {
	bool command pushMessage(uint8_t topic,uint8_t qos, uint16_t value, bool needAck, uint8_t ,uint8_t senderId);
	void command startQueueTimer();
}