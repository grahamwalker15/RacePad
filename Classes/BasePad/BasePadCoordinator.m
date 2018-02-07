//
//  BasePadCoordinator.m
//  BasePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadCoordinator.h"
#import "BasePadMedia.h"
#import "BasePadAppDelegate.h"
#import "BasePadSponsor.h"
#import "BasePadViewController.h"
#import "BasePadTimeController.h"
#import "BasePadTitleBarController.h"
#import "BasePadClientSocket.h"
#import "BasePadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "BasePadDatabase.h"
#import "CompositeViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "TabletState.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation BasePadCoordinator

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
@synthesize videoViewController;
@synthesize videoConnectionType;
@synthesize videoConnectionStatus;
@synthesize serverConnectionStatus;
@synthesize showingConnecting;
@synthesize liveMovieSeekAllowed;
@synthesize nameToFollow;
@synthesize lightRestart;
@synthesize diagnostics;
@synthesize forceDataLive;

static BasePadCoordinator * instance_ = nil;

+(BasePadCoordinator *)Instance
{
	assert ( instance_ );
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		instance_ = self;
		
		[HelpViewController specifyHelpMaster:self];
		appVersionNumber = 1.1;
		
		currentTime = [ElapsedTime LocalTimeOfDay];
		startTime = currentTime;
		endTime = currentTime + 7200;
		
		playbackRate = 1.0;
		activePlaybackRate = 1.0;
		
		needsPlayRestart = true;
		playing = false;
		allowProtectMediaFromRestart = false;
		protectMediaFromRestart = false;
		
        forceDataLive = false;
        socketStreaming = false;
        protectDataFromRestart = false;
        
		dataUpdateTimer = nil;
		elapsedTime = nil;
		
		views = [[NSMutableArray alloc] init];
		dataSources = [[NSMutableArray alloc] init];
		allTabs = [[NSMutableArray alloc] init];
		
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
		
		serverConnectionStatus = BPC_NO_CONNECTION_;
		connectionType = BPC_NO_CONNECTION_;
		connectionRetryCount = 0;
		connectionRetryTimer = nil;
		live = true;
		showingConnecting = false;
		
		videoConnectionStatus = BPC_NO_CONNECTION_;
		videoConnectionType = BPC_NO_CONNECTION_;
		
		reconnectOnBecomeActive = false;
		playOnBecomeActive = false;
		jumpOnBecomeActive = false;
		restartTime = 0;
		
		liveMovieSeekAllowed = true;
        
		diagnostics = false;
				
		currentSponsor = [[BasePadSponsor Instance] sponsor];
        
        settingsViewController = nil;
        
        connectionFeedbackDelegates = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[socket_ Disconnect];
    
	[views removeAllObjects];
	[views release];
    
	[dataSources removeAllObjects];
	[dataSources release];
    
	[registeredViewController release];
	[sessionPrefix release];
	[downloadProgress release];
	[serverConnect release];
	[workOffline release];
	[settingsViewController release];
    
	[connectionFeedbackDelegates removeAllObjects];
	[connectionFeedbackDelegates release];
    
	[videoViewController release];
	[allTabs release];
    [super dealloc];
}

- (void) onStartUp
{
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if ( tabControl )
	{
		unsigned char i;
		NSMutableArray *tabs = [[NSMutableArray alloc] init];
		int all_tabs = [[BasePadSponsor Instance] allTabCount];
		for ( i = 0; i < all_tabs; i++ )
		{
			bool supported = [[BasePadSponsor Instance]supportsTab:i];
			/*
			 if ( supported && i == [[BasePadSponsor Instance] videoTab] )
			 {
			 NSNumber *v = [[BasePadPrefs Instance] getPref:@"supportVideo"];
			 if ( v )
			 supported = [v boolValue];
			 }
			 */
			if ( supported )
				[tabs addObject:[allTabs objectAtIndex:i]];
		}
		[tabControl setViewControllers:tabs animated:YES];
        [tabs release];
	}
}

