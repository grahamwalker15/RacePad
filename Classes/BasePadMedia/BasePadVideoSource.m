//
//  BasePadVideoSource.m
//  RacePad
//
//  Created by Gareth Griffith on 12/13/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadCoordinator.h"
#import "BasePadMedia.h"
#import "ElapsedTime.h"
#import "MovieView.h"

#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVPlayerItemTrack.h>
#import <AVFoundation/AVAssetTrack.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVAudioMix.h>

@implementation BasePadVideoSource

@synthesize moviePlayerAsset;
@synthesize moviePlayerItem;
@synthesize moviePlayer;
@synthesize moviePlayerLayer;

@synthesize parentMovieView;

@synthesize moviePlayerObserver;

@synthesize movieStartTime;
@synthesize movieSeekTime;
@synthesize liveVideoDelay;

@synthesize movieLoop;
@synthesize movieForceLive;
@synthesize shouldAutoDisplay;

@synthesize resyncCount;

@synthesize currentMovie;
@synthesize movieURL;
@synthesize movieTag;
@synthesize movieName;
@synthesize movieThumbnail;

@synthesize currentStatus;
@synthesize currentError;

@synthesize movieLoaded;
@synthesize movieAttached;
@synthesize moviePlayPending;
@synthesize movieSeekable;
@synthesize movieSeekPending;
@synthesize movieGoLivePending;
@synthesize moviePausedInPlace;
@synthesize moviePlaying;
@synthesize movieInLiveMode;

@synthesize movieType;
@synthesize movieMarkedPlayable;
@synthesize movieActive;
@synthesize movieDisplayed;

-(id)init
{
	if(self = [super init])
	{
		movieActive = false;
		movieDisplayed = false;
		
		moviePlayer = nil;
		moviePlayerItem = nil;
		moviePlayerAsset = nil;
		moviePlayerLayer = nil;
		moviePlayerObserver = nil;
		
		moviePlayPending = false;
		movieSeekable = false;
		movieSeekPending = false;
		movieGoLivePending = false;
		movieLoaded = false;
		movieAttached = false;
		movieMarkedPlayable = false;
		
		moviePausedInPlace = false;
		moviePlaying = false;
		movieInLiveMode = false;
		
		movieStartTime = -1.0;
		movieSeekTime = 0.0;
		streamSeekStartTime = 0.0;
		
		movieLoop = false;
		movieForceLive = false;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		
		movieRecentlyResynced = false;
		
		movieType = MOVIE_TYPE_NONE_;
		currentMovie = nil;
		movieURL = nil;
		movieTag = nil;
		movieName = nil;
		movieThumbnail = nil;
		currentError = nil;
		
		errorTimer= nil;
		
        parentMovieView = nil;
		shouldAutoDisplay = false;
		
        requestedMovieView = nil;
        requestedShouldDisplay = false;
        
		loading = false;
		looping = false;
		liveVideoDelay = 0.0;
		
		restartCount = 0;
		resyncCount = 0;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		
		moviePlayElapsedTime = nil;
		
        verificationTimer = nil;
		playStartTimer = nil;
		playTimer = nil;
	}
	
	return self;
}


