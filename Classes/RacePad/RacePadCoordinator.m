//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"
#import "RacePadMedia.h"
#import "RacePadAppDelegate.h"
#import "RacePadSponsor.h"
#import "RacePadViewController.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadClientSocket.h"
#import "RacePadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "RacePadDatabase.h"
#import "CompositeViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "RacePadPrefs.h"
#import "TabletState.h"
#import "CommentaryView.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation RacePadCoordinator

@synthesize appVersionNumber;

@synthesize connectionType;
@synthesize currentTime;
@synthesize startTime;
@synthesize endTime;
@synthesize playbackRate;
@synthesize serverTimeOffset;
@synthesize needsPlayRestart;
@synthesize playing;
@synthesize registeredViewController;
@synthesize settingsViewController;
@synthesize gameViewController;
@synthesize videoConnectionType;
@synthesize videoConnectionStatus;
@synthesize serverConnectionStatus;
@synthesize showingConnecting;
@synthesize liveMovieSeekAllowed;
@synthesize carToFollow;

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
		appVersionNumber = 1.1;
		
		currentTime = [ElapsedTime LocalTimeOfDay];
		startTime = currentTime;
		endTime = currentTime + 7200;
		
		playbackRate = 1.0;
		activePlaybackRate = 1.0;
		
		needsPlayRestart = true;
		playing = false;
		
		updateTimer = nil;
		elapsedTime = nil;
		
		views = [[NSMutableArray alloc] init];
		dataSources = [[NSMutableArray alloc] init];
		allTabs = [[NSMutableArray alloc] init];
		
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
		
		serverConnectionStatus = RPC_NO_CONNECTION_;
		connectionType = RPC_NO_CONNECTION_;
		connectionRetryCount = 0;
		connectionRetryTimer = nil;
		live = true;
		showingConnecting = false;
		
		videoConnectionStatus = RPC_NO_CONNECTION_;
		videoConnectionType = RPC_NO_CONNECTION_;
		
		firstView = true;
		
		gameViewController = nil;
		
		reconnectOnBecomeActive = false;
		playOnBecomeActive = false;
		jumpOnBecomeActive = false;
		restartTime = 0;
		
		liveMovieSeekAllowed = true;
		
		currentSponsor = [[RacePadSponsor Instance] sponsor];
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
	[sessionPrefix release];
	[downloadProgress release];
	[serverConnect release];
	[WorkOffline release];
	[settingsViewController release];
	[gameViewController release];
	[allTabs release];
    [super dealloc];
}

- (void) onStartUp
{
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	if ( tabControl )
	{
		NSArray	*tabs = [tabControl viewControllers];
		for ( int i = 0; i < [tabs count]; i++ )
			[allTabs addObject:[tabs objectAtIndex:i]];
	}
	
	[self updateSponsor];
}

- (void) onDisplayFirstView
{
	[self goOffline];
}

- (void) updateTabs
{
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if ( tabControl )
	{
		unsigned char i;
		NSMutableArray *tabs = [[NSMutableArray alloc] init];
		for ( i = 0; i < RPS_ALL_TABS_; i++ )
		{
			bool supported = [[RacePadSponsor Instance]supportsTab:i];
			if ( supported && i == RPS_VIDEO_TAB_ )
			{
				NSNumber *v = [[RacePadPrefs Instance] getPref:@"supportVideo"];
				if ( v )
					supported = [v boolValue];
			}
			if ( supported )
				[tabs addObject:[allTabs objectAtIndex:i]];
		}
		[tabControl setViewControllers:tabs animated:YES];
	}
}

- (void) selectTab:(int)index
{
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if(tabControl)
	{
		NSArray * controllers = [tabControl viewControllers];
		
		if(controllers)
		{
			if(index < [controllers count])
				[tabControl setSelectedIndex:index];
		}
	}
}

-(int) tabCount
{
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if(tabControl)
	{
		NSArray * controllers = [tabControl viewControllers];
		
		if(controllers)
		{
			return [controllers count];
		}
	}
	
	return 0;	
}

