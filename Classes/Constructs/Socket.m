//
//  Socket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "Socket.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "DataHandler.h"
#import "DataStream.h"
#import "ElapsedTime.h"


@implementation Socket

///////////////////////////////////////////////////////////////////
///   STANDARD SOCKET CLASS

-(id)CreateSocket /*SocketConnection * parent, char * buffer*/
{
	if(self = [super init])
	{
		//parent_ = parent;
		//buffer_ = buffer;
		buffer_size_ = 0 ;
	
		socket_ref_ = nil;
		status_ = SOCKET_NOT_CONNECTED_;
		error_ = 0;
	
		run_loop_source_ = nil;
	
		new_transfer_ = true;
	
		sizeBytesReceived = 0;
	
		transferData = [self constructDataHandler];
	
		verifyTimer = nil;
	}
	
	return self;
}

-(void)DeleteSocket
{
	if(verifyTimer)
	{
		[verifyTimer invalidate];
		verifyTimer = nil;
	}
	
	if(run_loop_source_)
	{
		CFRunLoopRemoveSource (CFRunLoopGetMain(), run_loop_source_, kCFRunLoopCommonModes);
	}
	
	if ( run_loop_source_ )
		CFRelease(run_loop_source_);
	CFSocketInvalidate(socket_ref_);
	CFRelease(socket_ref_);
	socket_ref_ = nil;
	
	[transferData release];
	transferData = nil;
}

-(void)ConnectSocket:(const char *) server_address Port:(int) port
{
	strcpy(server_address_, server_address);
	port_ = port;
	
	CFSocketContext cf_context;
	cf_context.version = 0;
	cf_context.info = (void *) self;
	cf_context.retain = nil;
	cf_context.release = nil;
	cf_context.copyDescription = nil;
	
	socket_ref_ = CFSocketCreate (NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP,
								  kCFSocketConnectCallBack | kCFSocketDataCallBack, SocketCallback, &cf_context );
	
 
	if( socket_ref_ )
	{
		struct sockaddr_in socket_address;
		
		socket_address.sin_family = AF_INET;
		socket_address.sin_port = htons(port);
		inet_pton(AF_INET, server_address, &socket_address.sin_addr.s_addr);

		CFDataRef cf_server_address = CFDataCreate (NULL, (const UInt8 *) &socket_address, sizeof(struct sockaddr_in));
		if(cf_server_address)
		{
			CFSocketError error = CFSocketConnectToAddress (socket_ref_, cf_server_address, -1);
			
			if(error == kCFSocketSuccess)
			{
				lastReceiveTime = [ElapsedTime LocalTimeOfDay];
				run_loop_source_ = CFSocketCreateRunLoopSource (NULL, socket_ref_, 1);
				if(run_loop_source_)
				{
					CFRunLoopAddSource (CFRunLoopGetMain(), run_loop_source_, kCFRunLoopCommonModes);
					verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(verifySocketTimer:) userInfo:nil repeats:YES];
				}
			}
			else
			{
				[self OnDisconnect:true];
			}
		
			CFRelease(cf_server_address);

		}
													
	}
}
	
													
- (void)OnConnect:(CFSocketRef) socket_ref Error:(CFSocketError) error
{
	if(error == kCFSocketSuccess)
	{
		status_ = SOCKET_OK_;
		[self Connected];
	}
}

- (void) Disconnect
{
	// Must invalidate the timer here so that the timer is not holding an instance of the socket
	if(verifyTimer)
	{
		[verifyTimer invalidate];
		verifyTimer = nil;
	}
	
	[self release];
}

- (void)OnDisconnect:(bool) atConnect
{
	status_ = SOCKET_ERROR_;
	
	[self Disconnected: atConnect];
}

