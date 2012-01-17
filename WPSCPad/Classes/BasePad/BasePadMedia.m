//
//  BasePadMedia.m
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadMedia.h"

#import "BasePadCoordinator.h"
#import "ElapsedTime.h"
#import "BasePadPrefs.h"
#import "BasePadDatabase.h"


@implementation BasePadMedia

@synthesize movieSource;
@synthesize audioSource;

@synthesize liveVideoDelay;

@synthesize restartCount;
@synthesize resyncCount;

@synthesize currentStatus;
@synthesize currentError;

@synthesize movieType;

static BasePadMedia * instance_ = nil;

+(BasePadMedia *)Instance
{
	if(!instance_)
		instance_ = [[BasePadMedia alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		currentStatus = BPM_NOT_CONNECTED_;
		currentError = nil;
		
		movieSource = [[BasePadVideoSource alloc] init];
		audioSource = [[BasePadAudioSource alloc] init];
		
		activePlaybackRate = 1.0;
		liveVideoDelay = 0.0;
		
		restartCount = 0;
		resyncCount = 0;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		
		moviePlayElapsedTime = nil;
		
		playStartTimer = nil;
		playTimer = nil;
		
		movieType = MOVIE_TYPE_NONE_;
	}
	
	return self;
}


- (void)dealloc
{
	if(movieSource)
	{
		[movieSource release];
		movieSource= nil;
	}
	
	if(audioSource)
	{
		[audioSource release];
		audioSource= nil;
	}
	
    [super dealloc];
}

- (void) onStartUp
{
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void)resetConnectionCounts
{
	resyncCount = 0;
	restartCount = 0;
	
	[movieSource resetConnectionCounts];
}

- (void)connectToVideoServer
{
	[[BasePadCoordinator Instance] setVideoConnectionType:BPC_VIDEO_LIVE_CONNECTION_];
	
	currentStatus = BPM_TRYING_TO_CONNECT_;
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
	[self verifyMovieLoaded];
}

- (void)disconnectVideoServer
{
	if(movieSource)
	{
		[movieSource unloadMovie];
	}
	
	movieType = MOVIE_TYPE_NONE_;
	
	currentStatus = BPM_NOT_CONNECTED_;
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	[[BasePadCoordinator Instance] setVideoConnectionType:BPC_NO_CONNECTION_];
	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_NO_CONNECTION_];
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
}

- (void)verifyMovieLoaded
{
	// Check that we have the right movie loaded
	NSURL * url = [self getMovieURL];	
	if(url)
	{
		NSString * newMovie = [url absoluteString];
		NSString * currentMovie = [movieSource currentMovie];
		if(!currentMovie || [newMovie compare:currentMovie] != NSOrderedSame )
		{
			[movieSource loadMovie:url];
		}
	}
	else
	{
		[movieSource unloadMovie];
		movieType = MOVIE_TYPE_NONE_;
	}
}

- (void)verifyAudioLoaded
{
	// Check that we have the right audio loaded
	NSURL * url = [self getAudioURL];	
	if(url)
	{
		NSString * newAudio = [url absoluteString];
		NSString * currentAudio = [audioSource currentAudio];
		if(!currentAudio || [newAudio compare:currentAudio] != NSOrderedSame )
		{
			[audioSource loadAudio:url];
		}
	}
	else
	{
		[audioSource unloadAudio];
	}
}

////////////////////////////////////////////////////////////////////////////
// Movie and Audio information
////////////////////////////////////////////////////////////////////////////