- (void) selectTab:(int)index
{
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
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

- (void) selectVideoTab
{
	BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	
	if(tabControl)
	{
		NSArray * controllers = [tabControl viewControllers];
		
		if(controllers)
		{
			int index = 0;
			for(UIViewController * controller in controllers)
			{
				if(controller && [controller isKindOfClass:[CompositeViewController class]])
				{
					[tabControl setSelectedIndex:index];
					break;
				}
				
				index++;
			}
		}
	}
}

- (void) updateSponsor
{
	[self updateTabs];
	[[BasePadTitleBarController Instance] updateSponsor];
	[settingsViewController updateSponsor];
	
	// Go to first Tab if we've changed the sponsor
	if ( currentSponsor != [[BasePadSponsor Instance] sponsor] )
	{
		currentSponsor = [[BasePadSponsor Instance] sponsor];
		BasePadAppDelegate *app = (BasePadAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	[[BasePadDatabase Instance] clearStaticData];
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
	
	if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self setTimer:currentTime];
	
	playUpdateTimer10hz = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playUpdateTimer10hzFired:) userInfo:nil repeats:YES];
	playUpdateTimer1hz = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playUpdateTimer1hzFired:) userInfo:nil repeats:YES];
	
	if(!protectMediaFromRestart)
	{
		if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
			[[BasePadMedia Instance] moviePlayAtRate:activePlaybackRate];
		
		if(connectionType == BPC_ARCHIVE_CONNECTION_)
			[[BasePadMedia Instance] audioPlayAtRate:activePlaybackRate];
	}
	
}

-(void)pausePlay
{
	if(!playing)
		return;
	
	float elapsed = [elapsedTime value];
	currentTime = (float)baseTime * 0.001 + elapsed * activePlaybackRate;
	[elapsedTime release];
	elapsedTime = nil;
	
	if(dataUpdateTimer)
	{
		[dataUpdateTimer invalidate];
		dataUpdateTimer = nil;
	}
	
	if(playUpdateTimer10hz)
	{
		[playUpdateTimer10hz invalidate];
		playUpdateTimer10hz = nil;
	}
	
	if(playUpdateTimer1hz)
	{
		[playUpdateTimer1hz invalidate];
		playUpdateTimer1hz = nil;
	}
	
	if (connectionType == BPC_SOCKET_CONNECTION_)
    {
        if(!protectDataFromRestart)
        {
            [socket_ stopStreams];
            socketStreaming = false;
        }
    }
	
	if(!protectMediaFromRestart)
	{
		if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
			[[BasePadMedia Instance] movieStop];
		
		if(connectionType == BPC_ARCHIVE_CONNECTION_)
			[[BasePadMedia Instance] audioStop];
	}
	
	[[BasePadTimeController Instance] updateTime:currentTime];
	
	playing = false;
	
}

-(void)stopPlay
{
	[self pausePlay];
	needsPlayRestart = false;
	activePlaybackRate = playbackRate = 1.0;
    
	[[BasePadTitleBarController Instance] updateLiveIndicator];
    [registeredViewController notifyChangeToLiveMode];
    
	[[BasePadMedia Instance] stopPlayTimers];
}

-(void) userPause
{
    if(forceDataLive)
        protectDataFromRestart = true;
    
	live = false;
	[self stopPlay];
	[settingsViewController updateConnectionType];
	[[BasePadTitleBarController Instance] updateLiveIndicator];
    [registeredViewController notifyChangeToLiveMode];
    
    protectDataFromRestart = false;
}

-(void)jumpToTime:(float)time
{
    if(forceDataLive)
        protectDataFromRestart = true;
    
	[self stopPlay];
	
	[[BasePadMedia Instance] setMoviePausedInPlace:false];
	[[BasePadMedia Instance] setMoviePlaying:false];
	
	currentTime = time;
	live = false;
	
	[[BasePadTimeController Instance] updatePlayButtons];
	[[BasePadTitleBarController Instance] updateLiveIndicator];
    [registeredViewController notifyChangeToLiveMode];
	[[BasePadTitleBarController Instance] updateTime:currentTime];
	[self resetCommentaryTimings];
	[self resetListUpdateTimings];
	[self showSnapshot];
    
    protectDataFromRestart = false;
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
	if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self DestroyDataSources];
	else if(type == BPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	connectionType = type;
	
	if ( play )
	{
		if ( connectionType == BPC_NO_CONNECTION_ )
		{
			needsPlayRestart = true;
		}
		else
		{
			[self prepareToPlay];
			[self startPlay];
			[[BasePadTimeController Instance] updatePlayButtons];
			[[BasePadTitleBarController Instance] updateLiveIndicator];
            [registeredViewController notifyChangeToLiveMode];
		}
	}
	
	[settingsViewController updateConnectionType];
	[[BasePadTitleBarController Instance] updateLiveIndicator];
	[[BasePadPrefs Instance]setPref:@"connectionType" Value:[NSNumber numberWithInt: connectionType]];
	[[BasePadPrefs Instance] save];
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
		[self prepareToPlay];
		[self startPlay];
		[[BasePadTimeController Instance] updatePlayButtons];
	}
	
	[[BasePadTitleBarController Instance] updateLiveIndicator];
    [registeredViewController notifyChangeToLiveMode];
	
}

