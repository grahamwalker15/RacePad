//
//  MCSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MCSocket.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "BufferedDataStream.h"
#import "ElapsedTime.h"
#import "RaceMapCoordinator.h"
#import "TrackMap.h"
#import "RaceMapData.h"

@implementation MCSocket

-(id) init: (int) size
{
	if(self = [super init])
    {
		MCData = nil;
        lastFragmentIndex = 0;
    }
	
	return self;
}

- (void) dealloc
{
	[MCData release];
	[super dealloc];
}

- (void) Connected
{
	[[RaceMapCoordinator Instance] MCConnected];
}

- (void) Disconnected:(bool) atConnect
{
	[[RaceMapCoordinator Instance] MCDisconnected:atConnect];
}

- (void)processPacket
{
    // MCData should hold a correctly sized packet
    unsigned char mapID = [MCData PopUnsignedChar];
    unsigned char fragmentIndex = [MCData PopUnsignedChar];
    if ( fragmentIndex < lastFragmentIndex )
        [[RaceMapCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
    lastFragmentIndex = fragmentIndex;
    
    for ( int i = 0; i < 4; i++ )
    {
        unsigned char car = [MCData PopUnsignedChar];
        unsigned char flags = [MCData PopUnsignedChar];
        int distance = [MCData PopShort]; // This may need to be byte swapped
        bool pits = (flags &0x8) > 0;
        unsigned char type = (flags >> 4) & 0x0F;
        
        if ( type != 0 )
        {
            TrackMap *track_map = [[RaceMapData Instance] trackMap];
            [track_map updateCarFromDistance:car S:distance Pit:pits Type:type];
        }
    }
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
            transfer_size_ = 18;
            transfer_size_received_ = 0;
            [MCData release];
            MCData = [[BufferedDataStream alloc] initWithSize:transfer_size_];
            new_transfer_ = false;
            
            sizeBytesReceived = 0;
		}
		
		if ( !new_transfer_ )
		{
			int size_required = transfer_size_ - transfer_size_received_;
			if ( size_required > data_size )
				size_required = data_size;
			
			// memcpy ( transfer_buffer_ + transfer_size_received_, byte_ptr, size_required );
			memcpy ( [MCData inqBuffer] + transfer_size_received_, byte_ptr, size_required );
			transfer_size_received_ += size_required;
			data_size -= size_required;
			byte_ptr += size_required;
			
			if ( transfer_size_received_ >= transfer_size_ )
			{
				[self processPacket];
                transfer_size_received_ -= transfer_size_;
                if ( transfer_size_received_ <= 0 )
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

@end
	

