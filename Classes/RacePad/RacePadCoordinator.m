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

@synthesize connectionType;
@synthesize currentTime;
@synthesize startTime;
@synthesize endTime;
@synthesize shouldPlay;
@synthesize playing;

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
	{
		currentTime = 14 * 3600 + 10 * 60 + 0;
		startTime = 14 * 3600 + 0 * 60 + 0;
		endTime = 16 * 3600 + 0 * 60 + 0;
		
		shouldPlay = true;
		playing = false;
		
		updateTimer = nil;
		
		views = [[NSMutableArray alloc] init];
		dataSources = [[NSMutableArray alloc] init];
		
		connectionType = RPC_ARCHIVE_CONNECTION_; //RPC_NO_CONNECTION_;
		[self ConnectSocket];
	}
	
	return self;
}

- (void)dealloc
{
	[socket_ release];
	[views removeAllObjects];
	[views release];
	[dataSources removeAllObjects];
	[dataSources release];
	[sessionFolder release];
    [super dealloc];
}

- (void) onStartUp
{
	[self loadSession:@"/09_12Mza" Session:@"/Race"];
}

////////////////////////////////////////////////////////////////////////////////////////
// Play control management
////////////////////////////////////////////////////////////////////////////////////////

-(void)startPlay
{
	if(playing)
		return;
	
	playing = true;
	
	baseTime = (int)(currentTime * 1000.0);
	elapsedTime = [[ElapsedTime alloc] init];
	
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
	
}

-(void)stopPlay
{
	if(!playing)
		return;
	
	if(updateTimer)
	{
		[updateTimer invalidate];
		updateTimer = nil;
	}
	
	currentTime = (float)baseTime * 0.001 + [elapsedTime value];
	[elapsedTime release];
	
	playing = false;
	
}

-(void)setConnectionType:(int)type
{
	// If there's no change, we don't need to anything
	if(connectionType == type)
		return;
	
	// If we're moving to archive, make the data handlers
	// If we're moving away from archive, delete them
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self DestroyDataSources];
	else if(type == RPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	connectionType = type;
}

////////////////////////////////////////////////////////////////////////////////////////
// Local archive management
////////////////////////////////////////////////////////////////////////////////////////

- (void) loadRPF: (NSString *)file
{
	// Called at the beginning to load static elements - track map, helmets etc.
	RacePadDataHandler *handler = [[RacePadDataHandler alloc] initWithPath:file];
	[handler setTime:[handler inqTime]];
	[handler release];
}

- (void) prepareToPlayArchives
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] setTime:(int)(currentTime * 1000.0)];
		}
	}
}

- (void) showSnapshotOfArchives
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] setTime:(int)(currentTime * 1000.0)];
		}
	}
}

- (void) loadSession: (NSString *)event Session: (NSString *)session
{
	[self loadRPF: @"/race_pad.rpf"];
	
	NSString *eventFile = [event stringByAppendingString:@"/event.rpf"];
	[self loadRPF:eventFile];
	
	sessionFolder = [[event stringByAppendingString:session] retain];
	NSString *sessionFile = [event stringByAppendingString:@"/session.rpf"];
	[self loadRPF:sessionFile];
}

- (void) timerUpdate: (NSTimer *)theTimer
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] update:baseTime + [elapsedTime value] * 1000];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////
// Socket management
////////////////////////////////////////////////////////////////////////////////////////

- (void) serverConnected:(BOOL) ok
{
	if ( ok )
	{
		[socket_ RequestEvent];
		[socket_ SetReferenceTime:53400];
		[socket_ RequestTrackMap];
		[socket_ RequestDriverHelmets];
		
		[self setConnectionType:RPC_SOCKET_CONNECTION_];
	}
	else
	{
		[socket_ release];
		socket_ = nil;
		
		[self setConnectionType:RPC_SOCKET_CONNECTION_];
	}
	// FIXME - would be nice to let the user know one way or the other
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
	[socket_ RequestVersion];
}

////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of "interested" views - used to tell the server what data to send
////////////////////////////////////////////////////////////////////////////////////////