-(void)prepareToPlay
{
	if ( restartTime != 0 )
	{
		currentTime = restartTime;
		restartTime = 0;
	}
	
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[self prepareToPlayFromSocket];
	else if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self prepareToPlayArchives];
	else
		[self prepareToPlayUnconnected];
}

-(void)showSnapshot
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[self showSnapshotFromSocket];
	else if(connectionType == BPC_ARCHIVE_CONNECTION_)
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
		BPCDataSource * source = [dataSources objectAtIndex:i];
		float nextTime = [[source dataHandler] inqTime] / 1000.0;
		if ( eventTime == 0 || (nextTime != 0 && nextTime < eventTime) )
			eventTime = nextTime;
	}
	
	if ( eventTime > 0 )
		dataUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:((eventTime - thisTime) / activePlaybackRate) target:self selector:@selector(dataUpdateTimerFired:) userInfo:nil repeats:NO];
	else
		dataUpdateTimer = nil;
	
}

- (void) dataUpdateTimerFired: (NSTimer *)theTimer
{
	dataUpdateTimer = nil;
	
	float elapsed = [elapsedTime value]  * activePlaybackRate;
	
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			BPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] update:baseTime + elapsed * 1000];
		}
	}
	
	if ( playing )
		[self setTimer:currentTime + elapsed];
}

-(float)currentPlayTime
{
	if(playing)
	{
		float elapsed = [elapsedTime value]  * activePlaybackRate;
		return currentTime + elapsed;
	}
	else
	{
		return currentTime;
	}
}

- (void) resetCommentaryTimings
{
	// Override Me
}

-(void) redrawCommentary
{
	// Override Me
}

-(void) resetListUpdateTimings
{
	// Override Me
}

- (void) playUpdateTimer10hzFired: (NSTimer *)theTimer
{
	float elapsed = [elapsedTime value] * activePlaybackRate;
	[[BasePadTimeController Instance] updateTime:currentTime + elapsed];
	[[BasePadTitleBarController Instance] updateTime:currentTime + elapsed];
	
	[self redrawCommentary];
}

- (void) playUpdateTimer1hzFired: (NSTimer *)theTimer
{
}

////////////////////////////////////////////////////////////////////////////////////////
// Local archive management
////////////////////////////////////////////////////////////////////////////////////////

- (BasePadDataHandler *)allocateDataHandler
{
	return [BasePadDataHandler alloc]; // Override Me
}

- (void) loadBPF: (NSString *)archive File:(NSString *)file SubIndex: (NSString *)subIndex
{
	NSString *chunk = file;
	if ( subIndex != nil )
	{
		chunk = [chunk stringByAppendingString:@"_"];
		chunk = [chunk stringByAppendingString:subIndex];
	}
	
	// Called at the beginning to load static elements - track map, helmets etc.
	BasePadDataHandler *handler = [[self allocateDataHandler] initWithPath:archive SessionPrefix:sessionPrefix SubIndex:chunk];
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
			BPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] setTime:(int)(currentTime * 1000.0)];
		}
	}
	
	[self restartCommentary];
	
	// If the registered view controller is interested in video, prepare it to play
	if(!protectMediaFromRestart)
	{
		if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
		{
			[[BasePadMedia Instance] movieGotoTime:currentTime];
		}
		
		[[BasePadMedia Instance] audioGotoTime:currentTime];
		[[BasePadMedia Instance] audioPrepareToPlay];
	}
}

- (void) showSnapshotOfArchives
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			BPCDataSource * source = [dataSources objectAtIndex:i];
			[[source dataHandler] setTime:(int)(currentTime * 1000.0)];
		}
	}
	
	[self restartCommentary];
	
	// If the registered view controller is interested in video, cue this too
	if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
	{
		[[BasePadMedia Instance] movieGotoTime:currentTime];
	}
	
	[self redrawCommentary];
}

