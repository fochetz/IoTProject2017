interface SubscribeModule {
	event void onNewDeviceSubscribe(uint8_t nodeId, uint8_t topic, uint8_t qos);
	bool command isSubscribe(uint8_t nodeId, uint8_t topic);
	void command addSubscriber(uinr8_t nodeId, uint8_t topic, uint8_t qos);

}