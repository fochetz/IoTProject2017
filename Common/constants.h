#ifndef CONSTANTS_H
#define CONSTANTS_H
typedef enum {
	UNUSED,
	CONNECT_AM,
	
	SUBSCRIBE_AM,
	SUBACK_AM,
	PUBLISH_AM,

}packet_channel;


#define N_NODES 8
#define PANC_ID 1
#define TEMP_MASK 1
#define HUMI_MASK 2
#define LUMI_MASK 4
#define TEMP_ALLIGNMENT 0
#define HUMI_ALLIGNMENT 1
#define LUMI_ALLIGNMENT 2
#define MAXQUEUELENGHT N_NODES*N_NODES
#define PUBLISH_TIMER_PANC 20
#define PUBLISH_TIMER_NODE 300

#define SENSOR_TIMER 1000
#define TEMPERATURE_DELAY 10
#define HUMIDITY_DELAY 20
#define LUMINOSITY_DELAY 50

enum {
	NO_TOPIC,
	TEMPERATURE,
	HUMIDITY,
	LUMINOSITY
};

void printHeader() {
	if (TOS_NODE_ID!=PANC_ID)
		printf("|N: %d| ", TOS_NODE_ID);
	else
		printf("|PANC| ");	

}

void printDebugHeader() {
	printf("DEBUG: ");
	printHeader();
}

void printfH(const char *fmt, ...) {
	
	va_list args;
	printHeader();
	va_start(args, fmt);
	vprintf(fmt, args);
	va_end(args);

}

void printfDebug(const char *fmt, ...) {
	
	va_list args;
	printf("DEBUG: ");
	printHeader();
	va_start(args, fmt);
	vprintf(fmt, args);
	va_end(args);
	

}

void printReceivedData(uint8_t topic, uint16_t value, bool qos, uint8_t senderId) {
		
		printfH("[NODE:%d; QoS:%d] ", senderId, qos);
		switch(topic) {
			case TEMPERATURE: printf("T:"); break;			
			case HUMIDITY: printf("H:"); break;
			case LUMINOSITY: printf("L:"); break;
			default: printf("INVALIDTOPIC"); break;
		}
		printf("%d", value);

	}

void printReceivedDataNode(uint8_t topic, uint16_t value, uint8_t senderId) {

		printfH("[NODE:%d] ", senderId);
		switch(topic) {
			case TEMPERATURE: printf("T:"); break;			
			case HUMIDITY: printf("H:"); break;
			case LUMINOSITY: printf("L:"); break;
			default: printf("INVALIDTOPIC"); break;
		}
		printf("%d\n", value);

	}



#endif
