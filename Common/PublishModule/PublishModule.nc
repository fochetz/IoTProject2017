interface PublishModule {

	bool command publish(uint8_t destination, uint8_t topic, uint16_t value, bool qos, uint8_t senderId);
	event void OnPublicationReceive(uint8_t topic, uint16_t value, bool qos, uint8_t senderId);	
		
}