-(NSString *)tabTitle:(int)index
{
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if(tabControl)
	{
		UITabBar *tabBar = [tabControl tabBar];
		
		if(tabBar)
		{
			NSArray * tabBarItems = [tabBar items];
			
			if(index < [tabBarItems count])
				return [[tabBarItems objectAtIndex:index] title];
		}
	}
	
	return @"";	
}

- (void) updateSponsor
{
	[self updateTabs];
	[[RacePadTitleBarController Instance] updateSponsor];
	[settingsViewController updateSponsor];
	
	// Go to first Tab if we've changed the sponsor
	if ( currentSponsor != [[RacePadSponsor Instance] sponsor] )
	{
		currentSponsor = [[RacePadSponsor Instance] sponsor];
		RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
		UITabBarController *tabControl = [app tabBarController];
		if ( tabControl )
		{
			NSArray *tabs = [tabControl viewControllers];
			if ( [tabs count] )
				[tabControl setSelectedViewController:[tabs objectAtIndex:0]];
		}
	}
}

-(int) deviceOrientation
{
	if(registeredViewController)
	{
		CGRect bounds = [[registeredViewController view] bounds];
		if(bounds.size.width < bounds.size.height)
			return UI_ORIENTATION_PORTRAIT_;
		else
			return UI_ORIENTATION_LANDSCAPE_;	
	}
	else
	{
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		
		if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
			return UI_ORIENTATION_PORTRAIT_;
		else
			return UI_ORIENTATION_LANDSCAPE_;	
	}
}

-(void) setProjectRange:(int) start End:(int) end
{
	bool wasPlaying = playing;
	[self pausePlay];
	
	startTime = start;
	endTime = end;
	
	if (wasPlaying)
	{
		if ( restartTime != 0 )
			currentTime = restartTime;
		else
			currentTime = start;
		
		[self prepareToPlay];
		[self startPlay];
	}
	else
	{
		if ( restartTime != 0 )
			[self jumpToTime:restartTime];
		else
			[self jumpToTime:start];
		
	}
	
	restartTime= 0;
}

-(void) setLiveTime:(float) time
{
	if ( live && time > 0.0)
		currentTime = time;
}

-(float) liveTime
{
	float ourTime = (float)[ElapsedTime LocalTimeOfDay];
	return ourTime + serverTimeOffset;
}

-(void) synchroniseTime:(float) time
{
	float ourTime = (float)[ElapsedTime LocalTimeOfDay]; 
	
	serverTimeOffset = time - ourTime;	// Add to our local time to get server time
										// Subtract from server time to get our time
}

-(float) playTime
{
	if(playing)
	{
		if (live)
			return [self liveTime];
		else
			return (float)baseTime * 0.001 + [elapsedTime value] * activePlaybackRate;
	}
	else
	{
		return currentTime;
	}
}

-(void) clearStaticData
{
	[[RacePadDatabase Instance] clearStaticData];
	[self updatePrediction];
}

-(void) updateDriverNames
{
}

-(void) updatePrediction
{
	if ( gameViewController )
		[gameViewController updatePrediction];
}


////////////////////////////////////////////////////////////////////////////////////////
// Play control management
////////////////////////////////////////////////////////////////////////////////////////

-(void)startPlay
{
	if(playing && playbackRate == activePlaybackRate)
		return;
	
	if(playing)					// Change of play rate
		[self pausePlay];;
	
	playing = true;
	needsPlayRestart = false;
	
	activePlaybackRate = playbackRate;
	
	if(live)
		baseTime = (int)([self liveTime] * 1000.0);
	else
		baseTime = (int)(currentTime * 1000.0);
	
	elapsedTime = [[ElapsedTime alloc] init];
	
	if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self setTimer:currentTime];
		
	timeControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeControllerTimerUpdate:) userInfo:nil repeats:YES];

	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
		[[RacePadMedia Instance] moviePlayAtRate:activePlaybackRate];
}

