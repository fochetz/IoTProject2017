interface SubscribeModule {

	event void OnSubscribeToPanc();
 	bool command isSubscribed();
	void command sendSubscribe();
	void command setTopic(uint8_t topics, uint8_t QOS);
		
}
