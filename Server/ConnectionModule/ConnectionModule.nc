interface ConnectionModule {

	event void OnConnectReceived(uint8_t nodeId);
 	bool command isConnected(uint8_t nodeId);
	void command addConnectedDevice(uint8_t nodeId);
	void command sendConnack(uint8_t nodeId);
		
}