-(void)pausePlay
{
	if(!playing)
		return;
	
	float elapsed = [elapsedTime value];
	currentTime = (float)baseTime * 0.001 + elapsed * activePlaybackRate;
	[elapsedTime release];
	elapsedTime = nil;

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
	
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
		[[RacePadMedia Instance] movieStop];
	
	[[RacePadTimeController Instance] updateTime:currentTime];

	playing = false;

}

-(void)stopPlay
{
	[self pausePlay];
	needsPlayRestart = false;
	activePlaybackRate = playbackRate = 1.0;
}

-(void) userPause
{
	live = false;
	[self stopPlay];
	[settingsViewController updateConnectionType];
}

-(void)jumpToTime:(float)time
{
	[self stopPlay];
	
	[[RacePadMedia Instance] setMoviePausedInPlace:false];
	
	currentTime = time;
	live = false;
	
	[[RacePadTimeController Instance] updatePlayButtons];
	[self showSnapshot];
}

-(bool)playingRealTime
{
	return (playing && activePlaybackRate > 0.99 && activePlaybackRate < 1.01);
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
			[[RacePadTimeController Instance] updatePlayButtons];
		}
	}
	
	[settingsViewController updateConnectionType];
	[[RacePadPrefs Instance]setPref:@"connectionType" Value:[NSNumber numberWithInt: connectionType]];
	[[RacePadPrefs Instance] save];
}

- (bool) liveMode
{
	return live;
}

- (void) goLive:(bool)newMode
{
	[self stopPlay];
	
	live = newMode;
	
	if ( live  )
	{
/*
		if ( connectionType == RPC_NO_CONNECTION_ )
		{
			needsPlayRestart = true;
		}
		else if ( connectionType == RPC_SOCKET_CONNECTION_ )
 */
		{
			[self prepareToPlay];
			[self startPlay];
			[[RacePadTimeController Instance] updatePlayButtons];
		}
	}
}

-(void)prepareToPlay
{
	if ( restartTime != 0 )
	{
		currentTime = restartTime;
		restartTime = 0;
	}
	
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[self prepareToPlayFromSocket];
	else if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self prepareToPlayArchives];
	else
		[self prepareToPlayUnconnected];
}

-(void)showSnapshot
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[self showSnapshotFromSocket];
	else if(connectionType == RPC_ARCHIVE_CONNECTION_)
		[self showSnapshotOfArchives];
	else
		[self showSnapshotUnconnected];
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
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:((eventTime - thisTime) / activePlaybackRate) target:self selector:@selector(timerUpdate:) userInfo:nil repeats:NO];
	else
		updateTimer = nil;

}

- (void) timerUpdate: (NSTimer *)theTimer
{
	float elapsed = [elapsedTime value]  * activePlaybackRate;
	
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			RPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] update:baseTime + elapsed * 1000];
		}
	}
	
	if ( playing )
		[self setTimer:currentTime + elapsed];
}

-(void) redrawCommentary
{
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_COMMENTARY_VIEW_) > 0)
	{
		int view_count = [views count];
		
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				int type = [existing_view Type];
				
				if(type == RPC_COMMENTARY_VIEW_)
				{
					CommentaryView *commentary = [existing_view View];
					if ( commentary )
						[commentary drawIfChanged];
				}
			}
		}
	}
}

- (void) timeControllerTimerUpdate: (NSTimer *)theTimer
{
	float elapsed = [elapsedTime value] * activePlaybackRate;
	[[RacePadTimeController Instance] updateTime:currentTime + elapsed];
	[[RacePadTitleBarController Instance] updateTime:currentTime + elapsed];
	
	[self redrawCommentary];
}

////////////////////////////////////////////////////////////////////////////////////////
// Local archive management
////////////////////////////////////////////////////////////////////////////////////////

- (void) loadRPF: (NSString *)file SubIndex: (NSString *)subIndex
{
	// Called at the beginning to load static elements - track map, helmets etc.
	NSString *fileName = [sessionPrefix stringByAppendingString:file];
	RacePadDataHandler *handler = [[RacePadDataHandler alloc] initWithPath:fileName SubIndex:subIndex];
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
		[[RacePadMedia Instance] movieGotoTime:currentTime];
		[[RacePadMedia Instance] moviePrepareToPlay];
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
		[[RacePadMedia Instance] movieGotoTime:currentTime];
	}
	
	[self redrawCommentary];
}

