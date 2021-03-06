//
//  Socket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//
// The quick brown fox
//
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

@class DataHandler;

@interface Socket : NSObject
{
	
	CFSocketRef socket_ref_;
	int buffer_size_;
	char * buffer_;
	
	//char local_buffer_[MAX_LOCAL_BUFFER_SIZE];
	
	int status_;
	int error_;
	
	char server_address_[32];
	int port_;
	
	CFRunLoopSourceRef run_loop_source_;
	
	NSTimer *verifyTimer;
	double lastReceiveTime;
	double dataTimeout;
	
	bool new_transfer_;
	DataHandler *transferData;
	int transfer_size_; // How much we're supposed to get
	int transfer_size_received_; // How much we've got so far
	
	// The message size
	int sizeBytesReceived;
	bool requiresTransferSize;
	unsigned char sizeBytes[4];
	
}

@property (nonatomic) double dataTimeout;
@property (nonatomic) bool requiresTransferSize;

- (void) Disconnect; // Important: call this instead of release

- (id)CreateSocket /*(SocketConnection * parent, char * buffer)*/;
- (void)DeleteSocket;
- (void)ConnectSocket : (const char *) server_address Port:(int) port;

- (void)OnConnect:(CFSocketRef) socket_ref Error:(CFSocketError) error;
- (void)OnReceive:(CFSocketRef) socket_ref Data:(CFDataRef)data;
- (void)OnDisconnect:(bool) atConnect;

- (int)InqStatus;
- (void)Connected;
- (void)Disconnected:(bool) atConnect;
- (DataHandler *) constructDataHandler;

- (void) SendData: (CFDataRef) data;
- (void) verifySocketTimer: (NSTimer *)theTimer;

@end
