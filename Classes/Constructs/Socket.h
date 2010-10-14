//
//  Socket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


enum Status {
	SOCKET_NOT_CONNECTED_,
	SOCKET_OK_,
	SOCKET_ERROR_,
	SOCKET_ATTEMPTING_CONNECTION_
};

void SocketCallback ( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info );

// NOTE - NO SUPPORT IN HERE YET FOR ATTEMPTING TO RECONNECT ON FAILURE OR LOSS OF NETWORK

@interface Socket : NSObject
{
	
	CFSocketRef socket_ref_;
	int buffer_size_;
	char * buffer_;
	
	//char local_buffer_[MAX_LOCAL_BUFFER_SIZE];
	
	int status_;
	int error_;
	
	unsigned int reconnection_timer_;
	unsigned int disconnection_timer_;
	
	char server_address_[32];
	int port_;
	
	CFRunLoopSourceRef run_loop_source_;
	
	bool new_transfer_;
	UInt8 *transfer_buffer_;
	int transfer_size_; // How much we're supposed to get
	int transfer_size_received_; // How much we've got so far
	int buffer_index_; // How much we've read from our buffer
	
}


- (id)CreateSocket /*(SocketConnection * parent, char * buffer)*/;
- (void)DeleteSocket;
- (void)ConnectSocket : (char *) server_address Port:(int) port;

- (void)OnConnect:(CFSocketRef) socket_ref Error:(CFSocketError) error;
- (void)OnReceive:(CFSocketRef) socket_ref Data:(CFDataRef)data;

- (int)InqStatus;
- (void)Connected;
- (void)HandleCommand:(int)command;

- (bool) PopBool;
- (unsigned char) PopUnsignedChar;
- (int) PopInt;
- (float) PopFloat;
- (NSString *) PopString;
- (void) PopBuffer: (unsigned char *)buffer Length:(int)length;

@end
