//policy parameter defines if the message must be resent after timeout expiration
//timeout is only used for message that 



module ConfirmableMessageModuleC(am_id_t idMessage, am_id_t idAck, bool resendable) {
	
	provides interface ConfirmableMessageModule;
	
	uses {
		interface Receive as AMReceive;
		interface AMSend;
		//interface SplitControl as AMControl;
	}
	
}

implementation {
	
	bool confirmed = false;
	am_id_t idMessageLoc = idMessage;
	am_id_t idAckLoc = idAck;
	
	event message_t* AMReceive.receive(message_t* bufPtr,  void* payload, uint8_t len) {
		confirmed = true;
		signal confirmationReceived(uint_8 id);
	}
	
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
				locked = FALSE;
		}
	}
	
	command void ConfirmableMessageModule.sendConfirmableMessage(uint_8 destination, payload) {
		
	}
	
	
}