- (NSString *)archiveName
{
	return @"base_pad.rpa";
}

- (NSString *)baseChunkName
{
	return @"base_pad";
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
	NSString *archive = [self archiveName];
	[self loadBPF: archive File:[self baseChunkName] SubIndex:nil];
	[self loadBPF: archive File:@"event" SubIndex:nil];
	[self loadBPF: archive File:@"session" SubIndex:nil];
	
	[[BasePadPrefs Instance] setPref:@"preferredEvent" Value:event ];
	[[BasePadPrefs Instance] setPref:@"preferredSession" Value:session];
	
	[self setConnectionType:BPC_ARCHIVE_CONNECTION_];
	
	[[BasePadMedia Instance] verifyAudioLoaded];
	
	[self onSessionLoaded];
}

-(void)onSessionLoaded
{
	// Override to do something
}

-(NSString *)getVideoArchiveRoot
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	return folder;
}

-(NSString *)getAudioArchiveRoot
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	return folder;
}

-(NSString *)getVideoArchiveName
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	
	
	// Try first with vls extension - a video list file
	NSString *name = [sessionPrefix stringByAppendingString:@"video.vls"];
	NSString *fileName = [folder stringByAppendingPathComponent:name];
	
	// check whether it exists
	FILE * f;
	if((f = fopen ( [fileName UTF8String], "rt" )))
	{
		fclose(f);
		return fileName;
	}
	
	// If this fails, try with m4v extension
	name = [sessionPrefix stringByAppendingString:@"video.m4v"];
	fileName = [folder stringByAppendingPathComponent:name];
	if((f = fopen ( [fileName UTF8String], "rb" )))
	{
		fclose(f);
		return fileName;
	}
	
	// If this fails, try with mp4 extension
	name = [sessionPrefix stringByAppendingString:@"video.mp4"];
	fileName = [folder stringByAppendingPathComponent:name];
	if((f = fopen ( [fileName UTF8String], "rb" )))
	{
		fclose(f);
		return fileName;
	}
	
	// If none of them are present, return nil
	return nil;
}

-(NSString *)getAudioArchiveName
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *name = [sessionPrefix stringByAppendingString:@"audio.mp3"];
	NSString *fileName = [folder stringByAppendingPathComponent:name];
	
	// check whether it exists
	FILE * f;
	if((f = fopen ( [fileName UTF8String], "rb" )))
	{
		fclose(f);
		return fileName;
	}
	
	// If it is not present, return nil
	return nil;
}

-(NSString *)getLiveVideoListName
{
	// Get base folder
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	
	// Look for LiveVideoConnection.vls - a video list file
	NSString *name = @"LiveVideoConnection.vls";
	NSString *fileName = [folder stringByAppendingPathComponent:name];
	
	// check whether it exists
	FILE * f;
	if((f = fopen ( [fileName UTF8String], "rt" )))
	{
		fclose(f);
		return fileName;
	}
    
	// If it is not present, return nil
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////
// Socket management
////////////////////////////////////////////////////////////////////////////////////////

-(void)AddConnectionFeedbackDelegate:(id <ConnectionFeedbackDelegate>)object
{
	// First make sure that this object is not already in the list
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            if(object == [connectionFeedbackDelegates objectAtIndex:i])
                return;
        }
    }
	
	// Reach here if the view wasn't found - so we'll add a new one
	[connectionFeedbackDelegates addObject:object];
}

-(void)RemoveConnectionFeedbackDelegate:(id <ConnectionFeedbackDelegate>)object
{
	// First make sure that this object is not already in the list
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            if(object == [connectionFeedbackDelegates objectAtIndex:i])
            {
                [connectionFeedbackDelegates removeObjectAtIndex:i];
                return;
            }
        }
    }
}

-(void) requestInitialData
{
	// Override me
}

-(void) requestConnectedData
{
	// Override me
}

- (void) setServerConnected:(bool) ok
{
	if ( ok )
	{
		[self requestInitialData];
		
		live = (restartTime == 0);
		double savedTime = restartTime;
		
		[self setConnectionType:BPC_SOCKET_CONNECTION_];
		restartTime = savedTime; // setConnectionType will have set it to 0, and SetProjectRange will need to see it.
		
		[self requestConnectedData];
		
		showingConnecting = false;
		[serverConnect popDown];
        
        [self onSuccessfulConnection];
	}
	else
	{
		[socket_ Disconnect];
		socket_ = nil;
		
		[self setConnectionType:BPC_NO_CONNECTION_];
		
		restartTime = 0;
		
		[serverConnect badVersion];
	}
	
	[settingsViewController updateServerState];
    
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            id <ConnectionFeedbackDelegate> delegate = [connectionFeedbackDelegates objectAtIndex:i];
            [delegate notifyConnectionSucceeded];
        }
    }
}

