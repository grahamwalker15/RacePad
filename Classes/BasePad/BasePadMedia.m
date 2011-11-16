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

@synthesize moviePlayerAsset;
@synthesize moviePlayerItem;
@synthesize moviePlayer;
@synthesize moviePlayerLayer;

@synthesize audioPlayer;

@synthesize moviePlayerObserver;

@synthesize movieStartTime;
@synthesize movieSeekTime;
@synthesize liveVideoDelay;

@synthesize restartCount;
@synthesize resyncCount;

@synthesize currentMovie;
@synthesize currentAudio;
@synthesize currentStatus;
@synthesize currentError;

@synthesize movieLoaded;
@synthesize moviePlayPending;
@synthesize movieSeekable;
@synthesize movieSeekPending;
@synthesize moviePausedInPlace;

@synthesize movieType;

@synthesize audioPlayPending;
@synthesize audioSeekPending;
@synthesize audioStartTime;

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
		currentMovie = nil;
		
		currentStatus = BPM_NOT_CONNECTED_;
		currentError = nil;
		
		moviePlayer = nil;
		moviePlayerItem = nil;
		moviePlayerAsset = nil;
		moviePlayerLayer = nil;
		moviePlayerObserver = nil;
		
		audioPlayer = nil;
		
		moviePlayPending = false;
		movieSeekable = false;
		movieSeekPending = false;
		movieGoLivePending = false;
		movieLoaded = false;
		moviePlayable = false;
		moviePlayAllowed = false;
		
		moviePausedInPlace = false;
		
		movieStartTime = 0.0;
		movieSeekTime = 0.0;
		streamSeekStartTime = 0.0;
		
		audioPlayPending = false;
		audioSeekPending = false;
		
		audioStartTime = 0.0;

		activePlaybackRate = 1.0;
		liveVideoDelay = 0.0;
		
		restartCount = 0;
		resyncCount = 0;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		lastLiveVideoDelay = 0.0;
		
		moviePlayElapsedTime = nil;
		
		movieRecentlyResynced = false;
		
		playStartTimer = nil;
		playTimer = nil;
		
		movieType = MOVIE_TYPE_NONE_;
	}
	
	return self;
}


- (void)dealloc
{
	if(movieLoaded)
		[self unloadMovie];
	
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
	if(movieLoaded)
		[self unloadMovie];
	
	movieType = MOVIE_TYPE_NONE_;
	
	currentStatus = BPM_NOT_CONNECTED_;
	
	moviePlayable = false;
	
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
		if(!currentMovie || [newMovie compare:currentMovie] != NSOrderedSame )
		{
			[self loadMovie:url];
		}
	}
	else
	{
		if(movieLoaded)
			[self unloadMovie];
		
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
		if(!currentAudio || [newAudio compare:currentAudio] != NSOrderedSame )
		{
			[self loadAudio:url];
		}
	}
	else
	{
		[self unloadAudio];
	}
}