-(void)AddView:(id)view WithType:(int)type
{
	// First make sure that this view is not already in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// If it is, just set the type
		[existing_view SetType:type];
		return;
	}
	
	// Reach here if the view wasn't found - so we'll add a new one
	RPCView * new_view = [[RPCView alloc] initWithView:view AndType:type];
	[views addObject:new_view];
	[new_view release];
}

-(void)RemoveView:(id)view
{
	int index;
	RPCView * existing_view = [self FindView:view WithIndexReturned:&index];
	
	if(existing_view && index >= 0)
	{
		[views removeObjectAtIndex:index];
	}
}

-(void)SetViewDisplayed:(id)view
{
	// First make sure that we have this view in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		// Get the displayed count before we start in order to check whether this is the first displayed
		int prior_displayed_count = [self DisplayedViewCount];
		
		// Now set this to displayed
		[existing_view SetDisplayed:true];

		// TESTING MR
		// Explicity force the DriverListView back to showing the DriverListData
		if( [existing_view Type] == RPC_DRIVER_LIST_VIEW_)
		{
			TableDataView *table_data_view = (TableDataView *)[existing_view View];
			if ( table_data_view != nil )
				[table_data_view SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
		}
		// TESTING END
		
		bool was_playing = playing;
		
		if(playing)
			[self stopPlay];
		
		if (connectionType == RPC_SOCKET_CONNECTION_)
		{
			[socket_ SetReferenceTime:currentTime];
			
			if ( [existing_view Type] == RPC_DRIVER_LIST_VIEW_ )
			{
				[socket_ StreamTimingPage];
			}
			else if ( [existing_view Type] == RPC_LAP_LIST_VIEW_ )
			{
				[socket_ StreamTimingPage];
			}
			else if ( [existing_view Type] == RPC_TRACK_MAP_VIEW_ )
			{
				[socket_ StreamCars];
			}
		}
		else if (connectionType == RPC_ARCHIVE_CONNECTION_)
		{
			[self AddDataSourceWithType:[existing_view Type]];
			
			if(was_playing)
				[self prepareToPlayArchives];
			else
				[self showSnapshotOfArchives];
			
		}
		
		if(was_playing || shouldPlay)
			[self startPlay];
			
	}
}

-(void)SetViewHidden:(id)view
{
	// First make sure that we have this view in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view && [existing_view Displayed])
	{
		[existing_view SetDisplayed:false];
		
		// If this was the last displayed view, stop the play timers
		if([self DisplayedViewCount] <= 0)
			[self stopPlay];
		
		// Release the data handler
		if(connectionType == RPC_ARCHIVE_CONNECTION_)
			[self RemoveDataSourceWithType:[existing_view Type]];
		
		// DON'T WE NEED TO STOP THE SERVER STREAMING HERE??
	}
}

-(void) requestDriverView:(NSString *)driver
{
	if ( [driver length] > 0 )
	{
		// TESTING MR
		// I set the view's data to be the DriverView,
		// It gets set back in SetViewDisplayed
		int view_count = [views count];
		for ( int i = 0; i < view_count; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if( [existing_view Type] == RPC_DRIVER_LIST_VIEW_ && [existing_view Displayed])
			{
				TableDataView *table_data_view = (TableDataView *)[existing_view View];
				if ( table_data_view != nil )
					[table_data_view SetTableDataClass:[[RacePadDatabase Instance] driverData]];
				break;
			}
		}
		// TESTING END
		
		if ( [socket_ InqStatus] == SOCKET_OK_ )
		{
			[socket_ requestDriverView:driver];
		}
		else
		{
			NSString *s1 = @"/driver_";
			NSString *s2 = [s1 stringByAppendingString:driver];
			NSString *s3 = [s2 stringByAppendingString:@".rpf"];
			[self showSnapshotRPF:s3];
		}
	}
}

-(void) nextDriverView:(NSString *) driver
{
}

-(void) prevDriverView:(NSString *) driver
{
}