- (void) retryConnection:(NSTimer *)timer
{
	if(connectionRetryCount < 10)
	{
		connectionRetryCount++;
		[self SetServerAddress:[self PreferredServerAddress] ShowWindow:NO LightRestart:false];
        
        int delegate_count = [connectionFeedbackDelegates count];
        if(delegate_count > 0)
        {
            for ( int i = 0 ; i < delegate_count ; i++)
            {
                id <ConnectionFeedbackDelegate> delegate = [connectionFeedbackDelegates objectAtIndex:i];
                [delegate notifyConnectionRetry];
            }
        }
	}
	else
	{
		connectionRetryCount = 0;
		[serverConnect connectionTimeout];
	}
	
}

- (void) connectionTimeout
{
	[socket_ Disconnect];
	socket_ = nil;
	
	[self setConnectionType:BPC_NO_CONNECTION_];
	
	restartTime = 0;
	
	[settingsViewController updateServerState];
    
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            id <ConnectionFeedbackDelegate> delegate = [connectionFeedbackDelegates objectAtIndex:i];
            [delegate notifyConnectionTimeout];
        }
    }
	[[BasePadTitleBarController Instance] updateLiveIndicator];
}

-(bool) serverConnected
{
	return socket_ != nil;
}

- (void) showConnecting
{
	if ( socket_ != nil
		&& connectionType != BPC_SOCKET_CONNECTION_
		&& !showingConnecting )
	{
		if ( serverConnect == nil )
			serverConnect = [[ServerConnect alloc] initWithNibName:@"ServerConnect" bundle:nil];
		showingConnecting = true;
		[registeredViewController presentModalViewController:serverConnect animated:YES];
	}
}

- (int) serverPort
{
	return 6020;
}

- (BasePadClientSocket*) createClientSocket
{
	return [[BasePadClientSocket alloc] CreateSocket]; // Override Me
}

- (void) SetServerAddress : (NSString *) server ShowWindow:(BOOL)showWindow LightRestart:(bool) lRestart
{
	if ( server && [server length] )
	{
		[socket_ Disconnect];
		socket_ = [self createClientSocket];
		
		connectionType = BPC_NO_CONNECTION_;
		
		[socket_ ConnectSocket:[server UTF8String] Port:[self serverPort]];
		
		[self UpdateServerPrefs:server];
		
		[self clearStaticData];
		lightRestart = lRestart;
		[[BasePadTitleBarController Instance] updateLiveIndicator];
		
		if ( showWindow )
		{
			// Slightly delay popping up the connect window, just in case we connect really quickly
			[self performSelector:@selector(showConnecting) withObject:nil afterDelay: 1.0];
		}
	}
}

- (void) SetVideoServerAddress : (NSString *) server
{
	if ( server && [server length] )
	{
		[[BasePadPrefs Instance] setPref:@"preferredVideoServerAddress" Value:server];
		[[BasePadPrefs Instance] save];
	}
}

- (NSString *) PreferredServerAddress
{
	return [[BasePadPrefs Instance] getPref:@"preferredServerAddress"];
}

- (void) UpdateServerPrefs : (NSString *) server
{
	[[BasePadPrefs Instance] setPref:@"preferredServerAddress" Value:server];
	[[BasePadPrefs Instance] save];
}

- (void) disconnect
{
	[self setConnectionType: BPC_NO_CONNECTION_];
	
	[socket_ Disconnect];
	socket_ = nil;
}

- (void) Connected
{
}

- (void) Disconnected: (bool) atConnect
{
	// If failed at connect (because WiFi is switched off say), then the connect window will already be up
	// So, let timer do it do it's thing
	if ( !(atConnect && showingConnecting))
	{
		[socket_ Disconnect];
		socket_ = nil;
		
		if ( live )
			restartTime = 0;
		else
			restartTime = currentTime;
		
		[self setConnectionType:BPC_NO_CONNECTION_];
		[self performSelector:@selector(autoRetry) withObject:nil afterDelay: 1.0];
		[settingsViewController updateServerState];
		[[BasePadTitleBarController Instance] updateLiveIndicator];
	}
    
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            id <ConnectionFeedbackDelegate> delegate = [connectionFeedbackDelegates objectAtIndex:i];
            [delegate notifyConnectionFailed];
        }
    }
}

