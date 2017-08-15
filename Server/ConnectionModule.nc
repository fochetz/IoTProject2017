interface ConnectionModule {

	event void OnNewDeviceConnected(uint8_t nodeId);
 	bool command isConnected(uint8_t nodeId);
	void command sendAck(uint8_t destinationId);	
		
}
