#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "constants.h"

configuration ServerAppC {
}

implementation {

	components MainC, ServerC as App;
	components ActiveMessageC;
	components SerialPrintfC;
	components SerialStartC;

	components ConnectionModuleAppC;
	components SubscribeModuleAppC;
	components PublishModuleAppC;

	//components new QueueSenderAppC(PUBLISH_AM) as PublishQueueSender;
	

	//Boot interface
	App.Boot -> MainC.Boot;

	//Send and Receive interfaces
	App.ConnectionModule -> ConnectionModuleAppC;
	App.SubscribeModule -> SubscribeModuleAppC;
	App.PublishModule -> PublishModuleAppC;
	
	//App.QueueSender -> PublishQueueSender;

	//Radio Control
	App.SplitControl -> ActiveMessageC;


}