- (void) autoRetry
{
	[self SetServerAddress:[self PreferredServerAddress] ShowWindow:NO LightRestart:false];
}

- (void) goOffline
{
	if ( workOffline == nil )
		workOffline = [[WorkOffline alloc] initWithNibName:@"WorkOffline" bundle:nil];
	
	[registeredViewController presentModalViewController:workOffline animated:YES];
	[[BasePadTitleBarController Instance] updateLiveIndicator];
}

- (void) videoServerOnConnectionChange
{
	[settingsViewController updateServerState];
}

- (void) onSuccessfulConnection
{
    // Override me
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
}

- (void) streamData:(BPCView *) existing_view
{
	// Override Me
}

-(void)prepareToPlayFromSocket
{
	if ( live )
	{
        if(!socketStreaming)
        {
            playbackRate = 1.0;
            [socket_ goLive];
            [self streamViewsFromSocket];
        }
	}
	else if ( forceDataLive )
	{
        if(!socketStreaming)
        {
            [socket_ goLive];
            [self streamViewsFromSocket];
        }
	}
	else
	{
		[socket_ SetPlaybackRate:playbackRate];
		[socket_ SetReferenceTime:currentTime];
        [self streamViewsFromSocket];
	}
	
	// If the registered view controller is interested in video, cue this to play live too
	if(!protectMediaFromRestart)
	{
		if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
		{
			if ( live )
			{
				[[BasePadMedia Instance]  moviePrepareToPlayLive];
			}
			else
			{
				[[BasePadMedia Instance] movieGotoTime:currentTime];
			}
		}
	}
}

- (void) streamViewsFromSocket
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		// We keep a mask of streams already started so that none get started twice
		int stream_mask = 0;
		
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				int type = [existing_view Type];
				
				// Check it hasn't already started
				if((stream_mask & type) > 0)
					continue;
				
				// Otherwise we can start it
				
				stream_mask = (stream_mask | type);
				[self streamData:existing_view];
			}
		}
	}
	
	[self restartCommentary];
	
    socketStreaming = true;
}

- (void) requestData:(BPCView *) existing_view
{
	// Override Me
}

-(void)showSnapshotFromSocket
{
    // If the data is forced to be live, we don't show a snapshot here, we start the live data play if needed
    // Otherwise, we will set up snapshot
    if(forceDataLive)
    {
        if(!socketStreaming)
        {
            playbackRate = 1.0;
            [socket_ goLive];
            [self streamViewsFromSocket];
        }
    }
    else
    {
        [socket_ SetPlaybackRate:playbackRate];
        [socket_ SetReferenceTime:currentTime];
        
        int view_count = [views count];
        
        if(view_count > 0)
        {
            for ( int i = 0 ; i < view_count ; i++)
            {
                BPCView * existing_view = [views objectAtIndex:i];
                if([existing_view Displayed])
                {
                    [self requestData:existing_view];
                }
            }
        }
        
        [self restartCommentary];
    }
	
	// If the registered view controller is interested in video, cue this too - always a snapshot regardless of forceDataLive flag
	if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
	{
		if(liveMovieSeekAllowed)
			[[BasePadMedia Instance] movieGotoTime:currentTime];
	}
	
}

-(void)prepareToPlayUnconnected
{
	if ( live )
		playbackRate = 1.0;
	
	// If the registered view controller is interested in video, cue this to play
	if(!protectMediaFromRestart)
	{
		if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
		{
			if ( live )
			{
				[[BasePadMedia Instance]  moviePrepareToPlayLive];
			}
			else
			{
				[[BasePadMedia Instance] movieGotoTime:currentTime];
			}
		}
	}
}

-(void)showSnapshotUnconnected
{
	// If the registered view controller is interested in video, cue this
	if(registeredViewController && (registeredViewControllerTypeMask & BPC_VIDEO_VIEW_) > 0)
	{
		if(liveMovieSeekAllowed)
			[[BasePadMedia Instance] movieGotoTime:currentTime];
	}
}


