/**
 *  @author Luca Pietro Borsani
 */

#ifndef SENDACK_H
#define SENDACK_H

typedef nx_struct my_msg {
	nx_uint8_t msg_type;
	nx_uint8_t sender_id;
	nx_uint16_t msg_id;
	nx_uint16_t value;
} my_msg_t;

#define CONNECT 1
#define CONNACK 2

#define RESP 1
#define REQ 2

#define SERVER_NODE_ID 1

enum{
AM_MY_MSG = 6,
};

#endif
