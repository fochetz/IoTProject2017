interface SubscribeModule {
	event void onNewDeviceSubscribe(uint8_t nodeId, uint8_t topic, uint8_t qos);
	bool command isSubscribe(uint8_t nodeId, uint8_t topic);
	void command addSubscriber(uint8_t nodeId, uint8_t topic, uint8_t qos);
	bool command getQos(uint8_t nodeId,uint8_t topic);
	void command sendSubAck(uint8_t nodeId);

}
