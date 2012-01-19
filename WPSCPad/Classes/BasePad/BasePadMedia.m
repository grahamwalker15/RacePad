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

@synthesize liveVideoDelay;

@synthesize restartCount;
@synthesize resyncCount;

@synthesize currentMovieRoot;
@synthesize currentAudioRoot;
@synthesize currentMovieType;

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
		currentMovieRoot = nil;
		currentAudioRoot = nil;
		currentMovieType = MOVIE_TYPE_NONE_;
		
		currentStatus = BPM_NOT_CONNECTED_;
		currentError = nil;
		
		for(int i = 0 ; i < BPM_MAX_VIDEO_STREAMS ; i++)
			movieSources[i] = [[BasePadVideoSource alloc] init];
		
		movieSourceCount = 0;
		
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
	for(int i = 0 ; i < BPM_MAX_VIDEO_STREAMS ; i++)
	{
		if(movieSources[i])
		{
			[movieSources[i] release];
			movieSources[i] = nil;
		}
	}
	
	if(audioSource)
	{
		[audioSource release];
		audioSource= nil;
	}
	
	[currentMovieRoot release];
	currentMovieRoot = nil;
	
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
	
	for(int i = 0 ; i < BPM_MAX_VIDEO_STREAMS ; i++)
	{
		[movieSources[i] resetConnectionCounts];
	}
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
	for(int i = 0 ; i < BPM_MAX_VIDEO_STREAMS ; i++)
	{
		if(movieSources[i])
		{
			[movieSources[i] unloadMovie];
		}
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
		if(!currentMovieRoot || [newMovie compare:currentMovieRoot] != NSOrderedSame )
		{
			currentMovieRoot = [newMovie retain];
			
			for(int i = 0 ; i < movieSourceCount ; i++)
				[movieSources[i] unloadMovie];

			// If we have a video list, pass this on to the parser, else load directly here
			if([currentMovieRoot hasSuffix:@".vls"])
			{
				[self loadVideoList:currentMovieRoot];
			}
			else
			{
				[movieSources[0] loadMovie:url ShouldDisplay:true];
				movieSourceCount = 1;
			}

		}
	}
	else
	{
		for(int i = 0 ; i < movieSourceCount ; i++)
			[movieSources[i] unloadMovie];
		
		movieSourceCount = 0;
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

- (BasePadVideoSource *)movieSource:(int)index
{
	if(index >= 0 && index < movieSourceCount)
		return movieSources[index];

	return nil;
}

- (BasePadVideoSource *)findMovieSourceByTag:(NSString *)tag
{
	if(movieSourceCount > 0)
	{
		for(int i = 0 ; i < movieSourceCount ; i++)
		{
			if([[movieSources[i] movieTag] compare:tag] == NSOrderedSame)
				return movieSources[i];
		}
	}
	
	return nil;
}



- (int)getMovieType
{
	// Live stream or archive name
	if ( [[BasePadCoordinator Instance] connectionType] != BPC_ARCHIVE_CONNECTION_ && [[BasePadCoordinator Instance] videoConnectionType] == BPC_VIDEO_LIVE_CONNECTION_)
	{
		return MOVIE_TYPE_LIVE_STREAM_;
	}
	else if([[BasePadCoordinator Instance] connectionType] == BPC_ARCHIVE_CONNECTION_)
	{
		return MOVIE_TYPE_ARCHIVE_;
	}
	
	return MOVIE_TYPE_NONE_;
	
}

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
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] moviePlayAtRate:playbackRate];
	}
}

- (void) moviePlay
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] moviePlay];
	}
}

- (void) movieStop
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] movieStop];
	}
}

- (void) movieGotoTime:(float)time
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] movieGotoTime:time];
	}
}

- (void) movieGoLive
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] movieGoLive];
	}
}

- (void) movieSeekToLive
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] movieSeekToLive];
	}
}

- (void) movieResyncLive
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] movieResyncLive];
	}
}

- (void) setMoviePlaying:(bool)value
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] setMoviePlaying:value];
	}
}