- (NSURL *)getMovieURL
{
	NSURL * url = nil;;
	
	// Live stream or archive name
	if ( [[BasePadCoordinator Instance] connectionType] != BPC_ARCHIVE_CONNECTION_ && [[BasePadCoordinator Instance] videoConnectionType] == BPC_VIDEO_LIVE_CONNECTION_)
	{
		NSString * serverAddress = [[[BasePadPrefs Instance] getPref:@"preferredVideoServerAddress"] retain];
		
		if(serverAddress && [serverAddress length] > 0)
		{
			NSString * urlString = @"http://";
			urlString = [urlString stringByAppendingString:serverAddress];
			urlString = [urlString stringByAppendingString:@"/iPad_ipad.m3u8"];
			
			url = [NSURL URLWithString:urlString];	// auto released
		}
		
		[serverAddress release];
		
		movieType = MOVIE_TYPE_LIVE_STREAM_;
	}
	else if([[BasePadCoordinator Instance] connectionType] == BPC_ARCHIVE_CONNECTION_)
	{
		NSString * urlString = [[BasePadCoordinator Instance] getVideoArchiveName];
		if(urlString && [urlString length] > 0)
			url = [NSURL fileURLWithPath:urlString];	// auto released
		
		movieType = MOVIE_TYPE_ARCHIVE_;
	}
	
	return url;
	
}

- (NSURL *)getAudioURL
{
	NSURL * url = nil;;
	
	// Only applicable for archive name
	if([[BasePadCoordinator Instance] connectionType] == BPC_ARCHIVE_CONNECTION_)
	{
		NSString * urlString = [[BasePadCoordinator Instance] getAudioArchiveName];
		if(urlString && [urlString length] > 0)
			url = [NSURL fileURLWithPath:urlString];	// auto released
	}
	
	return url;
	
}

////////////////////////////////////////////////////////////////////////////
// Movie controls
////////////////////////////////////////////////////////////////////////////

- (void) moviePrepareToPlay
{
}

- (void) moviePlayAtRate:(float)playbackRate
{
	[movieSource moviePlayAtRate:playbackRate];
}

- (void) moviePlay
{
	[movieSource moviePlay];
}

- (void) movieStop
{
	[movieSource movieStop];
}

- (void) movieGotoTime:(float)time
{
	[movieSource movieGotoTime:time];
}

- (void) movieGoLive
{
	[movieSource movieGoLive];
}

- (void) movieSeekToLive
{
	[movieSource movieSeekToLive];
}

- (void) movieResyncLive
{
	[movieSource movieResyncLive];
}

- (void) startLivePlayTimer;
{
	if(movieType == MOVIE_TYPE_LIVE_STREAM_)
	{
		// A 5 second timer kicked off at start of live play.
		// Stream will resync on expiration.
		[self stopPlayTimers];
		
		playStartTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(playStartTimerExpired:) userInfo:nil repeats:NO];
		
		if(registeredViewController)
			[registeredViewController showLoadingIndicators];
	}
}

- (void) stopPlayTimers
{
	if(playStartTimer)
	{
		[playStartTimer invalidate];
		playStartTimer = nil;
	}
	
	if(playTimer)
	{
		[playTimer invalidate];
		playTimer = nil;
	}
	
	if(moviePlayElapsedTime)
	{
		[moviePlayElapsedTime release];
		moviePlayElapsedTime = nil;
	}
	
	if(registeredViewController)
		[registeredViewController hideLoadingIndicators];
}

- (void) playStartTimerExpired: (NSTimer *)theTimer
{
	// If there is a go live or play still pending, just kick off the timer again
	if([movieSource movieGoLivePending] || [movieSource moviePlayPending])
	{
		[self startLivePlayTimer];
		return;
	}
	
	// Re-syncs play back in live mode, then kicks off regular timer to keep track of sync
	[self movieResyncLive];
	
	if(registeredViewController)
		[registeredViewController hideLoadingIndicators];
	
	playStartTimer = nil;
	
	if(moviePlayElapsedTime)
		[moviePlayElapsedTime release];
	
	moviePlayElapsedTime = [[ElapsedTime alloc] init];
	
	if(playTimer)
		[playTimer invalidate];
	
	playTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(livePlayTimerFired:) userInfo:nil repeats:YES];
}

- (void) livePlayTimerFired: (NSTimer *)theTimer
{
	if([[BasePadCoordinator Instance] liveMode])
	{
		// Check the player status is still OK
		if(![movieSource moviePlayable])
		{
			[self restartConnection];
			return;
		}
		
		// Then check time hasn't slipped
		float timeNow = [moviePlayElapsedTime value];
		if(![movieSource moviePlayingRealTime:timeNow])
		{
			[self restartConnection];
		}
		
		resyncCount = [movieSource resyncCount];
		liveVideoDelay = [movieSource liveVideoDelay];
		
		if(registeredViewController)
			[registeredViewController notifyMovieInformation];
		
	}
}