- (void)dealloc
{
	if(movieLoaded)
		[self unloadMovie];
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	if(movieThumbnail)
	{
		[movieThumbnail release];
		movieThumbnail = nil;
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
}

////////////////////////////////////////////////////////////////////////////
// Movie loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadMovie
{
	if(movieURL)
	{
		[self loadMovie:movieURL ShouldDisplay:shouldAutoDisplay InMovieView:nil];
	}
}

- (void) loadMovieIntoView:(MovieView *)movieView
{
	if(movieURL)
	{
		[self loadMovie:movieURL ShouldDisplay:true InMovieView:movieView];
	}
}

- (void) loadMovie:(NSURL *)url ShouldDisplay:(bool)shouldDisplay InMovieView:(MovieView *)movieView
{
	if(movieLoaded)
		[self unloadMovie];
	
    if(requestedMovieView)
        [requestedMovieView release];
    
    requestedMovieView = [movieView retain];
    requestedShouldDisplay = shouldDisplay;
	
	moviePlayerAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
	
	currentMovie = [[url absoluteString] retain];
	
	[[BasePadMedia Instance] blockMovieLoadQueue];
	
	// Notify movie view that loading is starting
	if(movieView)
		[movieView notifyMovieAboutToShowSource:self];
	
	// Kick off a timer to fail if the connection doesn't get started within 25 secs
	errorTimer = [[NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(errorTimerExpired:) userInfo:nil repeats:NO] retain];
    
	loading = true;
	
	NSString *tracksKey = @"tracks";
	
	[moviePlayerAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
	 ^{
		 // Completion handler block.
		 
		 [self killErrorTimer];
		 
		 // Ignore this movie if we've called unload in the meantime
		 NSError *error = nil;
		 AVKeyValueStatus status = [moviePlayerAsset statusOfValueForKey:tracksKey error:&error];
		 
		 if (status == AVKeyValueStatusLoaded)
		 {
			 
			 moviePlayerItem = [[AVPlayerItem alloc] initWithAsset:moviePlayerAsset];
			 
			 moviePlayer = [[AVPlayer alloc] initWithPlayerItem:moviePlayerItem];
			 
			 if(movieLoop)
				 [moviePlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
			 else
				 [moviePlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
			 
			 if(shouldDisplay)
			 {
				 // Kick off a timer to fail if the connection doesn't complete within 15 secs
				 errorTimer = [[NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(errorTimerExpired:) userInfo:nil repeats:NO] retain];
                 
				 // Attach to a player
				 [self performSelectorOnMainThread:@selector(attachMovie) withObject:nil waitUntilDone:true];
			 }
			 
			 [self makeThumbnail];
			 
			 movieLoaded = true;
			 
			 moviePausedInPlace= false;
			 moviePlaying = false;
			              
             if([[BasePadMedia Instance] extendedNotification])
             {
                 currentStatus = BPM_WAITING_FOR_STREAM_;
                 [[BasePadMedia Instance] notifyNewVideoSource:self Status:BPM_WAITING_FOR_STREAM_ ShouldDisplay:shouldDisplay];
             }
         }
		 else
		 {
			 // Deal with the error appropriately.
			 currentStatus = BPM_CONNECTION_FAILED_;
			 
			 if(moviePlayerAsset)
			 {
				 [moviePlayerAsset release];
				 moviePlayerAsset = nil;
			 }
			 
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
			 
			 if(shouldDisplay && movieView)
				 [movieView notifyErrorOnVideoSource:self withError:currentError];
			 else
				 [[BasePadMedia Instance] notifyErrorOnVideoSource:self withError:currentError AutoRetry:false];
			 
			 [currentMovie release];
			 currentMovie = nil;
		 }
		 
		 [[BasePadMedia Instance] unblockMovieLoadQueue];
		 
		 loading = false;
		 
	 }
	 ];
}

- (void) unloadMovie
{
	if(loading)
	{
		[moviePlayerAsset cancelLoading];
		[[BasePadMedia Instance] unblockMovieLoadQueue];
		[currentMovie release];
		currentMovie = nil;
		loading = false;
		return;
	}
	
	if(!movieLoaded)
		return;
	
	if(movieAttached)
		[self detachMovie];
	
	[moviePlayer release];
	[moviePlayerItem release];
	[moviePlayerAsset release];
	
	moviePlayer = nil;
	moviePlayerItem = nil;
	moviePlayerAsset = nil;
	
	moviePlayPending = false;
	movieSeekable = false;
	movieMarkedPlayable = false;
	movieSeekPending = false;
	movieLoaded =false;
	moviePausedInPlace = false;
	moviePlaying = false;
	
	movieStartTime = -1.0;
	streamSeekStartTime = 0.0;
	
	shouldAutoDisplay = false;
	
	[currentMovie release];
	currentMovie = nil;
	
	loading = false;
	looping = false;
	
}

- (void) attachMovie
{
	// Register to observe status and add a time observer to get the current time while playing
	[moviePlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
	[moviePlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
	[moviePlayerItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:nil];
	[moviePlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
	[moviePlayerItem addObserver:self forKeyPath:@"tracks" options:0 context:nil];
	
	moviePlayerObserver = [moviePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(5.0, 1) queue:nil usingBlock:^(CMTime time){[self timeObserverCallback:time];}];
	[moviePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
	
	// Add an observer for when it reaches the end
	// If we are looping, this will restart the movie
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification object:moviePlayerItem];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToReachEnd:)
												 name:AVPlayerItemFailedToPlayToEndTimeNotification object:moviePlayerItem];
	
	
	// Make a movie player layer to receive the movie
	if(!moviePlayerLayer)
	{
		moviePlayerLayer = [[AVPlayerLayer playerLayerWithPlayer:moviePlayer] retain];
		[moviePlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
		[moviePlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
	}
	
	moviePausedInPlace= false;
	moviePlaying = false;
	
	movieAttached = true;
    
    [self checkForReadyToPlay];
    [self performSelectorOnMainThread:@selector(startVerificationTimer) withObject:nil waitUntilDone:true];
    
}

- (void) detachMovie
{
	if(verificationTimer)
	{
		[verificationTimer invalidate];
		verificationTimer = nil;
	}
    
    if(playTimer)
    {
		[playTimer invalidate];
        playTimer = nil;
    }
    
    if(playStartTimer)
    {
		[playStartTimer invalidate];
        playStartTimer = nil;
    }
	
	if(moviePlayerObserver)
	{
		[moviePlayer removeTimeObserver:moviePlayerObserver];
		moviePlayerObserver = nil;
	}
	
	if(moviePlayerItem)
	{
		[moviePlayerItem removeObserver:self forKeyPath:@"status"];
		[moviePlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
		[moviePlayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
		[moviePlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
		[moviePlayerItem removeObserver:self forKeyPath:@"tracks"];
	}
	
	if(moviePlayer)
	{
		[moviePlayer removeObserver:self forKeyPath:@"status"];
	}
	
	if(moviePlayerLayer)
	{
		[moviePlayerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[moviePlayerLayer release];
	moviePlayerLayer = nil;
	
	moviePlayPending = false;
	movieMarkedPlayable = false;
	movieSeekPending = false;
	moviePausedInPlace = false;
	moviePlaying = false;
	
	movieAttached = false;
	
	loading = false;
	looping = false;
	
}

-(void)makeThumbnail
{
    if(movieType != MOVIE_TYPE_ARCHIVE_)
        return;
    
	if(movieThumbnail)
		return;
	// DID USED TO RE-MAKE : RE-INSTATE IF YOU WANT TO AGAIN - [movieThumbnail release];
	
	if(!movieTag)
		return;
	
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:moviePlayerAsset];
	
    CGSize maxSize = CGSizeMake(72, 54);
    generator.maximumSize = maxSize;
	CMTime thumbTime = CMTimeMakeWithSeconds(0.1,30);
	
	CGImageRef imageRef = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
	
	if(imageRef)
	{
		movieThumbnail = [[UIImage alloc ] initWithCGImage:imageRef];
		CGImageRelease(imageRef);
	}
	else
	{
		NSString * imageName = @"Thumb";
		imageName = [imageName stringByAppendingString:movieTag];
		imageName = [imageName stringByAppendingString:@".png"];
		movieThumbnail = [[UIImage imageNamed:imageName] retain];
	}
    
    [generator release];
}

////////////////////////////////////////////////////////////////////////////
// Movie and Audio information
////////////////////////////////////////////////////////////////////////////

- (void) setStartTime:(float)time
{
	// Should only get called on Archives - just do getStartTime if it isn't
	
	if ( [[BasePadCoordinator Instance] connectionType] != BPC_ARCHIVE_CONNECTION_ && [[BasePadCoordinator Instance] videoConnectionType] == BPC_VIDEO_LIVE_CONNECTION_)
	{
		[self getStartTime];
	}
	else
	{
		movieStartTime = time;
		
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

- (void) updateStartTime
{
	if(movieType == MOVIE_TYPE_LIVE_STREAM_)
	{
        AVPlayerItem * item = [moviePlayer currentItem];
		
		if(item)
		{
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
}

////////////////////////////////////////////////////////////////////////////
// Movie controls
////////////////////////////////////////////////////////////////////////////

- (void) moviePrepareToPlayLive
{
	[self movieGoLive];
	[self startLivePlayTimer];
}

- (void) moviePlayAtRate:(float)playbackRate
{
	if([self moviePlayable] && movieActive)
	{
        if(movieForceLive)
            [moviePlayer setRate:1.0];
        else
            [moviePlayer setRate:playbackRate];
        
		moviePlayPending = false;
		moviePausedInPlace = false;
		moviePlaying = true;
	}
	else
	{
		moviePlayPending = true;
	}
}

- (void) moviePlay
{
	if(movieForceLive)
		[self moviePlayAtRate:1.0];
	else
        [self moviePlayAtRate:[[BasePadMedia Instance] activePlaybackRate]];
}

- (void) movieStop
{
	moviePlaying = false;
	moviePausedInPlace = true;
	[moviePlayer pause];
	moviePlayPending = false;
	movieGoLivePending = false;
}

- (void) movieGotoTime:(float)time
{
	if(movieForceLive)
    {
        if(!moviePlaying && !moviePlayPending && !movieGoLivePending)
            [self moviePrepareToPlayLive];
        
        return;
	}
	
	movieInLiveMode = false;
	
	if(movieSeekable && movieActive)
	{
        [self updateStartTime]; // Only does anything for live movies
        
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
				
				if(movieLoop && rangeDuration > 0)
				{
					if(movie_time < rangeStartTime)
					{
						while (movie_time < rangeStartTime)
							movie_time += rangeDuration;
					}
					else if(movie_time > rangeStartTime + rangeDuration)
					{
						while (movie_time > rangeStartTime + rangeDuration)
							movie_time -= rangeDuration;
					}
				}
				else
				{
					if(movie_time < rangeStartTime)
						movie_time = rangeStartTime;
					else if(movie_time > rangeStartTime + rangeDuration)
						movie_time = rangeStartTime + rangeDuration;
				}
				
				CMTime cm_time = CMTimeMakeWithSeconds(movie_time, 600);
				
				if(CMTIME_IS_VALID(cm_time)  && CMTIME_IS_NUMERIC(cm_time))
				{
					[moviePlayer seekToTime:cm_time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
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
	else
	{
		movieSeekPending = true;
		movieSeekTime = time;
	}
	
}

- (void) movieGoLive
{
    // Ignore if called on a forced live movie which is already playing
    if(movieForceLive && moviePlaying)
        return;
    
	movieInLiveMode = true;
	
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
	
	if(movieSeekable && movieActive)
	{
        if(movieType == MOVIE_TYPE_ARCHIVE_)
            [moviePlayer seekToTime:kCMTimeZero];
        else
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

- (void) movieResyncLiveWithRestart:(bool)restart
{
	if([[BasePadCoordinator Instance] liveMode])
	{
		if(restart)
			[self movieStop];
		
		[self movieGoLive];
		
		if(restart)
			[self moviePlay];
	}
	
	movieRecentlyResynced = true;
}

- (void) movieSetMuted:(bool)muted
{
    if(moviePlayer && moviePlayerAsset)
    {
        float volume = muted ? 0.0 : 1.0;
        NSArray *audioTracks = [moviePlayerAsset tracksWithMediaType:AVMediaTypeAudio];
        
        // Mute all the audio tracks
        NSMutableArray *allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks)
        {
            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:volume atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        
        AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
        [audioZeroMix setInputParameters:allAudioParams];
        
        [[moviePlayer currentItem] setAudioMix:audioZeroMix];
    }
}

- (bool) moviePlayable
{
	int moviePlayerStatus = moviePlayer ? [moviePlayer status] : AVPlayerItemStatusUnknown;
	
	if(moviePlayerStatus != AVPlayerItemStatusReadyToPlay)
	{
		return false;
	}
	
	int moviePlayerItemStatus = moviePlayerItem ? [moviePlayerItem status] : AVPlayerItemStatusUnknown;
	if(moviePlayerItemStatus != AVPlayerItemStatusReadyToPlay)
	{
		return false;
	}
	
    bool ready = moviePlayerLayer ? [moviePlayerLayer isReadyForDisplay] : false;
    
	return ready;
}

- (bool) moviePlayingRealTime: (float)timeNow
{
	// Called on a timer by BasePadMedia
	// Return true if time is OK
	// Resyncs if time has slipped, and returns true
	// Returns false if we can't get time : BasePadMedia will then restart the connection
	
	if([[BasePadCoordinator Instance] liveMode])
	{
		// Check the player status is still OK
		if(![self moviePlayable])
		{
			return false;
		}
		
		// Then check time hasn't slipped
		CMTime currentCMTime = [moviePlayer currentTime];
		if(CMTIME_IS_VALID(currentCMTime)  && CMTIME_IS_NUMERIC(currentCMTime))
		{
			Float64 moviePlayTime = CMTimeGetSeconds(currentCMTime);
			
			if(moviePlayTime > 0.0)
			{
				if(movieRecentlyResynced)
				{
					lastMoviePlayTime = moviePlayTime;
					lastResyncTime = timeNow;
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
						[self movieResyncLiveWithRestart:true];
						resyncCount ++;
					}
				}
				
				return true;
			}
		}
		
		// Fall through to here if live and time is not valid
		return false;
		
	}
	
	// Reach here if not in live mode
	return true;
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
			
			if([[BasePadMedia Instance] extendedNotification] || !parentMovieView)
				[[BasePadMedia Instance] notifyErrorOnVideoSource:self withError:currentError AutoRetry:true];
            
			if(parentMovieView)
				[parentMovieView notifyErrorOnVideoSource:self withError:currentError];
			
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
			int itemStatus = [object status];
			if(itemStatus ==  AVPlayerItemStatusFailed)
			{
				NSError * error = [object error];
				[self actOnPlayerError:error];
			}
            else
            {
                [self checkForReadyToPlay];
            }
		}
        
        if (object == moviePlayer)
        {
            if([keyPath isEqualToString:@"status"])
            {
                int playerStatus = [object status];
                
                if(playerStatus ==  AVPlayerItemStatusFailed)
                {
                    NSError * error = [object error];
                    [self actOnPlayerError:error];
                }
                else
                {
                    [self checkForReadyToPlay];
                }
            }
        }
		
        if (object == moviePlayerLayer)
        {
            if([keyPath isEqualToString:@"readyForDisplay"])
            {
                [self checkForReadyToPlay];
            }
        }
        
		if([keyPath isEqualToString:@"tracks"] || [keyPath isEqualToString:@"playbackBufferEmpty"] || [keyPath isEqualToString:@"playbackBufferFull"] || [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
		{
			NSArray * tracks = [object tracks];
			int tracksCount = [tracks count];
			int tracksEnabled = 0;
			
			if(tracksCount > 0)
			{
				for (int i = 0 ; i < tracksCount ; i++)
				{
					AVPlayerItemTrack * track = (AVPlayerItemTrack * )[tracks objectAtIndex:i];
					AVAssetTrack * assetTrack = [track assetTrack];
					
					if([track isEnabled]/* && [assetTrack isPlayable]*/)
						tracksEnabled++;
				}
			}
			
			//bool empty = false; //[object isPlaybackBufferEmpty];
			//bool full = [object isPlaybackBufferFull];
			//bool likelyToKeepUp = [object isPlaybackLikelyToKeepUp];
			
			if(parentMovieView)
			{
				//if([infoMessage length] > 0)
				//	[parentMovieView notifyInfoOnVideoSource:self withMessage:infoMessage];
				//else
                [parentMovieView hideMovieError];
			}
		}
	}
	
}

-(void)playerItemDidReachEnd:(NSNotification *)notification
{
	AVPlayerItem *player = [notification object];
	
	if(player == moviePlayerItem)	// Should always be
	{
		if(movieLoop)
		{
			[self performSelectorOnMainThread:@selector(actOnLoopingReachedEnd) withObject:nil waitUntilDone:true];
		}
		
		movieMarkedPlayable = false;
		looping = true;
	}
	
}

-(void)playerItemFailedToReachEnd:(NSNotification *)notification
{
	AVPlayerItem *player = [notification object];
	
	if(player == moviePlayerItem)	// Should always be
	{
		if(parentMovieView)
			[parentMovieView notifyInfoOnVideoSource:self withMessage:@"Failed to play to end"];
	}
}

- (void) checkForReadyToPlay
{
    bool ready = moviePlayerLayer ? [moviePlayerLayer isReadyForDisplay] : false;
    int playerStatus = moviePlayer ? [moviePlayer status] : AVPlayerItemStatusUnknown;
    int itemStatus = moviePlayerItem ? [moviePlayerItem status] : AVPlayerItemStatusUnknown;
    
    if(!movieMarkedPlayable /* && movieActive */ && ready && itemStatus == AVPlayerItemStatusReadyToPlay && playerStatus == AVPlayerItemStatusReadyToPlay)
    {
        [self performSelectorOnMainThread:@selector(actOnReadyToPlay) withObject:nil waitUntilDone:true];
    }
}

- (void) actOnReadyToPlay
{
	[self killErrorTimer];
	
	movieMarkedPlayable = [self moviePlayable];
	
    // Call parent to do anything needed with this movie
    // If we have called to load into a view, we'll notify the view
    // Otherwise, we notify BasePadMedia so that it can tell its registered view controller
    if(requestedShouldDisplay && requestedMovieView)
    {
        [requestedMovieView notifyMovieAttachedToSource:self];
 		[requestedMovieView notifyMovieSourceReadyToPlay:self];
    }
    else
    {
        [[BasePadMedia Instance] notifyNewVideoSource:self Status:BPM_CONNECTED_ ShouldDisplay:requestedShouldDisplay];
    }
    
	float currentTime = [[BasePadCoordinator Instance] currentPlayTime];
	[self getStartTime];
	
	if(movieGoLivePending)
	{
		[self movieGoLive];
		[self moviePlayAtRate:1.0];
	}
	else
	{
		if(movieType == MOVIE_TYPE_LIVE_STREAM_ && (movieForceLive || [[BasePadCoordinator Instance] liveMode]))
            [self moviePrepareToPlayLive];
		else if(!looping && ![[BasePadCoordinator Instance] liveMode])
            [self movieGotoTime:currentTime];
        
		if(movieForceLive || [[BasePadCoordinator Instance] playing])
            [self moviePlay];
	}
	
	looping = false;
	
	currentStatus = BPM_CONNECTED_;
	
    if(requestedMovieView)
        [requestedMovieView release];
    
    requestedMovieView = nil;
    requestedShouldDisplay = false;
    
	if([[BasePadMedia Instance] extendedNotification] || !parentMovieView)
		[[BasePadMedia Instance] notifyVideoSourceReadyToPlay:self];
    
	if(parentMovieView)
		[parentMovieView notifyMovieSourceReadyToPlay:self];
    
}

- (void) actOnPlayerError:(NSError *)error
{
	[self killErrorTimer];
    
	[self unloadMovie];
    
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
	
	if([[BasePadMedia Instance] extendedNotification] || !parentMovieView)
		[[BasePadMedia Instance] notifyErrorOnVideoSource:self withError:currentError AutoRetry:true];
	
	if(parentMovieView)
		[parentMovieView notifyErrorOnVideoSource:self withError:currentError];
    
	currentStatus = BPM_CONNECTION_ERROR_;
    
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
	looping = false;
	
}

- (void) actOnLoopingReachedEnd
{
	[moviePlayerItem seekToTime:kCMTimeZero];
	[moviePlayer setRate:[[BasePadMedia Instance] activePlaybackRate]];
}

- (void) activateMovie
{
    [self setMovieActive:true];
    
    if([self moviePlayable])
    {
        if(movieGoLivePending)
        {
            [self movieGoLive];
        }
        else if(movieSeekPending)
        {
            if(movieSeekTime < 0)
                [self movieSeekToLive];
            else
                [self movieGotoTime:movieSeekTime];
        }
        
        if(moviePlayPending)
        {
            [self moviePlay];
        }
        
    }
}


- (void) errorTimerExpired:(NSTimer *)theTimer
{
	[errorTimer release];
	errorTimer = nil;

	[self unloadMovie];
	
	if(currentError)
	{
		[currentError release];
		currentError = nil;
	}
	
	currentError = [[NSString alloc] initWithString:@"Connection timed out"];
	
	if([[BasePadMedia Instance] extendedNotification] || !parentMovieView)
		[[BasePadMedia Instance] notifyErrorOnVideoSource:self withError:currentError AutoRetry:false];
	
	if(parentMovieView)
		[parentMovieView notifyErrorOnVideoSource:self withError:currentError];
	
	currentStatus = BPM_CONNECTION_ERROR_;
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
	looping = false;
}

- (void) killErrorTimer
{
	if(errorTimer)
	{
		[errorTimer invalidate];
		[errorTimer release];
		errorTimer = nil;
	}
}


////////////////////////////////////////////////////////////////////////
//  Play timer functions

- (void) startVerificationTimer
{
    if(verificationTimer)
        [verificationTimer invalidate];
    
    // A 1 second repeating timer kicked off on loading as a fallback to catch ready to play.
    verificationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(verificationTimerFired:) userInfo:nil repeats:YES];
}

- (void) verificationTimerFired: (NSTimer *)theTimer
{
    if(!movieMarkedPlayable)
        [self checkForReadyToPlay];
    
    if(movieMarkedPlayable)
    {
        // Keep it playing - will have no effect if already playing, but gets it going again if stalled
        if(movieForceLive || [[BasePadCoordinator Instance] playing])
            [self moviePlay];
    }
}

- (void) startLivePlayTimer
{
	if(movieType == MOVIE_TYPE_LIVE_STREAM_)
	{
		// A 5 second timer kicked off at start of live play.
		[self stopPlayTimers];
		
		playStartTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(playStartTimerExpired:) userInfo:nil repeats:NO];
		
		//if(parentMovieView)
		//	[parentMovieView showMovieLoading];
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
	
	if(parentMovieView)
		[parentMovieView hideMovieLoading];
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
	//[self movieResyncLive];
    
    [self moviePlay];
	
	//if(parentMovieView)
	//	[parentMovieView hideMovieLoading];
	
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
		if(![self moviePlayable])
		{
			[self restartConnection];
			return;
		}
        
		// Then check time hasn't slipped
		float timeNow = [moviePlayElapsedTime value];
		if(movieDisplayed && ![self moviePlayingRealTime:timeNow])
		{
			[self restartConnection];
		}
	}
}

- (void) restartConnection
{
	[self movieStop];
	[self stopPlayTimers];
	
	if(parentMovieView)
		[self loadMovieIntoView:parentMovieView];
	else
		[self loadMovie];
	
	[self movieGoLive];
	[self moviePlay];
	
	[self startLivePlayTimer];
	
	restartCount++;
}

@end
