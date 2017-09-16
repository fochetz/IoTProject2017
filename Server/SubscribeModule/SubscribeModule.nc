interface SubscribeModule {

	event void OnSubscribeReceived(uint8_t nodeId, uint8_t topic, uint8_t qos);
	void command sendSuback(uint8_t nodeId);
	bool command isSubscribe(uint8_t nodeId, uint8_t topic);
	void command addSubscriber(uint8_t nodeId, uint8_t topic, uint8_t qos);
	bool command getQos(uint8_t nodeId,uint8_t topic);

}