- (void) setMoviePausedInPlace:(bool)value
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] setMoviePausedInPlace:value];
	}
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
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieGoLivePending] || [movieSources[i] moviePlayPending])
		{
			[self startLivePlayTimer];
			return;
		}
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
		for(int i = 0 ; i < movieSourceCount ; i++)
		{
			// Check the player status is still OK
			if(![movieSources[i] moviePlayable])
			{
				[self restartConnection];
				return;
			}
		
			// Then check time hasn't slipped
			float timeNow = [moviePlayElapsedTime value];
			if([movieSources[i] movieDisplayed] && ![movieSources[i] moviePlayingRealTime:timeNow])
			{
				[self restartConnection];
			}
		}
			
		resyncCount = [movieSources[0] resyncCount];
		liveVideoDelay = [movieSources[0] liveVideoDelay];
		
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
	
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		[movieSources[i] setMoviePausedInPlace:false];
		[movieSources[i]  setMovieActive:true];

		if([movieSources[i] movieLoaded])
		{
			[registeredViewController displayMovieSource:movieSources[i]];		}
	}
}

-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller
{
	if(registeredViewController && registeredViewController == view_controller)
	{
		[self stopPlayTimers];
		
		[self movieStop];	
		[registeredViewController removeMoviesFromView];
		
		[registeredViewController release];
		registeredViewController = nil;
		
		for(int i = 0 ; i < movieSourceCount ; i++)
		{
			[movieSources[i] setMoviePausedInPlace:false];
			[movieSources[i] setMovieActive:false];
			[movieSources[i] setMovieMarkedPlayable:false];
		}
	}
}


////////////////////////////////////////////////////////////////////////
//  Response to notifications

-(void)notifyNewVideoSource:(BasePadVideoSource *)videoSource ShouldDisplay:(bool)shouldDisplay
{
	// Position the movie and order the overlay in any registered view controller
	if(shouldDisplay && registeredViewController)
		[registeredViewController displayMovieSource:videoSource];
	
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
	
	[currentMovieRoot release];
	currentMovieRoot = nil;

	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_FAILED_];
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
}

-(void)notifyUnloadingVideoSource:(BasePadVideoSource *)videoSource
{
	// Delete any existing player and assets	
	if(registeredViewController)
		[registeredViewController removeMovieFromView:videoSource];
	
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


///////////////////////////////////////////////////////////////////
//  Video file i/o

- (void) loadVideoList:(NSString *)fileName
{
	movieSourceCount = 0;
	
	FILE * listFile;
	NSString * fileString = [[BasePadCoordinator Instance] getVideoArchiveName];
	listFile = fopen([fileString fileSystemRepresentation], "rt" );
	if ( listFile )
	{
		char keyword[128];
		char stringValue[256];
		int movieStartTime;
		int movieLoop;
		
		while(true)
		{
			if ( fscanf(listFile, "%128s", keyword ) != 1 )
				break;
			
			if ( strcmp ( keyword, "@videofile" ) != 0 )
				break;

			if ( fscanf(listFile, "%128s", stringValue ) != 1 )
				break;
			
			NSString * urlString = [[BasePadCoordinator Instance] getVideoArchiveRoot];
			urlString = [urlString stringByAppendingPathComponent:[NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding]];
			NSURL * url = [NSURL fileURLWithPath:urlString];	// auto released
			
			if ( fscanf(listFile, "%128s %d", keyword, &movieStartTime ) != 2 )
				break;
			
			if ( fscanf(listFile, "%128s %d", keyword, &movieLoop ) != 2 )
				break;
			
			if ( fscanf(listFile, "%128s %128s", keyword, stringValue ) != 2 )
				break;
			
			NSString * movieTag = [NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding];
			
			if ( fscanf(listFile, "%128s", keyword ) != 1 )
				break;
			
			if ( strcmp ( keyword, "@end" ) == 0 )
			{
				[movieSources[movieSourceCount] loadMovie:url ShouldDisplay:(movieSourceCount == 0)];	// Displays first one
				[movieSources[movieSourceCount] setStartTime:movieStartTime];
				[movieSources[movieSourceCount] setMovieLoop:(movieLoop > 0)];
				[movieSources[movieSourceCount] setMovieTag:movieTag];
				movieSourceCount++;
			}
			else
			{
				break;
			}
		}
		
		fclose(listFile);
	}
}

@end