////////////////////////////////////////////////////////////////////////////////////////
// Registration etc. of "interested" views - used to tell the server what data to send
////////////////////////////////////////////////////////////////////////////////////////

-(void)RegisterViewController:(BasePadViewController *)view_controller WithTypeMask:(int)mask
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
	
	BasePadTimeController * time_controller = [BasePadTimeController Instance];
	
	if([time_controller displayed])
    {
		if ( [view_controller wantTimeControls] )
			[time_controller displayInViewController:view_controller Animated:false];
		else
			[time_controller setDisplayed:NO];
    }
}

-(void)ReleaseViewController:(BasePadViewController *)view_controller
{
	if(registeredViewController == view_controller)
	{
		[registeredViewController release];
		registeredViewController = nil;
		registeredViewControllerTypeMask = 0;
	}
}

-(void)AddView:(id)view WithType:(int)type
{
	// First make sure that this view is not already in the list
	BPCView * existing_view = [self FindView:view WithType:type];
	
	if(existing_view)
	{
		// If it is already there, don't add it
		return;
	}
	
	// Reach here if the view wasn't found - so we'll add a new one
	BPCView * new_view = [[BPCView alloc] initWithView:view AndType:type];
	[views addObject:new_view];
	[new_view release];
}

-(void)RemoveView:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = view_count - 1 ; i >= 0 ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view)
			{
				[views removeObjectAtIndex:i];
			}
		}
	}
}

-(void)SetViewDisplayed:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view && ![existing_view Displayed])
			{
				[existing_view SetDisplayed:true];
				[existing_view SetRefreshEnabled:true];
				
				if(!needsPlayRestart && allowProtectMediaFromRestart)
					protectMediaFromRestart = true;
				
				needsPlayRestart = (needsPlayRestart || playing);
				
				if(playing)
					[self pausePlay];
				
				if (connectionType == BPC_ARCHIVE_CONNECTION_)
					[self AddDataSourceWithType:[existing_view Type] AndParameter:[existing_view Parameter]];
				
				if(needsPlayRestart)
				{
					[self prepareToPlay];
					[self startPlay];
					[[BasePadTimeController Instance] updatePlayButtons];
				}
				else
				{
					[self showSnapshot];
				}
				
				protectMediaFromRestart = false;
			}
		}
	}
}

-(void)SetViewHidden:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			
			if([existing_view View] == view && [existing_view Displayed])
			{
				[existing_view SetDisplayed:false];
					
				// If this was the last displayed view, stop the play timers, but record the fact
				// that we are playing so that it will restart when the next view is loaded
					
				// If it is not the last view, restart all the others
				if(playing)
				{
					if([self DisplayedViewCount] <= 0)
					{
						[self stopPlay]; // This will stop the server streaming
						needsPlayRestart = true;
					}
					else
					{
						if(allowProtectMediaFromRestart)
							protectMediaFromRestart = true;
						
						[self pausePlay];
						[self prepareToPlay];
						[self startPlay];
						[[BasePadTimeController Instance] updatePlayButtons];
						
						protectMediaFromRestart = false;
						
					}
				}
				
				// Release the data handler
				if(connectionType == BPC_ARCHIVE_CONNECTION_)
					[self RemoveDataSourceWithType:[existing_view Type]];
			}
		}
	}
}

-(void)EnableViewRefresh:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view)
			{
				[existing_view SetRefreshEnabled:true];
			}
		}
	}
}

-(void)DisableViewRefresh:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view)
			{
				[existing_view SetRefreshEnabled:false];
			}
		}
	}
}

-(void)SetParameter:(NSString *)parameter ForView:(id)view
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view)
			{
				[existing_view SetParameter:parameter];
			}
		}
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
	if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self DestroyDataSources];
	
	[downloadProgress setProject:eventName SessionName:sessionName SizeInMB:sizeInMB];
	[registeredViewController presentModalViewController:downloadProgress animated:YES];
}

-(void) projectDownloadCancelled
{
	if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	[downloadProgress dismissModalViewControllerAnimated:YES];
	
	// Dismissing the view will make the playing restart if required.
}

