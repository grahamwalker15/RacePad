//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"
#import "RacePadClientSocket.h"


@implementation RacePadCoordinator

static RacePadCoordinator * instance_ = nil;

+(RacePadCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[RacePadCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
		views_ = [[NSMutableArray alloc] init];
	
	[self ConnectSocket];
	
	return self;
}

- (void) ConnectSocket
{
	// Create the socket
	socket_ = [[RacePadClientSocket alloc] CreateSocket];
}

- (void) SetServerAddress : (NSString *) server
{
	[socket_ ConnectSocket:[server cString] Port:6021];
}

- (void) Connected
{
	[socket_ RequestEvent];
	[socket_ SetReferenceTime:53400];
	[socket_ RequestTrackMap];
	[socket_ RequestDriverHelmets];
}

-(void)AddView:(id)view WithType:(int)type
{
	// First make sure that this view is not already in the list
	RacePadView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// If it is, just set the type
		[existing_view SetType:type];
		return;
	}
	
	// Reach here if the view wasn't found - so we'll add a new one
	RacePadView * new_view = [[RacePadView alloc] initWithView:view AndType:type];
	[views_ addObject:new_view];
	[new_view release];
}

-(void)RemoveView:(id)view
{
	int index;
	RacePadView * existing_view = [self FindView:view WithIndexReturned:&index];
	
	if(existing_view && index >= 0)
	{
		[views_ removeObjectAtIndex:index];
	}
}

-(void)SetViewDisplayed:(id)view
{
	// First make sure that this view is not already in the list
	RacePadView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// If it is, just set the type
		[existing_view SetDisplayed:true];
		
		if ( [socket_ InqStatus] == SOCKET_OK_ )
		{
			[socket_ SetReferenceTime:53400];
			if ( [existing_view Type] == RPC_DRIVER_LIST_VIEW_ )
			{
				[socket_ StreamTimingPage];
			}
			else if ( [existing_view Type] == RPC_TRACK_MAP_VIEW_ )
			{
				[socket_ StreamCars];
			}
		}
	}
}

-(void)SetViewHidden:(id)view
{
	// First make sure that this view is not already in the list
	RacePadView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// If it is, just set the type
		[existing_view SetDisplayed:false];
	}
}

-(void)RequestRedraw:(id)view
{
}

-(void)RequestRedrawType:(int)type
{
	int view_count = [views_ count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RacePadView * existing_view = [views_ objectAtIndex:i];
			if( [existing_view Type] == type && [existing_view Displayed])
			{
				[[existing_view View] RequestRedraw];
			}
		}
	}
}

-(RacePadView *)FindView:(id)view
{
	int view_count = [views_ count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RacePadView * existing_view = [views_ objectAtIndex:i];
			if([existing_view View] == view)
			{
				return existing_view;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

-(RacePadView *)FindView:(id)view WithIndexReturned:(int *)index
{
	*index = -1;
	
	int view_count = [views_ count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RacePadView * existing_view = [views_ objectAtIndex:i];
			if([existing_view View] == view)
			{
				*index = i;
				return existing_view;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

- (void)dealloc
{
	[socket_ release];
	[views_ removeAllObjects];
	[views_ release];
    [super dealloc];
}



@end

@implementation RacePadView

@synthesize view_;
@synthesize type_;
@synthesize displayed_;

-(id)initWithView:(id)view AndType:(int)type
{
	if(self = [super init])
	{
		view_ = [view retain];
		type_ = type;
		displayed_ = false;
	}

	return self;
}
	   
@end