-(void) acceptPushData:(NSString *)event Session:(NSString *)session
{
	// For now we'll always accept
	[socket_ acceptPushData:YES]; // Even if we don't want it, we should tell the server, so it can stop waiting
}

-(void)RequestRedraw:(id)view
{
}

-(void)RequestRedrawType:(int)type
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if( [existing_view Type] == type && [existing_view Displayed])
			{
				[[existing_view View] RequestRedraw];
			}
		}
	}
}

-(RPCView *)FindView:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view)
			{
				return existing_view;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

-(RPCView *)FindView:(id)view WithIndexReturned:(int *)index
{
	*index = -1;
	
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
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

-(int)DisplayedViewCount
{
	int view_count = [views count];
	
	int displayed_count = 0;
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				displayed_count++;
			}
		}
	}
	
	return displayed_count;
}

////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of data handlers for archive play
////////////////////////////////////////////////////////////////////////////////////////

-(void)AddDataSourceWithType:(int)type
{
	// First make sure that this handler is not already in the list
	RPCDataSource * existing_source = [self FindDataSourceWithType:type];
	
	if(existing_source)
	{
		// If it is, just increment the reference count
		[existing_source incrementReferenceCount];
		return;
	}
	
	// Reach here it wasn't found - so we'll add a new one
	NSString * file;
	if (type == RPC_DRIVER_LIST_VIEW_)
	{
		file = @"/timing.rpf";
	}
	else if (type == RPC_LAP_LIST_VIEW_ )
	{
		file = @"/timing.rpf";
	}
	else if (type == RPC_TRACK_MAP_VIEW_ )
	{
		file = @"/cars.rpf";
	}
	
	NSString *fileName = [sessionFolder stringByAppendingString:file];
	RacePadDataHandler * data_handler = [[RacePadDataHandler alloc] initWithPath:fileName];
	RPCDataSource * rpc_source = [[RPCDataSource alloc] initWithDataHandler:data_handler Type:type Filename:fileName];
	[dataSources addObject:rpc_source];
	[rpc_source release];
}

-(void)RemoveDataSourceWithType:(int)type
{
	int index;
	RPCDataSource * existing_source = [self FindDataSourceWithType:type WithIndexReturned:&index];
	
	if(existing_source && index >= 0)
	{
		[existing_source decrementReferenceCount];
		
		if(existing_source.referenceCount == 0)
			[dataSources removeObjectAtIndex:index];
	}
}

-(void)CreateDataSources
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				[self AddDataSourceWithType:[existing_view Type]];
			}
		}
	}
}


-(void)DestroyDataSources
{
	[dataSources removeAllObjects];
}

-(RPCDataSource *)FindDataSourceWithType:(int)type
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			if([source archiveType] == type)
			{
				return source;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

-(RPCDataSource *)FindDataSourceWithType:(int)type WithIndexReturned:(int *)index
{
	*index = -1;
	
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			if([source archiveType] == type)
			{
				*index = i;
				return source;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

@end


////////////////////////////////////////////////////////////////////////////////////////
// RPCView Class
////////////////////////////////////////////////////////////////////////////////////////

@implementation RPCView

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
	   
- (void)dealloc
{
	[view_ release];
    [super dealloc];
}

@end



////////////////////////////////////////////////////////////////////////////////////////
// RPCDataSource Class
////////////////////////////////////////////////////////////////////////////////////////

@implementation RPCDataSource

@synthesize dataHandler;
@synthesize fileName;
@synthesize archiveType;
@synthesize referenceCount;

-(id)initWithDataHandler:(RacePadDataHandler *)handler Type:(int)type Filename:(NSString *)name
{
	if(self = [super init])
	{
		dataHandler = [handler retain];
		archiveType = type;
		fileName = [name retain];
		referenceCount = 1;
	}
	
	return self;
}

- (void)dealloc
{
	[dataHandler release];
	[fileName release];
    [super dealloc];
}

-(void)incrementReferenceCount
{
	referenceCount++;
}

-(void)decrementReferenceCount
{
	referenceCount--;
}

@end