-(void) projectDownloadComplete
{
	if(connectionType == BPC_ARCHIVE_CONNECTION_)
		[self CreateDataSources];
	
	[downloadProgress dismissModalViewControllerAnimated:YES];
	
	if ( registeredViewControllerTypeMask & BPC_SETTINGS_VIEW_ )
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
			BPCView * existing_view = [views objectAtIndex:i];
			
			if( [existing_view Type] == type && [existing_view Displayed] && [existing_view RefreshEnabled])
			{
				[[existing_view View] RequestRedrawForUpdate];
			}
		}
	}
	
	if(registeredViewController && (registeredViewControllerTypeMask & type) > 0)
		[registeredViewController RequestRedrawForType:type];
}

-(BPCView *)FindView:(id)view WithType:(int)type
{
	int view_count = [views count];
	
	if(view_count > 0)
	{
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view View] == view && [existing_view Type] == type)
			{
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
			BPCView * existing_view = [views objectAtIndex:i];
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

-(void)AddDataSourceWithType:(int)type AndArchive:(NSString *)archive AndFile:(NSString *)file AndSubIndex:(NSString *)subIndex
{
	NSString *chunk = file;
	if ( subIndex != nil )
	{
		chunk = [chunk stringByAppendingString:@"_"];
		chunk = [chunk stringByAppendingString:subIndex];
	}
	BasePadDataHandler * data_handler = [[self allocateDataHandler] initWithPath:archive SessionPrefix:sessionPrefix SubIndex:chunk];
	BPCDataSource *rpc_source = [[BPCDataSource alloc] initWithDataHandler:data_handler Type:type Filename:chunk];
	[dataSources addObject:rpc_source];
	[rpc_source release];
}

-(void)AddDataSourceWithType:(int)type AndFile:(NSString *)file
{
	[self AddDataSourceWithType:type AndArchive:[self archiveName] AndFile:file AndSubIndex:nil];
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	// Override ME
}

-(void)AddDataSourceWithType:(int)type AndParameter:(NSString *)parameter
{
	// There are no data sources for video or settings types, so ignore calls with this type
	if(type == BPC_VIDEO_VIEW_ || type == BPC_SETTINGS_VIEW_)
		return;
	
	// First make sure that this handler is not already in the list
	BPCDataSource * existing_source = [self FindDataSourceWithType:type];
	
	if(existing_source)
	{
		// If it is, just increment the reference count
		[existing_source incrementReferenceCount];
		return;
	}
	
	[self addDataSource:type Parameter:parameter];
}

-(void)RemoveDataSourceWithType:(int)type
{
	int index;
	BPCDataSource * existing_source = [self FindDataSourceWithType:type WithIndexReturned:&index];
	
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
			BPCView * existing_view = [views objectAtIndex:i];
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

-(BPCDataSource *)FindDataSourceWithType:(int)type
{
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			BPCDataSource * source = [dataSources objectAtIndex:i];
			if([source archiveType] == type)
			{
				return source;
			}
		}
	}
	
	// Reach here if the view wasn't found
	return nil;
}

-(BPCDataSource *)FindDataSourceWithType:(int)type WithIndexReturned:(int *)index
{
	*index = -1;
	
	int data_source_count = [dataSources count];
	
	if(data_source_count > 0)
	{
		for ( int i = 0 ; i < data_source_count ; i++)
		{
			BPCDataSource * source = [dataSources objectAtIndex:i];
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

-(void) willResignActive
{
	playOnBecomeActive = playing;
	jumpOnBecomeActive = true;
	[self stopPlay];
	
	if ( live )
		restartTime = 0;
	else
		restartTime = currentTime;
	
	if ( connectionType == BPC_SOCKET_CONNECTION_ )
	{
		[self setConnectionType:BPC_NO_CONNECTION_];
		[socket_ Disconnect];
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
		[self SetServerAddress:[self PreferredServerAddress] ShowWindow:YES LightRestart:true];
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

//
// HelpViewMaster Protocol

- (bool) helpMasterPlaying;
{
	return playing;
}

- (void) helpMasterPausePlay
{
	[self pausePlay];
}

- (void) helpMasterStartPlay
{
	[self startPlay];
}

@end


////////////////////////////////////////////////////////////////////////////////////////
// BPCView Class
////////////////////////////////////////////////////////////////////////////////////////

@implementation BPCView

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
// BPCDataSource Class
////////////////////////////////////////////////////////////////////////////////////////

@implementation BPCDataSource

@synthesize dataHandler;
@synthesize fileName;
@synthesize archiveType;
@synthesize referenceCount;

-(id)initWithDataHandler:(BasePadDataHandler *)handler Type:(int)type Filename:(NSString *)name
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


