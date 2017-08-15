interface ConnectionModule {

	event void OnConnackReceived();
 	bool command isConnected();
	void command sendConnect();	
		
}
