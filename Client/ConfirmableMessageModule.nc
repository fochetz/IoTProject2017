interface ConfirmableMessageModule {
	
	event void confirmationReceived(uint8_t id);
	//event void connectionRequestReceived(uint_8 id);
	command void sendConfirmableMessage(uint8_t destination);
	
}