- (void) loadSession: (NSString *)event Session: (NSString *)session
{
	[self goLive:false];
	
	[self disconnect];
	[self clearStaticData];
	sessionPrefix = [NSString stringWithString:event];
	sessionPrefix = [sessionPrefix stringByAppendingString:@"-"];
	sessionPrefix = [sessionPrefix stringByAppendingString:session];
	sessionPrefix = [sessionPrefix stringByAppendingString:@"-"];
	[sessionPrefix retain];
	[self loadRPF: @"race_pad.rpf" SubIndex:nil];
	[self loadRPF: @"event.rpf" SubIndex:nil];
	[self loadRPF: @"session.rpf" SubIndex:nil];
	
	[[RacePadPrefs Instance] setPref:@"preferredEvent" Value:event ];
	[[RacePadPrefs Instance] setPref:@"preferredSession" Value:session];
	
	[self setConnectionType:RPC_ARCHIVE_CONNECTION_];
}

-(NSString *)getVideoArchiveName
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *name = [sessionPrefix stringByAppendingString:@"video.m4v"];

	// Try first with m4v extension
	NSString *fileName = [folder stringByAppendingPathComponent:name];
	
	// check whether it exists
	FILE * f;
	if(f = fopen ( [fileName UTF8String], "rb" ))
	{
	   fclose(f);
	   return fileName;
	}
	
	// If this fails, try with mp4 extension
	name = [sessionPrefix stringByAppendingString:@"video.mp4"];
	fileName = [folder stringByAppendingPathComponent:name];
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

- (void) setServerConnected:(bool) ok
{
	if ( ok )
	{
		[socket_ SynchroniseTime];
		[socket_ RequestEvent];
		[socket_ RequestTrackMap];
		[socket_ RequestPitWindowBase];
		[socket_ RequestUIImages];
		
		live = (restartTime == 0);
		double savedTime = restartTime;
		
		[self setConnectionType:RPC_SOCKET_CONNECTION_];
		restartTime = savedTime; // setConnectionType will have set it to 0, and SetProjectRange will need to see it.
		
		[self requestPrediction:[[[RacePadDatabase Instance] racePrediction] user]];

		showingConnecting = false;
		[serverConnect popDown];
	}
	else
	{
		[socket_ release];
		socket_ = nil;
		
		[self setConnectionType:RPC_NO_CONNECTION_];
		
		restartTime = 0;
		
		[serverConnect badVersion];
	}
	
	[settingsViewController updateServerState];
}

- (void) retryConnection:(NSTimer *)timer
{
	if(connectionRetryCount < 10)
	{
		connectionRetryCount++;
		[self SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:NO];
	}
	else
	{
		connectionRetryCount = 0;
		[serverConnect connectionTimeout];
	}

}

- (void) connectionTimeout
{
	[socket_ release];
	socket_ = nil;
	
	[self setConnectionType:RPC_NO_CONNECTION_];
	
	restartTime = 0;
	
	[settingsViewController updateServerState];
}

-(bool) serverConnected
{
	return socket_ != nil;
}

- (void) showConnecting
{
	if ( socket_ != nil
	  && connectionType != RPC_SOCKET_CONNECTION_
	  && !showingConnecting )
	{
		if ( serverConnect == nil )
			serverConnect = [[ServerConnect alloc] initWithNibName:@"ServerConnect" bundle:nil];
		showingConnecting = true;
		[registeredViewController presentModalViewController:serverConnect animated:YES];
	}
}

