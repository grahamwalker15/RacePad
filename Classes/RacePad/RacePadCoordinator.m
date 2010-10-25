//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"
#import "RacePadClientSocket.h"
#import "RacePadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "RacePadDatabase.h"

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

- (void) loadRPF: (NSString *)file {
	RacePadDataHandler *handler = [[RacePadDataHandler alloc] initWithPath:file];
	[handler setTime:[handler inqTime]];
	[handler release];
}

- (void) playRPF: (NSString *)file {
	NSString *fileName = [sessionFolder stringByAppendingString:file];
	dataHandler = [[RacePadDataHandler alloc] initWithPath:fileName];
	[dataHandler setTime:[dataHandler inqTime] + 60 * 15 * 1000];
	baseTime = [dataHandler inqTime];
	currentTime = [[ElapsedTime alloc] init];
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
}

- (void) showRPF: (NSString *)file {
	NSString *fileName = [sessionFolder stringByAppendingString:file];
	RacePadDataHandler *handler = [[RacePadDataHandler alloc] initWithPath:fileName];
	[handler setTime:[handler inqTime]];
	[handler release];
}

- (void) loadSession: (NSString *)event Session: (NSString *)session {
	[self loadRPF: @"/race_pad.rpf"];
	
	NSString *eventFile = [event stringByAppendingString:@"/event.rpf"];
	[self loadRPF:eventFile];
	
	sessionFolder = [[event stringByAppendingString:session] retain];
	NSString *sessionFile = [event stringByAppendingString:@"/session.rpf"];
	[self loadRPF:sessionFile];
}

- (void) onStartUp {
	[self loadSession:@"/07_25Hok" Session:@"/Race"];
}

- (void) ConnectSocket
{
	// Create the socket
	socket_ = [[RacePadClientSocket alloc] CreateSocket];
}

- (void) SetServerAddress : (NSString *) server
{
	[socket_ ConnectSocket:[server UTF8String] Port:6021];
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

		// TESTING MR
		// Explicity force the DriverListView back to showing the DriverListData
		if( [existing_view Type] == RPC_DRIVER_LIST_VIEW_)
		{
			TableDataView *table_data_view = (TableDataView *)[[existing_view View] view];
			if ( table_data_view != nil )
				[table_data_view SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
		}
		// TESTING END
		
		if ( [socket_ InqStatus] == SOCKET_OK_ ) {
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
		else {
			if ( [existing_view Type] == RPC_DRIVER_LIST_VIEW_ ) {
				[self playRPF:@"/timing.rpf"];
			}
			else if ( [existing_view Type] == RPC_TRACK_MAP_VIEW_ ) {
				[self playRPF:@"/cars.rpf"];
			}
		}
	}
}

-(void) requestDriverView:(NSString *)driver {
	if ( [driver length] > 0 )
	{
		// TESTING MR
		// I set the view's data to be the DriverView,
		// It gets set back in SetViewDisplayed
		int view_count = [views_ count];
		for ( int i = 0; i < view_count; i++)
		{
			RacePadView * existing_view = [views_ objectAtIndex:i];
			if( [existing_view Type] == RPC_DRIVER_LIST_VIEW_ && [existing_view Displayed])
			{
				TableDataView *table_data_view = (TableDataView *)[[existing_view View] view];
				if ( table_data_view != nil )
					[table_data_view SetTableDataClass:[[RacePadDatabase Instance] driverData]];
				break;
			}
		}
		// TESTING END

		if ( [socket_ InqStatus] == SOCKET_OK_ ) {
			[socket_ requestDriverView:driver];
		} else {
			NSString *s1 = @"/driver_";
			NSString *s2 = [s1 stringByAppendingString:driver];
			NSString *s3 = [s2 stringByAppendingString:@".rpf"];
			[self showRPF:s3];
		}
	}
}

-(void) acceptPushData:(NSString *)event Session:(NSString *)session {
	// For now we'll always accept
	[socket_ acceptPushData:YES]; // Even if we don't want it, we should tell the server, so it can stop waiting
}

-(void)SetViewHidden:(id)view
{
	// First make sure that this view is not already in the list
	RacePadView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// If it is, just set the type
		[existing_view SetDisplayed:false];

		// Stop the repeating timer
		[updateTimer invalidate];
		updateTimer = nil;
		[currentTime release];
		currentTime = nil;
		
		// Release the data handler
		[dataHandler release];
		dataHandler = nil;
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

- (void) timerUpdate: (NSTimer *)theTimer {
	[dataHandler update:baseTime + [currentTime value] * 1000];
}

- (void)dealloc
{
	[socket_ release];
	[views_ removeAllObjects];
	[views_ release];
	[sessionFolder release];
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


