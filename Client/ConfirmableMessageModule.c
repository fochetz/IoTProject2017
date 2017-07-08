interface ConfirmableMessageModule {
	
	event void confirmationReceived(uint_8 id);
	//event void connectionRequestReceived(uint_8 id);
	command void sendConfirmableMessage(uint_8 destination, payload);
	
}