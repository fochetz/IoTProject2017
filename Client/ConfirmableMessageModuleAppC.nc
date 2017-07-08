configuration ConfirmableMessageModuleAppC(am_id_t idMessage, am_id_t idAck) {} {
	
	implementation {
		
		components new AMSenderC(idMessage);
		components new AMReceiverC(idAck);
		
		ConfirmableMessageModuleC.AMSend -> AMSenderC;
		ConfirmableMessageModuleC.AMReceive -> AMReceiverC;		
	}

}