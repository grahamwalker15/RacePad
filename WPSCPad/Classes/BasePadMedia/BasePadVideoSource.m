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

@implementation BasePadVideoSource

@synthesize moviePlayerAsset;
@synthesize moviePlayerItem;
@synthesize moviePlayer;
@synthesize moviePlayerLayer;

@synthesize moviePlayerObserver;

@synthesize movieStartTime;
@synthesize movieSeekTime;
@synthesize liveVideoDelay;

@synthesize resyncCount;

@synthesize currentMovie;

@synthesize currentStatus;
@synthesize currentError;

@synthesize movieLoaded;
@synthesize moviePlayPending;
@synthesize movieSeekable;
@synthesize movieSeekPending;
@synthesize movieGoLivePending;
@synthesize moviePausedInPlace;

@synthesize movieType;
@synthesize movieMarkedPlayable;
@synthesize movieActive;


-(id)init
{
	if(self = [super init])
	{	
		movieActive = false;
		
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
		movieMarkedPlayable = false;
		
		moviePausedInPlace = false;
		
		movieStartTime = 0.0;
		movieSeekTime = 0.0;
		streamSeekStartTime = 0.0;
		
		activePlaybackRate = 1.0;
		
		resyncCount = 0;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		
		movieRecentlyResynced = false;
		
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
}

////////////////////////////////////////////////////////////////////////////
// Movie loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadMovie:(NSURL *)url
{
	if(movieLoaded)
		[self unloadMovie];
	
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
			 
			 // Call parent to position the movie and order the overlay in any registered view controller
			 [[BasePadMedia Instance] notifyNewVideoSource:self];
			 
			 movieLoaded = true;
			 currentMovie = [[url absoluteString] retain];
			 
			 currentStatus = BPM_CONNECTED_;
			 
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
			 
			 [[BasePadMedia Instance] notifyErrorOnVideoSource:self withError:currentError];
			 
			 [currentMovie release];
			 currentMovie = nil;
		 }
	 }
	 ];
}

- (void) unloadMovie
{
	// Delete any existing player and assets	
	[[BasePadMedia Instance] notifyUnloadingVideoSource:self];
	
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
	movieMarkedPlayable = false;
	movieSeekPending = false;
	movieLoaded =false;
	moviePausedInPlace = false;
	
	movieStartTime = 0.0;
	streamSeekStartTime = 0.0;
	
	movieType = MOVIE_TYPE_NONE_;
	
	[currentMovie release];
	currentMovie = nil;
	
}

////////////////////////////////////////////////////////////////////////////
// Movie and Audio information
////////////////////////////////////////////////////////////////////////////

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

- (void) moviePrepareToPlay
{
}

- (void) moviePlayAtRate:(float)playbackRate
{
	activePlaybackRate = playbackRate;
	
	if([self moviePlayable] && movieActive)
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
	if(movieSeekable && movieActive)
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
	
	if(movieSeekable && movieActive)
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
						[self movieResyncLive];
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
			if(!movieMarkedPlayable && movieActive && status == AVPlayerItemStatusReadyToPlay)
			{
				movieMarkedPlayable = [self moviePlayable];
				
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
			if(!movieMarkedPlayable && movieActive && [object status] == AVPlayerItemStatusReadyToPlay)
			{
				movieMarkedPlayable = [self moviePlayable];
				
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

@end