- (void) restartConnection
{
	[self movieStop];
	[self stopPlayTimers];
	
	[self disconnectVideoServer];
	[self connectToVideoServer];
	
	[self movieGoLive];
	[self moviePlay];
	
	[self startLivePlayTimer];
	
	restartCount++;
}

////////////////////////////////////////////////////////////////////////
//  Audio controls

- (void) audioPlayAtRate:(float)playbackRate
{
	if(audioSource)
	{
		// ONLY AVAILABLE IN IOS 5.0 : [audioPlayer setRate:playbackRate];
		[audioSource audioPlayAtRate:playbackRate];
	}
}

- (void) audioPlay
{
	if(audioSource)
	{
		[audioSource audioPlay];
	}
}

- (void) audioStop
{
	if(audioSource)
	{
		[audioSource audioStop];
	}
}

- (void) audioGotoTime:(float)time

{
	if(audioSource)
	{
		[audioSource audioGotoTime:time];
	}
}

- (void) audioPrepareToPlay
{
	if(audioSource)
	{
		[audioSource audioPrepareToPlay];
	}
}

////////////////////////////////////////////////////////////////////////
//  View Controller registration

-(void)RegisterViewController:(BasePadVideoViewController *)view_controller
{
	// If nil is passed, just release any existing one
	if(!view_controller)
	{
		[registeredViewController release];
		registeredViewController = nil;
		return;
	}
	
	id old_registered_view_controller = registeredViewController;
	
	registeredViewController = [view_controller retain];
	
	if(old_registered_view_controller)
		[old_registered_view_controller release];
	
	[movieSource setMoviePausedInPlace:false];
	[movieSource setMovieActive:true];
	
	if([movieSource movieLoaded])
	{
		[registeredViewController displayMovieInView];
	}
}

-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller
{
	if(registeredViewController && registeredViewController == view_controller)
	{
		[self stopPlayTimers];
		
		[self movieStop];	
		[registeredViewController removeMovieFromView];
		
		[registeredViewController release];
		registeredViewController = nil;
		
		[movieSource setMoviePausedInPlace:false];
		[movieSource setMovieActive:false];
		[movieSource setMovieMarkedPlayable:false];
	}
}


////////////////////////////////////////////////////////////////////////
//  Response to notifications

-(void)notifyNewVideoSource:(BasePadVideoSource *)videoSource
{
	// Position the movie and order the overlay in any registered view controller
	if(registeredViewController)
		[registeredViewController displayMovieInView];
	
	if(movieType == MOVIE_TYPE_LIVE_STREAM_)
	{
		[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_SUCCEEDED_];
	}
	else
	{
		[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_NO_CONNECTION_];
	}
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	currentStatus = BPM_CONNECTED_;
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
}

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:error
{
	// Deal with the error appropriately.
	currentStatus = BPM_CONNECTION_FAILED_;
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	currentError = [error retain];
	
	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_FAILED_];
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
}

-(void)notifyUnloadingVideoSource:(BasePadVideoSource *)videoSource
{
	// Delete any existing player and assets	
	if(registeredViewController)
		[registeredViewController removeMovieFromView];
	
	[[BasePadCoordinator Instance] setVideoConnectionType:BPC_NO_CONNECTION_];
	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_NO_CONNECTION_];
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
}


-(void)notifyVideoSourceConnecting:(BasePadVideoSource *)videoSource showIndicators:(bool)showIndicators
{
	if(registeredViewController)
	{
		if(showIndicators)
			[registeredViewController showLoadingIndicators];
		else
			[registeredViewController hideLoadingIndicators];
	}
}

-(void)notifyMovieInformation
{
	if(registeredViewController)
		[registeredViewController notifyMovieInformation];
}


@end
