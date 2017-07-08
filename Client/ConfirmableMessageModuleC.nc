//policy parameter defines if the message must be resent after timeout expiration
//timeout is only used for message that 



generic module ConfirmableMessageModuleC(am_id_t idMessage, am_id_t idAck) {
	
	provides interface ConfirmableMessageModule;
	
	uses {
		interface Receive as AMReceive;
		interface AMSend;
		//interface SplitControl as AMControl;
	}
	
}

implementation {
	
	bool confirmed;
	am_id_t idMessageLoc = idMessage;
	am_id_t idAckLoc = idAck;
	
	event message_t* AMReceive.receive(message_t* bufPtr,  void* payload, uint8_t len) {
		confirmed = 1;
		signal ConfirmableMessageModule.confirmationReceived(0);
	}
	
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		
	}
	
	command void ConfirmableMessageModule.sendConfirmableMessage(uint8_t destination) {
		
	}
	
	
}
