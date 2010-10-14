//
//  RacePadClientSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadClientSocket.h"
#include "RacePadCoordinator.h"
#include "RacePadDatabase.h"
#import "TrackMap.h"

@implementation RacePadClientSocket

- (void) Connected 
{
	[[RacePadCoordinator Instance] Connected];
}

- (void)HandleCommand: (int) command
{
	switch (command)
	{
		case 1:
			break;
		
		case 2:
		{
			RacePadDatabase *database = [RacePadDatabase Instance];
			NSString *string = [self PopString];
			[ database setEventName:string];
			break;
		}
		case 3: // Track Map
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map loadTrack:self];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
		case 4: 
			break;
			
		case 5: // Timing Page 1 (whole page)
		{
			
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list loadData:self];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
		case 6: // Timing Page 1 (updates)
		{
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list updateData:self];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
			
		case 7: // Track Map Cars
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map updateCars:self];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
			
		case 8:
		{
			ImageListStore *imageListStore = [[RacePadDatabase Instance] imageListStore];
			[imageListStore loadItem:self];
			break;
		}
		default:
			break;
	}
}

- (void) SimpleCommand: (int) command
{
	uint32_t int_data[2];
	int_data[0] =  htonl(8);
	int_data[1] =  htonl(command);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 2);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
}

- (void)RequestEvent
{
	[self SimpleCommand:2];
}

- (void)RequestTrackMap
{
	[self SimpleCommand:3];
}

- (void)SetReferenceTime :(float) reference_time;
{
	uint32_t int_data[3];
	int_data[0] =  htonl(12);
	int_data[1] =  htonl(4);
	float *t = (float *)int_data + 2;
	*t = reference_time;
	int_data[2] = htonl(int_data[2]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 3);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
}

- (void)RequestTimingPage
{
	[self SimpleCommand:5];
}

- (void)StreamTimingPage
{
	[self SimpleCommand:6];
}

- (void)StreamCars
{
	[self SimpleCommand:7];
}

- (void)RequestDriverHelmets
{
	[self SimpleCommand:8];
}

- (UIColor *)PopRGB
{
	unsigned char r = [self PopUnsignedChar];
	unsigned char g = [self PopUnsignedChar];
	unsigned char b = [self PopUnsignedChar];
	
	return [[[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0] autorelease];
}

- (UIColor *)PopRGBA
{
	unsigned char r = [self PopUnsignedChar];
	unsigned char g = [self PopUnsignedChar];
	unsigned char b = [self PopUnsignedChar];
	unsigned char a = [self PopUnsignedChar];
	
	return [[[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:(CGFloat)a/255.0] autorelease];
}

@end