- (void)OnReceive: (CFSocketRef) socket_ref Data:(CFDataRef)data
{
	// Get size of data
	CFIndex data_size = CFDataGetLength(data);
	UInt8 * byte_ptr = (UInt8 *)CFDataGetBytePtr(data);
	
	if ( data_size == 0 )
	{
		[self OnDisconnect:false];
		return;
	}
	
	lastReceiveTime = [ElapsedTime LocalTimeOfDay];
	
	while ( data_size > 0 )
	{
		if ( new_transfer_ )
		{
			int sizeBytesRequired = sizeof(int) - sizeBytesReceived;
			long sizeBytesToCopy = data_size;
			if ( sizeBytesToCopy > sizeBytesRequired )
				sizeBytesToCopy = sizeBytesRequired;
			memcpy(sizeBytes + sizeBytesReceived, byte_ptr, sizeBytesToCopy);
			sizeBytesReceived += sizeBytesToCopy;
			byte_ptr += sizeBytesToCopy;
			data_size -= sizeBytesToCopy;
			
			if ( sizeBytesReceived >= sizeof(int) )
			{
				int *long_ptr = (int *)sizeBytes;
				
				transfer_size_ = ntohl(*long_ptr++) - sizeof(int);
				transfer_size_received_ = 0;
				[transferData newTransfer:transfer_size_];
				new_transfer_ = false;
				
				sizeBytesReceived = 0;
			}
			else 
			{
				new_transfer_ = true;
				break;
			}

		}
		
		if ( !new_transfer_ )
		{
			int size_required = transfer_size_ - transfer_size_received_;
			if ( size_required > data_size )
				size_required = data_size;
			
			// memcpy ( transfer_buffer_ + transfer_size_received_, byte_ptr, size_required );
			memcpy ( [[transferData getStream] inqBuffer] + transfer_size_received_, byte_ptr, size_required );
			transfer_size_received_ += size_required;
			data_size -= size_required;
			byte_ptr += size_required;
			
			if ( transfer_size_received_ >= transfer_size_ )
			{
				[transferData handleCommand];
				new_transfer_ = true;
			}
			else
			{
				assert ( data_size == 0 );
				break;
			}

		}
	}
}

- (DataHandler *) constructDataHandler
{
	DataHandler *handler = [[DataHandler alloc] init];
	return handler;
}

- (void) Connected
{
	// Override me
}

- (void) Disconnected:(bool) atConnect
{
	// Override me
}

- (int) InqStatus
{
	return status_;
}

-(void) dealloc
{
	[self DeleteSocket];
	
    [super dealloc];
}

- (void) SendData: (CFDataRef) data
{
	if ( CFSocketIsValid(socket_ref_) )
		CFSocketSendData (socket_ref_, nil, data, 0);
}

- (void) verifySocketTimer: (NSTimer *)theTimer
{
	double timeNow = [ElapsedTime LocalTimeOfDay];
	if ( timeNow - lastReceiveTime > 10 )
		[self OnDisconnect:false];
}

@end
	

//////////////////////////////////////////////////////////////////////////////////////
// Global socket event callback

void SocketCallback ( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info )
{
	// Can't do anything useful if we don't know the socket and the owner of the socket
	if(!s || !info)
		return;
	
	Socket *owner = (Socket *)info;

	if ( CFSocketIsValid(s) )
	{		
		switch (callbackType)
		{
			case kCFSocketNoCallBack:
				break;
			case kCFSocketReadCallBack:
				break;
			case kCFSocketAcceptCallBack:
				break;
			case kCFSocketDataCallBack:
				{				
					// Pass on to owner of socket
					[owner OnReceive:s Data:data];
				}
				break;
			case kCFSocketConnectCallBack:
				{
					// Get error code from data
					CFSocketError error = (SInt32)data;
					
					// Pass on to owner of socket
					[owner OnConnect:s Error:error];
				}
				break;
			case kCFSocketWriteCallBack:
				break;
			default:
				break;
		}
	}
	else {
		[owner OnDisconnect:false];
	}

}


