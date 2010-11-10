//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadClientSocket.h"
#import "RacePadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "RacePadDatabase.h"
#import "MovieViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "RacePadPrefs.h"

@implementation RacePadCoordinator

@synthesize connectionType;
@synthesize currentTime;
@synthesize startTime;
@synthesize endTime;
@synthesize needsPlayRestart;
@synthesize playing;
@synthesize settingsViewController;

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
		
		needsPlayRestart = true;
		playing = false;
		
		updateTimer = nil;
		elapsedTime = nil;
		
		views = [[NSMutableArray alloc] init];
		dataSources = [[NSMutableArray alloc] init];
		
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
		
		connectionType = RPC_NO_CONNECTION_;
		
		firstView = true;
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
	[registeredViewController release];
	[sessionFolder release];
	[downloadProgress release];
	[serverConnect release];
	[WorkOffline release];
	[settingsViewController release];
    [super dealloc];
}

- (void) onStartUp
{
}

- (void) onDisplayFirstView
{
	NSNumber *ctype= [[RacePadPrefs Instance] getPref:@"connectionType"];
	if ( [ctype intValue] == RPC_SOCKET_CONNECTION_ )
	{
		NSString *address = [[RacePadPrefs Instance] getPref:@"preferredServerAddress"];
		if ( [address length] > 0 )
			[self SetServerAddress: address ShowWindow:YES];
	}
	else
		[self goOffline];
}

-(int) deviceOrientation
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
		return RPC_ORIENTATION_PORTRAIT_;
	else
		return RPC_ORIENTATION_LANDSCAPE_;	
}

-(void) setProjectRange:(int) start End:(int) end
{
	bool p = playing;
	[self pausePlay];
	
	startTime = start;
	endTime = end;
	
	if ( p )
	{
		currentTime = start;
		[self startPlay];
	}
	else
		[self jumpToTime:start];
}

////////////////////////////////////////////////////////////////////////////////////////
// Play control management
////////////////////////////////////////////////////////////////////////////////////////

-(void)startPlay
{
	if(playing)
		return;
	
	playing = true;
	needsPlayRestart = false;
	
	baseTime = (int)(currentTime * 1000.0);
	elapsedTime = [[ElapsedTime alloc] init];
	
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self setTimer:currentTime];
		
	timeControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeControllerTimerUpdate:) userInfo:nil repeats:YES];

	if(connectionType == RPC_ARCHIVE_CONNECTION_ && registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
		[(MovieViewController *)registeredViewController moviePlay];	
}

-(void)pausePlay
{
	if(!playing)
		return;
	
	if(updateTimer)
	{
		[updateTimer invalidate];
		updateTimer = nil;
	}
	
	if(timeControllerTimer)
	{
		[timeControllerTimer invalidate];
		timeControllerTimer = nil;
	}
	
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[socket_ stopStreams];	
	
	if(connectionType == RPC_ARCHIVE_CONNECTION_ && registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
		[(MovieViewController *)registeredViewController movieStop];

	currentTime = (float)baseTime * 0.001 + [elapsedTime value];
	[elapsedTime release];
	elapsedTime = nil;
	
	[[RacePadTimeController Instance] updateTime:currentTime];

	playing = false;	
}

-(void)stopPlay
{
	[self pausePlay];
	needsPlayRestart = false;
}

-(void)jumpToTime:(float)time
{
	[self stopPlay];
	currentTime = time;
	
	[self showSnapshot];
}

-(void)setConnectionType:(int)type
{
	// If there's no change, we don't need to anything
	if(connectionType == type)
		return;
	
	bool play = playing || needsPlayRestart;
	[self stopPlay];
	
	// If we're moving to archive, make the data handlers
	// If we're moving away from archive, delete them
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self DestroyDataSources];
	else if(type == RPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	connectionType = type;
	
	if ( play )
	{
		if ( connectionType == RPC_NO_CONNECTION_ )
			needsPlayRestart = true;
		else
		{
			[self prepareToPlay];
			[self startPlay];
		}
	}
	
	[settingsViewController updateConnectionType];
	[[RacePadPrefs Instance]setPref:@"connectionType" Value:[NSNumber numberWithInt: connectionType]];
}

-(void)prepareToPlay
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[self prepareToPlayFromSocket];
	else if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self prepareToPlayArchives];
}

-(void)showSnapshot
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[self showSnapshotFromSocket];
	else if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self showSnapshotOfArchives];
}