////////////////////////////////////////////////////////////////////////////
// Movie loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadMovie:(NSURL *)url
{
	if(movieLoaded)
		[self unloadMovie];
	
	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_CONNECTING_];
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
	moviePlayerAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
	
	NSString *tracksKey = @"tracks";
	
	[moviePlayerAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
	 ^{
		 // Completion handler block.
		 
		 NSError *error = nil;
		 AVKeyValueStatus status = [moviePlayerAsset statusOfValueForKey:tracksKey error:&error];
		 
		 if (status == AVKeyValueStatusLoaded)
		 {
			 moviePlayerItem = [[AVPlayerItem alloc] initWithAsset:moviePlayerAsset];
			 
			 [moviePlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
			 
			 moviePlayer = [[AVPlayer alloc] initWithPlayerItem:moviePlayerItem];
			 [moviePlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
			 
			 // Register a time observer to get the current time while playing
			 movieStartTime = -1.0;
			 moviePlayerObserver = [moviePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:nil usingBlock:^(CMTime time){[self timeObserverCallback:time];}];
			 [moviePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
			 
			 // Make a movie player layer to receive the movie
			 if(!moviePlayerLayer)
			 {
				 moviePlayerLayer = [[AVPlayerLayer playerLayerWithPlayer:moviePlayer] retain];
				 [moviePlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
			 }
			 
			 // Position the movie and order the overlay in any registered view controller
			 if(registeredViewController)
				 [registeredViewController displayMovieInView];
			 
			 movieLoaded = true;
			 currentMovie = [[url absoluteString] retain];
			 
			 currentStatus = BPM_CONNECTED_;
			 
			 if(movieType == MOVIE_TYPE_LIVE_STREAM_)
			 {
				 [[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_SUCCEEDED_];
			 }
			 else
			 {
				 [[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_NO_CONNECTION_];
			 }
			 
			 [[BasePadCoordinator Instance] videoServerOnConnectionChange];
			 
			 moviePausedInPlace= false;
		 }
		 else
		 {
			 // Deal with the error appropriately.
			 currentStatus = BPM_CONNECTION_FAILED_;
			 
			 if(currentError)
			 {
				 [currentError release];
				 currentError = nil;
			 }
			 
			 if(error)
			 {
				 NSString * description = [NSString stringWithString:[error localizedDescription]];
				 
				 if(description)
				 {
					 if([error localizedFailureReason])
					 {
						 description = [description stringByAppendingString:@" - "];
						 description = [description stringByAppendingString:[error localizedFailureReason]];
						 
					 }
					 
					 currentError = [description retain];
				 }
				 
			 }
			 
			 [[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_CONNECTION_FAILED_];
			 
			 [[BasePadCoordinator Instance] videoServerOnConnectionChange];
			 
			 [currentMovie release];
			 currentMovie = nil;
		 }
	 }
	 ];
}

- (void) unloadMovie
{
	// Delete any existing player and assets	
	if(registeredViewController)
		[registeredViewController removeMovieFromView];
	
	if(moviePlayerObserver)
	{
		[moviePlayer removeTimeObserver:moviePlayerObserver];
		moviePlayerObserver = nil;
	}
	
	if(moviePlayerItem)
	{
		[moviePlayerItem removeObserver:self forKeyPath:@"status"];
	}
	
	if(moviePlayer)
	{
		[moviePlayer removeObserver:self forKeyPath:@"status"];
	}
	
	[moviePlayerLayer release];
	[moviePlayer release];
	[moviePlayerItem release];
	[moviePlayerAsset release];
	
	moviePlayerLayer = nil;
	moviePlayer = nil;
	moviePlayerItem = nil;
	moviePlayerAsset = nil;
	
	moviePlayPending = false;
	movieSeekable = false;
	moviePlayable = false;
	movieSeekPending = false;
	movieLoaded =false;
	moviePausedInPlace = false;
	
	movieStartTime = 0.0;
	streamSeekStartTime = 0.0;
	
	[[BasePadCoordinator Instance] setVideoConnectionType:BPC_NO_CONNECTION_];
	[[BasePadCoordinator Instance] setVideoConnectionStatus:BPC_NO_CONNECTION_];
	
	movieType = MOVIE_TYPE_NONE_;
	
	[currentMovie release];
	currentMovie = nil;
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
}

////////////////////////////////////////////////////////////////////////////
// Audio loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadAudio:(NSURL *)url
{
	[self unloadAudio];
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	
	if(audioPlayer)
	{
		//[audioPlayer setEnableRate:true];
		//[audioPlayer set setE:true];
		
		currentAudio = [[url absoluteString] retain];
		
		// Try to find a meta file
		NSString *metaFileName = [currentAudio stringByReplacingOccurrencesOfString:@".mp3" withString:@".amd"];
		FILE *metaFile = fopen([metaFileName UTF8String], "rt" );
		if ( metaFile )
		{
			char keyword[128];
			int value;
			if ( fscanf(metaFile, "%128s %d", keyword, &value ) == 2 )
				if ( strcmp ( keyword, "AudioStartTime" ) == 0 )
					audioStartTime = value;
			fclose(metaFile);
		}
		
	}

}

- (void) unloadAudio
{
	if(audioPlayer)
	{
		[audioPlayer release];
		
		audioPlayer = nil;

		audioPlayPending = false;
		audioSeekPending = false;

		audioStartTime = 0.0;
		
		[currentAudio release];
		currentAudio = nil;
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

- (void) getStartTime
{
	if ( [[BasePadCoordinator Instance] connectionType] != BPC_ARCHIVE_CONNECTION_ && [[BasePadCoordinator Instance] videoConnectionType] == BPC_VIDEO_LIVE_CONNECTION_)
	{
        AVPlayerItem * item = [moviePlayer currentItem];
		
		if(item)
		{
			//CMTime currentCMTime = [item currentTime];
			CMTime currentCMTime = [moviePlayer currentTime];			
			
			float currentMovieTime = 0.0;
			
			if(CMTIME_IS_VALID(currentCMTime)  && CMTIME_IS_NUMERIC(currentCMTime))
			{
				currentMovieTime = (float) CMTimeGetSeconds(currentCMTime);
			}
			
			NSArray *seekableTimeRanges = [item seekableTimeRanges];
			
			if([seekableTimeRanges count] > 0)
			{
				NSValue * value = [seekableTimeRanges objectAtIndex:0];
				CMTimeRange range;
				[value getValue:&range];
								
				if(CMTIME_IS_VALID(range.duration)  && CMTIME_IS_NUMERIC(range.duration))
				{
					float duration = (float) CMTimeGetSeconds( range.duration );
					float streamStartTime = CMTimeGetSeconds( range.start );
					float timeNow = (float)[ElapsedTime LocalTimeOfDay];
					float startTime = timeNow - duration;
					
					if(duration > 0.0)
					{
						currentMovieTime -= streamStartTime;

						streamSeekStartTime = streamStartTime;
						
						if(!movieSeekable || startTime < movieStartTime)
						{
							movieStartTime = startTime;
							
							movieSeekable= true;
							
							if(movieSeekPending)
							{
								if(movieSeekTime < 0)
									[self movieSeekToLive];
								else
									[self movieGotoTime:movieSeekTime];
							}		
						}
						
						currentMovieTime += movieStartTime;
						
					}

				}
			}
		}
		else
		{
			// Item is nil
			// Try to re-connect current item to player
			[moviePlayer replaceCurrentItemWithPlayerItem:moviePlayerItem];
		}
	}
	else if(movieStartTime < 0.0)	// Archive & we haven't read metadata yet
	{
		// Try to find a meta file
		NSString * urlString = [[BasePadCoordinator Instance] getVideoArchiveName];
		NSString *metaFileName = [urlString stringByReplacingOccurrencesOfString:@".m4v" withString:@".vmd"];
		metaFileName = [metaFileName stringByReplacingOccurrencesOfString:@".mp4" withString:@".vmd"];
		FILE *metaFile = fopen([metaFileName UTF8String], "rt" );
		if ( metaFile )
		{
			char keyword[128];
			int value;
			if ( fscanf(metaFile, "%128s %d", keyword, &value ) == 2 )
				if ( strcmp ( keyword, "VideoStartTime" ) == 0 )
					movieStartTime = value;
			fclose(metaFile);
		}
		
		if ( movieStartTime < 0 )
		{
			// Default to hard coded start time
			movieStartTime = 13 * 3600.0 + 43 * 60.0 + 40;
		}
		
		movieSeekable= true;
		
		if(movieSeekPending)
		{
			if(movieSeekTime < 0)
				[self movieSeekToLive];
			else
				[self movieGotoTime:movieSeekTime];
		}		
	}
}

////////////////////////////////////////////////////////////////////////////
// Movie controls
////////////////////////////////////////////////////////////////////////////

- (void) movieSetStartTime:(float)time
{
	movieStartTime = time;
}

- (void) moviePrepareToPlay
{
}

- (void) moviePlayAtRate:(float)playbackRate
{
	activePlaybackRate = playbackRate;
	
	if([self moviePlayable] && registeredViewController)
	{
		[moviePlayer setRate:activePlaybackRate];
		moviePlayPending = false;
		moviePausedInPlace = false;
	}
	else
	{
		moviePlayPending = true;
	}
}

- (void) moviePlay
{
	[self moviePlayAtRate:activePlaybackRate];
}

- (void) movieStop
{
	moviePausedInPlace = true;
	[moviePlayer pause];	
	moviePlayPending = false;
	movieGoLivePending = false;
}

- (void) movieGotoTime:(float)time
{
	if(movieSeekable && registeredViewController)
	{
		Float64 movie_time = time - movieStartTime;
		CMTime currentMovieTime = [moviePlayer currentTime];
		Float64 currentMovieTimeSeconds = CMTimeGetSeconds(currentMovieTime);
		
		if(movieType == MOVIE_TYPE_LIVE_STREAM_)
			movie_time = movie_time + streamSeekStartTime - [[BasePadCoordinator Instance] serverTimeOffset];
			
		// Shouldn't need to do anything if we're just continuing after a clean pause
		if(moviePausedInPlace && fabs(movie_time - currentMovieTimeSeconds) < 0.8)
			return;
		
		NSArray *seekableTimeRanges = [moviePlayerItem seekableTimeRanges];
		
		if([seekableTimeRanges count] > 0)
		{
			NSValue * value = [seekableTimeRanges objectAtIndex:0];
			CMTimeRange range;
			[value getValue:&range];
			
			if(CMTIME_IS_VALID(range.start)  && CMTIME_IS_NUMERIC(range.start) && CMTIME_IS_VALID(range.duration)  && CMTIME_IS_NUMERIC(range.duration)  )
			{
				float rangeStartTime = (float) CMTimeGetSeconds( range.start );
				float rangeDuration = (float) CMTimeGetSeconds( range.duration );
				
				if(movie_time < rangeStartTime)
					movie_time = rangeStartTime;
				else if(movie_time > rangeStartTime + rangeDuration)
					movie_time = rangeStartTime + rangeDuration;
				
				CMTime cm_time = CMTimeMakeWithSeconds(movie_time, 600);
				
				if(CMTIME_IS_VALID(cm_time)  && CMTIME_IS_NUMERIC(cm_time))
				{
					[moviePlayer seekToTime:cm_time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			}
		}

		movieSeekPending = false;
	}
	else
	{
		movieSeekPending = true;
		movieSeekTime = time;
	}
	
}

- (void) movieGoLive
{
	if(!moviePlayer || !moviePlayerItem)
	{
		movieGoLivePending = true;
		return;
	}
	
	if(moviePlayer && [moviePlayer status] != AVPlayerItemStatusReadyToPlay)
	{
		movieGoLivePending = true;
		return;
	}
	
	if(moviePlayerItem && [moviePlayerItem status] != AVPlayerItemStatusReadyToPlay)
	{
		movieGoLivePending = true;
		return;
	}
	
	[self movieSeekToLive];
	
	movieGoLivePending = false;

}

- (void) movieSeekToLive
{
	if(!moviePlayer || !moviePlayerItem)
	{
		movieSeekPending = true;
		movieSeekTime = -1.0;
		return;
	}
	
	if(moviePlayer && [moviePlayer status] != AVPlayerItemStatusReadyToPlay)
	{
		movieSeekPending = true;
		movieSeekTime = -1.0;
		return;
	}
	
	if(moviePlayerItem && [moviePlayerItem status] != AVPlayerItemStatusReadyToPlay)
	{
		movieSeekPending = true;
		movieSeekTime = -1.0;
		return;
	}
	
	if(movieSeekable && registeredViewController)
	{
		[moviePlayer seekToTime:kCMTimePositiveInfinity];
		
		movieSeekPending = false;
		moviePausedInPlace = false;
	}
	else
	{
		movieSeekPending = true;
		movieSeekTime = -1.0;
	}
	
}

- (void) movieResyncLive
{
	if([[BasePadCoordinator Instance] liveMode])
	{
		[self movieStop];
		[self movieGoLive];
		[self moviePlay];
	}

	movieRecentlyResynced = true;
}

- (bool) moviePlayable
{
	if(!moviePlayer || [moviePlayer status] != AVPlayerItemStatusReadyToPlay)
	{
		return false;
	}
	
	if(!moviePlayerItem || [moviePlayerItem status] != AVPlayerItemStatusReadyToPlay)
	{
		return false;
	}
	
	return true;
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
	if(movieGoLivePending || moviePlayPending)
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
	movieRecentlyResynced = true;
}

- (void) livePlayTimerFired: (NSTimer *)theTimer
{
	if([[BasePadCoordinator Instance] liveMode])
	{
		// Check the player status is still OK
		if(![self moviePlayable])
		{
			[self restartConnection];
			return;
		}
				
		// Then check time hasn't slipped
		CMTime currentCMTime = [moviePlayer currentTime];
		if(CMTIME_IS_VALID(currentCMTime)  && CMTIME_IS_NUMERIC(currentCMTime))
		{
			Float64 moviePlayTime = CMTimeGetSeconds(currentCMTime);
			
			if(moviePlayTime > 0.0)
			{
				float timeNow = [moviePlayElapsedTime value];
						 
				if(movieRecentlyResynced)
				{
					lastMoviePlayTime = moviePlayTime;
					lastResyncTime = timeNow;
					lastLiveVideoDelay = liveVideoDelay;
					liveVideoDelay = 0.0;
					movieRecentlyResynced = false;
				}
				else
				{
					float elapsedTime = timeNow - lastResyncTime;
					float playedTime = moviePlayTime - lastMoviePlayTime;
					liveVideoDelay = elapsedTime > playedTime ? elapsedTime - playedTime : 0.0;
					if(liveVideoDelay > 2.0)
					{
						[self movieResyncLive];
						resyncCount ++;
					}
				}

				if(registeredViewController)
					[registeredViewController notifyMovieInformation];
				
				return;
			}
		}
		
		// Fall through to here if live and time is not valid
		[self restartConnection];

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
	if(audioPlayer)
	{
		[audioPlayer setRate:playbackRate];
		[audioPlayer play];
	}
}

- (void) audioPlay
{
	if(audioPlayer)
	{
		[audioPlayer play];
	}
}

- (void) audioStop
{
	if(audioPlayer)
	{
		[audioPlayer pause];
	}
}

- (void) audioGotoTime:(float)time

{
	if(audioPlayer)
	{
		Float64 audioTime = time - audioStartTime;
		
		double duration = [audioPlayer duration];
		if(audioTime > duration)
			audioTime = duration;
		else if(audioTime < 0.0)
			audioTime = 0.0;
		
		[audioPlayer setCurrentTime:(NSTimeInterval)audioTime];
	}
}

- (void) audioPrepareToPlay
{
	if(audioPlayer)
	{
		[audioPlayer prepareToPlay];
	}
}

////////////////////////////////////////////////////////////////////////
//  Callback functions

- (void) timeObserverCallback:(CMTime) cmTime
{
	if(moviePlayerObserver)
	{
		AVPlayerItemStatus status = [moviePlayer status];
		if(status ==  AVPlayerItemStatusFailed)
		{
			NSError * error = [moviePlayer error];
			
			if(currentError)
			{
				[currentError release];
				currentError = nil;
			}
			
			if(error)
			{
				NSString * description = [NSString stringWithString:[error localizedDescription]];
				
				if(description)
				{
					if([error localizedFailureReason])
					{
						description = [description stringByAppendingString:@" - "];
						description = [description stringByAppendingString:[error localizedFailureReason]];
					}
					
					currentError = [description retain];
				}
				
			}
			
			[[BasePadCoordinator Instance] videoServerOnConnectionChange];
		}

		if(movieStartTime < 0.001)
			[self getStartTime];
		
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(!object)
		return;
	
    if (object == moviePlayerItem)
	{
		if([keyPath isEqualToString:@"status"])
		{
			int status = [object status];
			if(!moviePlayable && moviePlayAllowed && status == AVPlayerItemStatusReadyToPlay)
			{
				moviePlayable = [self moviePlayable];
				
				float time_of_day = [[BasePadCoordinator Instance] currentTime];
				[self getStartTime];
				
				if(movieGoLivePending)
				{
					[self movieGoLive];
				}
				
				if(movieType == MOVIE_TYPE_ARCHIVE_ || ![[BasePadCoordinator Instance] liveMode])
					[self movieGotoTime:time_of_day];
				
				if(moviePlayPending)
					[self moviePlay];
			}
			
			if(status ==  AVPlayerItemStatusFailed)
			{
				NSError * error = [object error];

				if(currentError)
				{
					[currentError release];
					currentError = nil;
				}
				
				if(error)
				{
					NSString * description = [NSString stringWithString:[error localizedDescription]];
					
					if(description)
					{
						if([error localizedFailureReason])
						{
							description = [description stringByAppendingString:@" - "];
							description = [description stringByAppendingString:[error localizedFailureReason]];
						}
						
						currentError = [description retain];
					}
				}
				
				[[BasePadCoordinator Instance] videoServerOnConnectionChange];
			}
		}
	}
	
	if (object == moviePlayer)
	{
		if([keyPath isEqualToString:@"status"])
		{
			if(!moviePlayable && moviePlayAllowed && [object status] == AVPlayerItemStatusReadyToPlay)
			{
				moviePlayable = [self moviePlayable];
				
				if(movieGoLivePending)
				{
					[self movieGoLive];
				}
				
				if(moviePlayPending)
					[self moviePlay];
			}
			
			if([object status] ==  AVPlayerItemStatusFailed)
			{
				NSError * error = [object error];

				if(currentError)
				{
					[currentError release];
					currentError = nil;
				}
				
				if(error)
				{
					NSString * description = [NSString stringWithString:[error localizedDescription]];
					
					if(description)
					{
						if([error localizedFailureReason])
						{
							description = [description stringByAppendingString:@" - "];
							description = [description stringByAppendingString:[error localizedFailureReason]];							
						}
						
						currentError = [description retain];
					}					
				}
				
				[[BasePadCoordinator Instance] videoServerOnConnectionChange];
			}
		}
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
	
	moviePausedInPlace = false;	
	moviePlayAllowed = true;
		
	if(movieLoaded)
	{
		[registeredViewController displayMovieInView];
	}
}

-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller
{
	if(registeredViewController && registeredViewController == view_controller)
	{
		[self stopPlayTimers];

		[moviePlayer pause];	
		[registeredViewController removeMovieFromView];
		
		[registeredViewController release];
		registeredViewController = nil;
		
		moviePausedInPlace = false;
		moviePlayable = false;
		moviePlayAllowed = false;
	}
}

@end
