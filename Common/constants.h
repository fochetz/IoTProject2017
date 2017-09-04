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

#define TEMP_MASK 1
#define HUMI_MASK 2
#define LUMI_MASK 4
#define TEMP_ALLIGNMENT 0
#define HUMI_ALLIGNMENT 1
#define LUMI_ALLIGNMENT 2

enum {
	NO_TOPIC,
	TEMPERATURE,
	HUMIDITY,
	LUMINOSITY
};


#endif