- (void) setTimer: (float)thisTime
{
	// Assume that the timer has been stopped (by stopPlay), or has fired, and has therefore invalidated itself.
	// i.e. we don't need to invalidate it here, we can just make a new one.
	
	float eventTime = 0;
	int data_source_count = [dataSources count];
	
	for ( int i = 0 ; i < data_source_count ; i++)
	{
		RPCDataSource * source = [dataSources objectAtIndex:i];
		float nextTime = [[source dataHandler] inqTime] / 1000.0;
		if ( eventTime == 0 || (nextTime != 0 && nextTime < eventTime) )
			eventTime = nextTime;
	}
	
	if ( eventTime > 0 )
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:eventTime - thisTime target:self selector:@selector(timerUpdate:) userInfo:nil repeats:NO];
}

- (void) timerUpdate: (NSTimer *)theTimer
{
	float elapsed = [elapsedTime value];
	
	int data_source_count = [dataSources count];
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] update:baseTime + elapsed * 1000];
		}
	}
	
	[self setTimer:currentTime + elapsed];
}

- (void) timeControllerTimerUpdate: (NSTimer *)theTimer
{
	float elapsed = [elapsedTime value];
	[[RacePadTimeController Instance] updateTime:currentTime + elapsed];
	[[RacePadTitleBarController Instance] updateTime:currentTime + elapsed];
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
	// Load up the prepared data sources 
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] setTime:(int)(currentTime * 1000.0)];
		}
	}
	
	// If the registered view controller is interested in video, prepare it to play
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		//[(MovieViewController *)registeredViewController movieGotoTime:currentTime];
		//[(MovieViewController *)registeredViewController moviePrepareToPlay];
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
	
	// If the registered view controller is interested in video, cue this too
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		[(MovieViewController *)registeredViewController movieGotoTime:currentTime];
	}
}

- (void) loadSession: (NSString *)event Session: (NSString *)session
{
	[self setConnectionType:RPC_NO_CONNECTION_];
	[self loadRPF: @"race_pad.rpf"];
	
	NSString *eventFile = [event stringByAppendingPathComponent:@"event.rpf"];
	[self loadRPF:eventFile];
	
	sessionFolder = [[event stringByAppendingPathComponent:session] retain];
	NSString *sessionFile = [sessionFolder stringByAppendingPathComponent:@"session.rpf"];
	[self loadRPF:sessionFile];
	
	[[RacePadPrefs Instance] setPref:@"preferredEvent" Value:event ];
	[[RacePadPrefs Instance] setPref:@"preferredSession" Value:session];
	
	[self setConnectionType:RPC_ARCHIVE_CONNECTION_];
}

-(NSString *)getVideoArchiveName
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *rootFolder = [paths objectAtIndex:0];
	NSString *folder = [rootFolder stringByAppendingPathComponent:sessionFolder];

	// Try first with m4v extension
	NSString *fileName = [folder stringByAppendingPathComponent:@"video.m4v"];
	
	// check whether it exists
	FILE * f;
	if(f = fopen ( [fileName UTF8String], "rb" ))
	{
	   fclose(f);
	   return fileName;
	}
	
	// If this fails, try with mp4 extension
	fileName = [folder stringByAppendingPathComponent:@"video.mp4"];
	if(f = fopen ( [fileName UTF8String], "rb" ))
	{
	   fclose(f);
	   return fileName;
	}
	
	// If neither is present, return nil
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////
// Socket management
////////////////////////////////////////////////////////////////////////////////////////

- (void) serverConnected:(BOOL) ok
{
	if ( ok )
	{
		[socket_ RequestEvent];
		[socket_ RequestTrackMap];
		[socket_ RequestPitWindowBase];
		[socket_ RequestDriverHelmets];
		
		[self setConnectionType:RPC_SOCKET_CONNECTION_];

		[serverConnect popDown];
	}
	else
	{
		[socket_ release];
		socket_ = nil;
		
		[self setConnectionType:RPC_NO_CONNECTION_];
		
		[serverConnect badVersion];
	}
	[settingsViewController updateServerState];
}

- (void) connectionTimeout
{
	[socket_ release];
	socket_ = nil;
	
	[self setConnectionType:RPC_NO_CONNECTION_];
	[settingsViewController updateServerState];
}

-(BOOL) serverConnected
{
	return socket_ != nil;
}