- (void) SetServerAddress : (NSString *) server ShowWindow:(BOOL)showWindow
{
	if ( server && [server length] )
	{
		[socket_ release];
		socket_ = [[RacePadClientSocket alloc] CreateSocket];
		
		connectionType = RPC_NO_CONNECTION_;
		
		[socket_ ConnectSocket:[server UTF8String] Port:6021];
		[[RacePadPrefs Instance] setPref:@"preferredServerAddress" Value:server];
		[[RacePadPrefs Instance] save];
		[self clearStaticData];
		
		if ( showWindow )
		{
			// Slightly delay popping up the connect window, just in case we connect really quickly
			[self performSelector:@selector(showConnecting) withObject:nil afterDelay: 0.5];
		}
	}
}

- (void) SetVideoServerAddress : (NSString *) server
{
	if ( server && [server length] )
	{		
		[[RacePadPrefs Instance] setPref:@"preferredVideoServerAddress" Value:server];
		[[RacePadPrefs Instance] save];
	}
}

- (void) disconnect 
{
	[self setConnectionType: RPC_NO_CONNECTION_];

	[socket_ release];
	socket_ = nil;
}

- (void) Connected
{
	[socket_ RequestVersion];
}

- (void) Disconnected: (bool) atConnect
{
	// If failed at connect (because WiFi is switched off say), then the connect window will already be up
	// So, let timer do it do it's thing
	if ( !atConnect)
	{
		[socket_ release];
		socket_ = nil;
		
		[self setConnectionType:RPC_NO_CONNECTION_];
		[self SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:YES];
		[settingsViewController updateServerState];
	}
}

- (void) goOffline
{
	if ( workOffline == nil )
		workOffline = [[WorkOffline alloc] initWithNibName:@"WorkOffline" bundle:nil];
	[registeredViewController presentModalViewController:workOffline animated:YES];
}

- (void) videoServerOnConnectionChange
{
	[settingsViewController updateServerState];
}

- (void) userExit
{
	[[UIApplication sharedApplication] terminateWithSuccess];
}

- (void) userRestart
{
	[self disconnect];
	[self goOffline];
	
}

-(void) restartCommentary
{
	int view_count = [views count];

	for ( int i = 0 ; i < view_count ; i++)
	{
		RPCView * existing_view = [views objectAtIndex:i];
		if([existing_view Displayed])
		{
			int type = [existing_view Type];
			
			if(type == RPC_COMMENTARY_VIEW_)
			{
				NSString * driver = [[[RacePadDatabase Instance] commentary] commentaryFor];
				if ( driver == nil )
					driver = @"RACE";
				[[[RacePadDatabase Instance] commentary] clearAll];
				
				if (connectionType == RPC_SOCKET_CONNECTION_)
					[socket_ StreamCommentary:driver];
				else
					[self loadRPF:@"commentary.rpf" SubIndex:driver];
				[[existing_view View] RequestRedraw];
			}
		}
	}	
}

