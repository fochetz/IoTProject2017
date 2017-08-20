#ifndef PACKETS_H
#define PACKETS_H

typedef nx_struct simple_msg {
	nx_uint8_t senderId;
} simple_msg_t;

typedef nx_struct sub_msg {
	nx_uint8_t senderId;
	nx_uint8_t topics;
	nx_uint8_t qos;
} sub_msg_t;



#endif