- (void) showConnecting
{
	if ( socket_ != nil
	  && connectionType != RPC_SOCKET_CONNECTION_ )
	{
		if ( serverConnect == nil )
			serverConnect = [[ServerConnect alloc] initWithNibName:@"ServerConnect" bundle:nil];
		[registeredViewController presentModalViewController:serverConnect animated:YES];
	}
}

- (void) SetServerAddress : (NSString *) server ShowWindow:(BOOL)showWindow
{
	if ( server && [server length] )
	{
		[socket_ release];
		socket_ = [[RacePadClientSocket alloc] CreateSocket];
		
		[socket_ ConnectSocket:[server UTF8String] Port:6021];
		[[RacePadPrefs Instance] setPref:@"preferredServerAddress" Value:server];

		if ( showWindow )
		{
			// Slightly delay popping up the connect window, just in case we connect really quickly
			// Which can mean that the window won't pop down
			[self performSelector:@selector(showConnecting) withObject:nil afterDelay: 0.2];
		}
	}
}


- (void) Connected
{
	[socket_ RequestVersion];
}

- (void) Disconnected
{
	[socket_ release];
	socket_ = nil;
	
	[self setConnectionType:RPC_NO_CONNECTION_];
	[self SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:YES];
	[settingsViewController updateServerState];
}

- (void) goOffline
{
	if ( workOffline == nil )
		workOffline = [[WorkOffline alloc] initWithNibName:@"WorkOffline" bundle:nil];
	[registeredViewController presentModalViewController:workOffline animated:YES];
}

-(void)prepareToPlayFromSocket
{
	[socket_ SetReferenceTime:currentTime];

	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
				{
					[socket_ StreamTimingPage];
				}
				else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
				{
					NSString * driver = [existing_view Parameter];					
					if([driver length] > 0)
					{
						[socket_ requestDriverView:driver];
					}
				}
				else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
				{
					[socket_ StreamCars];
				}
				else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
				{
					[socket_ StreamPitWindow];
				}
			}
		}
	}
}

-(void)showSnapshotFromSocket
{
	[socket_ SetReferenceTime:currentTime];
	
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
				{
					[socket_ RequestTimingPage];
				}
				else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
				{
					NSString * driver = [existing_view Parameter];					
					if([driver length] > 0)
					{
						[socket_ requestDriverView:driver];
					}
				}
				else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
				{
					[socket_ RequestCars];
				}
				else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
				{
					[socket_ RequestPitWindow];
				}
			}
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of "interested" views - used to tell the server what data to send
////////////////////////////////////////////////////////////////////////////////////////

-(void)RegisterViewController:(UIViewController *)view_controller WithTypeMask:(int)mask
{
	// If nil is passed, just release any existing one
	if(!view_controller)
	{
		[registeredViewController release];
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
		return;
	}
		
	id old_registered_view_controller = registeredViewController;
	
	registeredViewController = [view_controller retain];
	registeredViewControllerTypeMask = mask;
	
	if(old_registered_view_controller)
		[old_registered_view_controller release];
	
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
		
	if([time_controller displayed])
		[time_controller displayInViewController:view_controller Animated:false];
	
	// The first time a viewController becomes active, we can use it to display the re-connect modal dialog
	if ( firstView )
	{
		firstView = false;
		[self onDisplayFirstView];
	}
}

-(void)ReleaseViewController:(UIViewController *)view_controller
{
	if(registeredViewController == view_controller)
	{
		[registeredViewController release];
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
	}
}
	
-(void)AddView:(id)view WithParameter:(NSString *)parameter AndType:(int)type
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
		[existing_view SetDisplayed:true];

		needsPlayRestart = (needsPlayRestart || playing);
		
		if(playing)
			[self pausePlay];
		
		if (connectionType == RPC_ARCHIVE_CONNECTION_)
			[self AddDataSourceWithType:[existing_view Type] AndParameter:[existing_view Parameter]];
			
		if(needsPlayRestart)
		{
			[self prepareToPlay];
			[self startPlay];
		}
		else
		{
			[self showSnapshot];
		}
			
	}
}

-(void)SetViewHidden:(id)view
{
	// First make sure that we have this view in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view && [existing_view Displayed])
	{
		[existing_view SetDisplayed:false];
		
		// If this was the last displayed view, stop the play timers, but record the fact
		// that we are playing so that it will restart when the next view is loaded
		if(playing && [self DisplayedViewCount] <= 0)
		{
			[self stopPlay]; // This will stop the server streaming
			needsPlayRestart = true;
		}
		
		// Release the data handler
		if(connectionType == RPC_ARCHIVE_CONNECTION_)
			[self RemoveDataSourceWithType:[existing_view Type]];
	}
}