-(void)prepareToPlayFromSocket
{
	if ( live )
	{
		playbackRate = 1.0;
		[socket_ goLive];
	}
	else
	{
		[socket_ SetPlaybackRate:playbackRate];
		[socket_ SetReferenceTime:currentTime];
	}
	
	int view_count = [views count];
	
	if(view_count > 0)
	{
		// We keep a mask of streams already started so that none get started twice
		int stream_mask = 0;
		
		for ( int i = 0 ; i < view_count ; i++)
		{
			RPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				int type = [existing_view Type];
				
				// Check it hasn't already started
				if((stream_mask & type) > 0)
					continue;
				
				// Otherwise we can start it
				
				stream_mask = (stream_mask | type);
				
				if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
				{
					[socket_ StreamTimingPage];
				}
				else if([existing_view Type] == RPC_LEADER_BOARD_VIEW_)
				{
					[socket_ StreamLeaderBoard];
				}
				else if([existing_view Type] == RPC_GAME_VIEW_)
				{
					[socket_ StreamGameView];
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
				else if([existing_view Type] == RPC_TRACK_PROFILE_VIEW_)
				{
					[socket_ StreamTrackProfile];
				}
				else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
				{
					[socket_ StreamPitWindow];
				}
				else if([existing_view Type] == RPC_TELEMETRY_VIEW_)
				{
					[socket_ StreamTelemetry];
				}
				else if([existing_view Type] == RPC_DRIVER_GAP_INFO_VIEW_)
				{
					[socket_ StreamDriverGapInfo:[[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
				}
			}
		}
	}
	
	// If the registered view controller is interested in video, cue this to play live too
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		if ( live )
			[[RacePadMedia Instance] movieGoLive];
		else
			[[RacePadMedia Instance] movieGotoTime:currentTime];
	}
	
	
}

-(void)showSnapshotFromSocket
{
	[socket_ SetPlaybackRate:playbackRate];
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
				else if([existing_view Type] == RPC_LEADER_BOARD_VIEW_)
				{
					[socket_ RequestLeaderBoard];
				}
				else if([existing_view Type] == RPC_GAME_VIEW_)
				{
					[socket_ RequestGameView];
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
				else if([existing_view Type] == RPC_TRACK_PROFILE_VIEW_)
				{
					[socket_ RequestTrackProfile];
				}
				else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
				{
					[socket_ RequestPitWindow];
				}
				else if([existing_view Type] == RPC_TELEMETRY_VIEW_)
				{
					[socket_ RequestTelemetry];
				}
				else if([existing_view Type] == RPC_DRIVER_GAP_INFO_VIEW_)
				{
					[socket_ RequestDriverGapInfo:[[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
				}
			}
		}
	}
	
	// If the registered view controller is interested in video, cue this too
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		if(liveMovieSeekAllowed)
			[[RacePadMedia Instance] movieGotoTime:currentTime];
	}
	
}

-(void)prepareToPlayUnconnected
{
	if ( live )
		playbackRate = 1.0;
	
	// If the registered view controller is interested in video, cue this to play
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		if ( live )
			[[RacePadMedia Instance] movieGoLive];
		else
			[[RacePadMedia Instance] movieGotoTime:currentTime];
	}
}

-(void)showSnapshotUnconnected
{
	// If the registered view controller is interested in video, cue this
	if(registeredViewController && (registeredViewControllerTypeMask & RPC_VIDEO_VIEW_) > 0)
	{
		if(liveMovieSeekAllowed)
			[[RacePadMedia Instance] movieGotoTime:currentTime];
	}
}


////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of "interested" views - used to tell the server what data to send
////////////////////////////////////////////////////////////////////////////////////////

-(void)RegisterViewController:(RacePadViewController *)view_controller WithTypeMask:(int)mask
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
		if ( [view_controller wantTimeControls] )
			[time_controller displayInViewController:view_controller Animated:false];
		else
			[time_controller setDisplayed:NO];

	
	// The first time a viewController becomes active, we can use it to display the re-connect modal dialog
	if ( firstView )
	{
		firstView = false;
		[self onDisplayFirstView];
	}
}

-(void)ReleaseViewController:(RacePadViewController *)view_controller
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
		[existing_view SetRefreshEnabled:true];

		needsPlayRestart = (needsPlayRestart || playing);
		
		if(playing)
			[self pausePlay];
		
		if (connectionType == RPC_ARCHIVE_CONNECTION_)
			[self AddDataSourceWithType:[existing_view Type] AndParameter:[existing_view Parameter]];
			
		if(needsPlayRestart)
		{
			[self prepareToPlay];
			[self startPlay];
			[[RacePadTimeController Instance] updatePlayButtons];
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

-(void)EnableViewRefresh:(id)view
{
	// First make sure that we have this view in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		[existing_view SetRefreshEnabled:true];
	}
}

