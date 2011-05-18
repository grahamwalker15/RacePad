//
//  RacePadMedia.m
//  RacePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadMedia.h"

#import "RacePadCoordinator.h"
#import "ElapsedTime.h"
#import "RacePadPrefs.h"
#import "RacePadDatabase.h"


@implementation RacePadMedia

@synthesize moviePlayerAsset;
@synthesize moviePlayerItem;
@synthesize moviePlayer;
@synthesize moviePlayerLayer;

@synthesize moviePlayerObserver;

@synthesize movieStartTime;
@synthesize movieSeekTime;

@synthesize currentMovie;

@synthesize movieLoaded;
@synthesize moviePlayable;
@synthesize moviePlayPending;
@synthesize movieSeekable;
@synthesize movieSeekPending;
@synthesize moviePausedInPlace;


@synthesize movieType;

static RacePadMedia * instance_ = nil;

+(RacePadMedia *)Instance
{
	if(!instance_)
		instance_ = [[RacePadMedia alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		currentMovie = nil;
		
		moviePlayer = nil;
		moviePlayerItem = nil;
		moviePlayerAsset = nil;
		moviePlayerLayer = nil;
		moviePlayerObserver = nil;
		
		moviePlayable = false;
		moviePlayPending = false;
		movieSeekable = false;
		movieSeekPending = false;
		movieLoaded = false;
		
		moviePausedInPlace = false;
		
		movieStartTime = 0.0;
		movieSeekTime = 0.0;
		streamSeekStartTime = 0.0;
		
		activePlaybackRate = 1.0;
		
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

- (void)connectToVideoServer
{
	[[RacePadCoordinator Instance] setVideoConnectionType:RPC_VIDEO_LIVE_CONNECTION_];
	[self verifyMovieLoaded];
}

- (void)disconnectVideoServer
{
	if(movieLoaded)
		[self unloadMovie];
	
	movieType = MOVIE_TYPE_NONE_;

	[[RacePadCoordinator Instance] setVideoConnectionType:RPC_NO_CONNECTION_];
	[[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_NO_CONNECTION_];
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

////////////////////////////////////////////////////////////////////////////
// Movie loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadMovie:(NSURL *)url
{
	if(movieLoaded)
		[self unloadMovie];
	
	[[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_CONNECTION_CONNECTING_];
	[[RacePadCoordinator Instance] videoServerOnConnectionChange];
		
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
			 [moviePlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
			 			 
			 // Register a time observer to get the current time while playing
			 moviePlayerObserver = [moviePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:nil usingBlock:^(CMTime time){[self timeObserverCallback:time];}];
			 
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
			 
			 if(movieType == MOVIE_TYPE_LIVE_STREAM_)
			 {
				 [[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_CONNECTION_SUCCEEDED_];
			 }
			 else
			 {
				 [[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_NO_CONNECTION_];
			 }
			 
			 [[RacePadCoordinator Instance] videoServerOnConnectionChange];

			 moviePausedInPlace= false;
		 }
		 else
		 {
			 // Deal with the error appropriately.
			 [[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_CONNECTION_FAILED_];
			 [[RacePadCoordinator Instance] videoServerOnConnectionChange];

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
	
	
	[moviePlayerLayer release];
	[moviePlayer release];
	[moviePlayerItem release];
	[moviePlayerAsset release];
	
	moviePlayerLayer = nil;
	moviePlayer = nil;
	moviePlayerItem = nil;
	moviePlayerAsset = nil;
	
	moviePlayable = false;
	moviePlayPending = false;
	movieSeekable = false;
	movieSeekPending = false;
	movieLoaded =false;
	moviePausedInPlace = false;
	
	movieStartTime = 0.0;
	streamSeekStartTime = 0.0;
	
	[[RacePadCoordinator Instance] setVideoConnectionType:RPC_NO_CONNECTION_];
	[[RacePadCoordinator Instance] setVideoConnectionStatus:RPC_NO_CONNECTION_];

	movieType = MOVIE_TYPE_NONE_;
	
	[currentMovie release];
	currentMovie = nil;
	
	[[RacePadCoordinator Instance] videoServerOnConnectionChange];
	
}


////////////////////////////////////////////////////////////////////////////
// Movie information
////////////////////////////////////////////////////////////////////////////

- (NSString *)getVideoArchiveName
{
	NSString *name = [[RacePadCoordinator Instance] getVideoArchiveName];
	
	return name;
}

- (NSURL *)getMovieURL
{
	NSURL * url = nil;;
	
	// Live stream or archive name
	if ( [[RacePadCoordinator Instance] connectionType] != RPC_ARCHIVE_CONNECTION_ && [[RacePadCoordinator Instance] videoConnectionType] == RPC_VIDEO_LIVE_CONNECTION_)
	{
		NSString * serverAddress = [[[RacePadPrefs Instance] getPref:@"preferredVideoServerAddress"] retain];
		
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
	else
	{
		NSString * urlString = [self getVideoArchiveName];
		if(urlString && [urlString length] > 0)
			url = [NSURL fileURLWithPath:urlString];	// auto released
		
		movieType = MOVIE_TYPE_ARCHIVE_;
	}
	
	return url;
	
}

- (void) getStartTime
{
	if ( [[RacePadCoordinator Instance] connectionType] != RPC_ARCHIVE_CONNECTION_ && [[RacePadCoordinator Instance] videoConnectionType] == RPC_VIDEO_LIVE_CONNECTION_)
	{
        AVPlayerItem * item = [moviePlayer currentItem];
		
		if(item)
		{
			CMTime currentCMTime = [item currentTime];
			
			float currentTime = 0.0;
			
			if(CMTIME_IS_VALID(currentCMTime)  && CMTIME_IS_NUMERIC(currentCMTime))
			{
				currentTime = (float) CMTimeGetSeconds(currentCMTime);
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
					float startTime = (float)[ElapsedTime LocalTimeOfDay] - duration;

					streamSeekStartTime = streamStartTime;
					
					if(!movieSeekable || startTime < movieStartTime)
					{
						movieStartTime = startTime;
						
						movieSeekable= true;
						
						if(movieSeekPending)
							[self movieGotoTime:movieSeekTime];
					}
				}
			}
		}
	}
	else
	{
		movieStartTime = -1;
		
		// Try to find a meta file
		NSString *metaFileName = [currentMovie stringByReplacingOccurrencesOfString:@".m4v" withString:@".vmd"];
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
		
		if ( movieStartTime == -1 )
		{
			// Default to hard coded start time
			movieStartTime = 13 * 3600.0 + 43 * 60.0 + 40;
		}
		
		movieSeekable= true;
		
		if(movieSeekPending)
		{
			if(movieSeekTime < 0)
				[self movieGoLive];
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
	
	if(moviePlayable && registeredViewController)
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
}

- (void) movieGotoTime:(float)time
{
	if(movieSeekable && registeredViewController)
	{
		Float64 movie_time = time - movieStartTime;
		CMTime currentMovieTime = [moviePlayer currentTime];
		Float64 currentMovieTimeSeconds = CMTimeGetSeconds(currentMovieTime);
		
		if(movieType == MOVIE_TYPE_LIVE_STREAM_)
			movie_time = movie_time + streamSeekStartTime - [[RacePadCoordinator Instance] serverTimeOffset];
			
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
	if(movieSeekable && registeredViewController)
	{
		NSArray *seekableTimeRanges = [moviePlayerItem seekableTimeRanges];
		
		if([seekableTimeRanges count] > 0)
		{
			NSValue * value = [seekableTimeRanges objectAtIndex:0];
			CMTimeRange range;
			[value getValue:&range];
			
			if(CMTIME_IS_VALID(range.start)  && CMTIME_IS_NUMERIC(range.start) && CMTIME_IS_VALID(range.duration)  && CMTIME_IS_NUMERIC(range.duration)  )
			{
				[moviePlayer seekToTime:CMTimeAdd(range.start, range.duration)];
			}
		}
		movieSeekPending = false;
	}
	else
	{
		movieSeekPending = true;
		movieSeekTime = -1.0;
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
			NSString * description = [error localizedDescription];
			NSString * reason = [error localizedFailureReason];
			int x = 0;
		}

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
			if(!moviePlayable && [object status] == AVPlayerItemStatusReadyToPlay)
			{
				moviePlayable = true;
				
				float time_of_day = [[RacePadCoordinator Instance] currentTime];
				[self getStartTime];
				
				if(movieType == MOVIE_TYPE_ARCHIVE_ || ![[RacePadCoordinator Instance] liveMode])
					[self movieGotoTime:time_of_day];
				
				if(moviePlayPending)
					[self moviePlay];
			}
			
			if([object status] ==  AVPlayerItemStatusFailed)
			{
				NSError * error = [object error];
				NSString * description = [error localizedDescription];
				NSString * reason = [error localizedFailureReason];
				int x = 0;
			}
		}
	}
	
	if (object == moviePlayer)
	{
		if([keyPath isEqualToString:@"status"])
		{
			if([object status] == AVPlayerItemStatusReadyToPlay)
			{
				int x = 0;
			}
			
			if([object status] ==  AVPlayerItemStatusFailed)
			{
				NSError * error = [object error];
				NSString * description = [error localizedDescription];
				NSString * reason = [error localizedFailureReason];
				int x = 0;
			}
		}
	}
}


////////////////////////////////////////////////////////////////////////
//  View Controller registration

-(void)RegisterViewController:(RacePadVideoViewController *)view_controller
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
	
	if(movieLoaded)
		[registeredViewController displayMovieInView];
	
}

-(void)ReleaseViewController:(RacePadVideoViewController *)view_controller
{
	if(registeredViewController && registeredViewController == view_controller)
	{
		[moviePlayer pause];	
		[registeredViewController removeMovieFromView];
		
		[registeredViewController release];
		registeredViewController = nil;
		
		moviePausedInPlace = false;

	}
}

@end