-(void)SetParameter:(NSString *)parameter ForView:(id)view
{
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		[existing_view SetParameter:parameter];
	}
}

-(void) acceptPushData:(NSString *)event Session:(NSString *)session
{
	// For now we'll always accept
	[socket_ acceptPushData:YES]; // Even if we don't want it, we should tell the server, so it can stop waiting
}

-(void) projectDownloadStarting:(NSString *) eventName SessionName:(NSString *)sessionName SizeInMB:(int) sizeInMB
{
	if ( downloadProgress == nil )
		downloadProgress = [[DownloadProgress alloc] initWithNibName:@"DownloadProgress" bundle:nil];

	if(playing)
	{
		[self stopPlay]; // This will stop the server streaming
		needsPlayRestart = true;
	}

	// Make sure we don't have any sources open - just in case we're going to overwrite them
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self DestroyDataSources];

	[downloadProgress setProject:eventName SessionName:sessionName SizeInMB:sizeInMB];
	[registeredViewController presentModalViewController:downloadProgress animated:YES];
}

-(void) projectDownloadCancelled
{
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];

	[downloadProgress dismissModalViewControllerAnimated:YES];
	
	// Dismissing the view will make the playing restart if required.
}

-(void) projectDownloadComplete
{
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	[downloadProgress dismissModalViewControllerAnimated:YES];
	
	// Dismissing the view will make the playing restart if required.
}

-(void) projectDownloadProgress:(int) sizeInMB
{
	[downloadProgress setProgress:sizeInMB];
}

-(void) cancelDownload
{
	[socket_ cancelDownload];
	// We will get a projectDownloadCancelled later
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
	
	if(registeredViewController && (registeredViewControllerTypeMask & type) > 0)
		[registeredViewController RequestRedrawForType:type];
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

-(void)AddDataSourceWithType:(int)type AndFile:(NSString *)file
{
	NSString *fileName = [sessionFolder stringByAppendingPathComponent:file];
	RacePadDataHandler * data_handler = [[RacePadDataHandler alloc] initWithPath:fileName];
	RPCDataSource * rpc_source = [[RPCDataSource alloc] initWithDataHandler:data_handler Type:type Filename:fileName];
	[dataSources addObject:rpc_source];
	[rpc_source release];
}

-(void)AddDataSourceWithType:(int)type AndParameter:(NSString *)parameter
{
	// There are no data sources for video or settings types, so ignore calls with this type
	if(type == RPC_VIDEO_VIEW_ || type == RPC_SETTINGS_VIEW_)
		return;
	
	// First make sure that this handler is not already in the list
	RPCDataSource * existing_source = [self FindDataSourceWithType:type];
	
	if(existing_source)
	{
		// If it is, just increment the reference count
		[existing_source incrementReferenceCount];
		return;
	}
	
	// Reach here if it wasn't found - so we'll add a new one
	if (type == RPC_DRIVER_LIST_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"timing.rpf"];
	}
	else if (type == RPC_LAP_LIST_VIEW_ )
	{
		if(parameter && [parameter length] > 0 )
		{
			NSString *s = @"driver_";
			s = [s stringByAppendingString:parameter];
			s = [s stringByAppendingString:@".rpf"];
			[self AddDataSourceWithType:type AndFile: s];
		}
	}
	else if (type == RPC_TRACK_MAP_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"cars.rpf"];
	}
	else if (type == RPC_LAP_COUNT_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"lap_count.rpf"];
	}
	else if (type == RPC_PIT_WINDOW_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"pit_window.rpf"];
	}
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
				[self AddDataSourceWithType:[existing_view Type] AndParameter:[existing_view Parameter]];
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
@synthesize parameter_;
@synthesize type_;
@synthesize displayed_;

-(id)initWithView:(id)view AndType:(int)type
{
	if(self = [super init])
	{
		view_ = [view retain];
		parameter_ = nil;
		type_ = type;
		displayed_ = false;
	}

	return self;
}
	   
-(id)initWithView:(id)view Parameter:(NSString *)parameter AndType:(int)type;
{
	if(self = [super init])
	{
		view_ = [view retain];
		parameter_ = [parameter retain];
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