-(void)DisableViewRefresh:(id)view
{
	// First make sure that we have this view in the list
	RPCView * existing_view = [self FindView:view];
	
	if(existing_view)
	{
		[existing_view SetRefreshEnabled:false];
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

-(void) acceptPushData:session
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
	
	if ( registeredViewControllerTypeMask & RPC_SETTINGS_VIEW_ )
	{
		[settingsViewController updateEvents];
	}
	
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

			if( [existing_view Type] == type && [existing_view Displayed] && [existing_view RefreshEnabled])
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

-(void)AddDataSourceWithType:(int)type AndFile:(NSString *)file AndSubIndex:(NSString *)subIndex
{
	NSString *fileName = [sessionPrefix stringByAppendingString:file];
	RacePadDataHandler * data_handler = [[RacePadDataHandler alloc] initWithPath:fileName SubIndex:subIndex];
	RPCDataSource * rpc_source = [[RPCDataSource alloc] initWithDataHandler:data_handler Type:type Filename:fileName];
	[dataSources addObject:rpc_source];
	[rpc_source release];
}

-(void)AddDataSourceWithType:(int)type AndFile:(NSString *)file
{
	[self AddDataSourceWithType:type AndFile:file AndSubIndex:nil];
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
	else if (type == RPC_LEADER_BOARD_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"leader.rpf"];
	}
	else if (type == RPC_LAP_LIST_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"drivers.rpf" AndSubIndex:parameter];
	}
	else if (type == RPC_TRACK_MAP_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"cars.rpf"];
	}
	else if (type == RPC_TRACK_PROFILE_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"track_profile.rpf"];
	}
	else if (type == RPC_LAP_COUNT_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"lap_count.rpf"];
	}
	else if (type == RPC_PIT_WINDOW_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"pit_window.rpf"];
	}
	else if (type == RPC_TELEMETRY_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"telemetry.rpf"];
	}
	else if (type == RPC_GAME_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"game.rpf"];
	}
	else if (type == RPC_DRIVER_GAP_INFO_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"driver_gap.rpf" AndSubIndex: [[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
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

-(void) sendPrediction
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[socket_ sendPrediction];
}

-(void) checkUserName: (NSString *)name
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[socket_ checkUserName:name];
	else
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *folder = [paths objectAtIndex:0];
		NSString *fName = sessionPrefix;
		fName = [fName stringByAppendingString:@"player_"];
		fName = [fName stringByAppendingString:name];
		fName = [fName stringByAppendingString:@".rpf"];
		NSString *competitorFile = [folder stringByAppendingPathComponent:fName];
		NSFileManager *fm =	[[NSFileManager alloc]init];
		BOOL isDir;
		if ( [fm fileExistsAtPath:competitorFile isDirectory:&isDir] )
			[self badUser];
		else
			[gameViewController cancelledRegister];
		[fm release];
	}
}

-(void) requestPrediction: (NSString *)name
{
	if (connectionType == RPC_SOCKET_CONNECTION_)
		[socket_ requestPrediction:name];
	else
	{
		NSString *fName = @"player_";
		fName = [fName stringByAppendingString:name];
		fName = [fName stringByAppendingString:@".rpf"];
		[self loadRPF:fName SubIndex:nil];		
	}

}

-(void) registeredUser
{
	[gameViewController registeredUser];
}

-(void) badUser
{
	[gameViewController badUser];
}

-(void) willResignActive
{
	playOnBecomeActive = playing;
	jumpOnBecomeActive = true;
	[self stopPlay];
	
	if ( live )
		restartTime = 0;
	else
		restartTime = currentTime;
	
	if ( connectionType == RPC_SOCKET_CONNECTION_ )
	{
		[self setConnectionType:RPC_NO_CONNECTION_];
		[socket_ release];
		socket_ = nil;
		
		reconnectOnBecomeActive = true;
	}
	else
	{
		reconnectOnBecomeActive = false;
	}

	
}

-(void) didBecomeActive
{
	if ( reconnectOnBecomeActive )
	{
		needsPlayRestart = playOnBecomeActive;
		[self SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:YES];
		[settingsViewController updateServerState];
	}
	else
	{
		if ( playOnBecomeActive )
		{
			[self prepareToPlay];
			[self startPlay];
		}
		else if ( jumpOnBecomeActive )
		{
			[self jumpToTime:restartTime];
		}		
	}
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
@synthesize refresh_enabled_;

-(id)initWithView:(id)view AndType:(int)type
{
	if(self = [super init])
	{
		view_ = [view retain];
		parameter_ = nil;
		type_ = type;
		displayed_ = false;
		refresh_enabled_ = true;
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


