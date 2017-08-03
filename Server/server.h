/**
 *  @author Luca Pietro Borsani
 */

#ifndef SERVER_H
#define SERVER_H

typedef nx_struct my_msg {
	nx_uint8_t msg_type;
	nx_uint8_t sender_id;
	nx_uint16_t msg_id;
	nx_uint16_t value;
} my_msg_t;


#define CONNECT 1
#define CONNACK 2
#define SUBSCRIBE 3
#define PUBLISH 4

#define SERVER_NODE_ID 1

typedef nx_struct con_msg {
	nx_uint8_t msg_type;
	nx_uint8_t sender_id;
} con_msg_t;

#define L_TOPIC 1
#define H_TOPIC 2
#define HL_TOPIC 3
#define T_TOPIC 4
#define TL_TOPIC 5
#define TH_TOPIC 6
#define TLH_TOPIC 7

typedef nx_struct subscribe_msg {
	nx_uint8_t msg_type;
	nx_uint8_t sender_id;
	nx_uint8_t topic;
	nx_uint8_t qos;
} subscribe_msg_t;

typedef nx_struct publish_msg {
	nx_uint8_t msg_type;
	nx_uint8_t sender_id;
	nx_uint8_t qos;
	nx_uint8_t topic;
	nx_uint16_t value;
} publish_msg_t;
	
	
enum{
AM_MY_MSG = 6,
};

#endif
