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


@implementation Socket

///////////////////////////////////////////////////////////////////
///   STANDARD SOCKET CLASS

-(id)CreateSocket /*SocketConnection * parent, char * buffer*/
{
	//parent_ = parent;
	//buffer_ = buffer;
	buffer_size_ = 0 ;
	
	socket_ref_ = nil;
	status_ = SOCKET_NOT_CONNECTED_;
	error_ = 0;
	
	run_loop_source_ = nil;
	
	reconnection_timer_ = 0;
	disconnection_timer_ = 0;
	
	new_transfer_ = true;
	
	return self;
}

-(void)DeleteSocket
{
	if(run_loop_source_)
	{
		CFRunLoopRemoveSource (CFRunLoopGetMain(), run_loop_source_, kCFRunLoopCommonModes);
	}
	
	CFRelease(run_loop_source_);
	CFRelease(socket_ref_);
	//KillReconnectTimer();
}

-(void)ConnectSocket:(char *) server_address Port:(int) port
{
	//KillReconnectTimer();
	
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
				run_loop_source_ = CFSocketCreateRunLoopSource (NULL, socket_ref_, 1);
				if(run_loop_source_)
				{
					CFRunLoopAddSource (CFRunLoopGetMain(), run_loop_source_, kCFRunLoopCommonModes);
				}
			}
		}
													
		CFRelease(cf_server_address);
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

- (void)OnReceive: (CFSocketRef) socket_ref Data:(CFDataRef)data
{
	// Get size of data
	CFIndex data_size = CFDataGetLength(data);
	UInt8 * byte_ptr = (UInt8 *)CFDataGetBytePtr(data);
	
	while ( data_size > 0 )
	{
		if ( new_transfer_ )
		{
			if ( data_size >= sizeof(int) )
			{
				int *long_ptr = (int *)byte_ptr;
				
				transfer_size_ = ntohl(*long_ptr++);
				transfer_size_received_ = 0;
				transfer_buffer_ = (UInt8 *) malloc ( sizeof (UInt8) * transfer_size_ );
				new_transfer_ = false;
			}
			else 
			{
				assert ( false );
				break;
			}

		}
		
		if ( !new_transfer_ )
		{
			int size_required = transfer_size_ - transfer_size_received_;
			if ( size_required > data_size )
				size_required = data_size;
			
			memcpy ( transfer_buffer_ + transfer_size_received_, byte_ptr, size_required );
			transfer_size_received_ += size_required;
			data_size -= size_required;
			byte_ptr += size_required;
			
			if ( transfer_size_received_ >= transfer_size_ )
			{
				buffer_index_ = 4; // to skip the size
				int command = [self PopInt];
				[self HandleCommand:command];
				free (transfer_buffer_);
				
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

- (bool)PopBool
{
	bool t = transfer_buffer_[buffer_index_] > 0;
	buffer_index_ += 1;
	
	return t;
}

- (unsigned char)PopUnsignedChar 
{
	int t = (unsigned char) transfer_buffer_[buffer_index_];
	buffer_index_ += 1;
	
	return t;
}

- (int)PopInt 
{
	int *buf = (int *)(transfer_buffer_ + buffer_index_);
	int t = ntohl ( *buf );
	buffer_index_ += sizeof ( int );
	
	return t;
}

- (float)PopFloat
{
	float *buf = (float *)(transfer_buffer_ + buffer_index_);
	unsigned int *ip = (unsigned int *)(transfer_buffer_ + buffer_index_);
	*ip = ntohl ( *ip);
	float t = ( *buf );
	buffer_index_ += sizeof ( float );
	
	return t;
}

- (NSString *)PopString
{
	int size = [self PopInt];
	char *s = malloc ( size + 1 );
	memcpy ( s, transfer_buffer_ + buffer_index_, size );
	buffer_index_ += size;
	s[size] = 0;
	NSString *t = [NSString stringWithUTF8String:s];
	free ( s );
	return t;
}

- (void) PopBuffer: (unsigned char *)buffer Length:(int)length
{
	memcpy ( buffer, transfer_buffer_ + buffer_index_, length );
	buffer_index_ += length;
}

- (void)HandleCommand : (int) command
{
	// Override me
}

- (void) Connected
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

@end
	

//////////////////////////////////////////////////////////////////////////////////////
// Global socket event callback

void SocketCallback ( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info )
{
	// Can't do anything useful if we don't know the socket and the owner of the socket
	if(!s || !info)
		return;
	
	Socket *owner = (Socket *)info;
		
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
