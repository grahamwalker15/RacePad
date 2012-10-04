//
//  BasePadMedia.m
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadMedia.h"

#import "BasePadCoordinator.h"
#import "BasePadPrefs.h"
#import "BasePadDatabase.h"


@implementation BasePadMedia

@synthesize movieSourceCount;

@synthesize activePlaybackRate;
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
		movieSourceQueueCount = 0;
		movieSourceQueueBlocked = false;
		
		audioSource = [[BasePadAudioSource alloc] init];
		
		activePlaybackRate = 1.0;
		liveVideoDelay = 0.0;
		
		restartCount = 0;
		resyncCount = 0;
		
		lastMoviePlayTime = 0.0;
		lastResyncTime = 0.0;
		
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
        
		if(queuedMovieSource[i])
		{
			[queuedMovieSource[i] release];
			queuedMovieSource[i] = nil;
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
		if(movieSources[i] && [movieSources[i] movieLoaded])
		{
			[self notifyUnloadingVideoSource:movieSources[i]];
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

- (void)clearMediaSources
{
    movieSourceCount = 0;
    movieSourceQueueCount = 0;
    movieSourceQueueBlocked = false;
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
			for(int i = 0 ; i < movieSourceCount ; i++)
			{
				if(movieSources[i] && [movieSources[i] movieLoaded])
				{
					[self notifyUnloadingVideoSource:movieSources[i]];
					[movieSources[i] unloadMovie];
				}
			}
            
            [self clearMediaSources];

			currentMovieRoot = [newMovie retain];
			
			// If we have a video list, pass this on to the parser, else load directly here
			if([currentMovieRoot hasSuffix:@".vls"])
			{
				[self loadVideoList:currentMovieRoot];
			}
			else
			{
				[movieSources[0] loadMovie:url ShouldDisplay:true InMovieView:nil];
				movieSourceCount = 1;
			}
		}
	}
	else
	{
		for(int i = 0 ; i < movieSourceCount ; i++)
		{
			if(movieSources[i] && [movieSources[i] movieLoaded])
			{
				[self notifyUnloadingVideoSource:movieSources[i]];
				[movieSources[i] unloadMovie];
			}
		}
		
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
 		NSString * urlString = [[BasePadCoordinator Instance] getLiveVideoListName];
		if(urlString && [urlString length] > 0)
        {
			url = [NSURL fileURLWithPath:urlString];	// auto released
        }
        else
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
        }
		
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

- (void) moviePrepareToPlayLive
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] moviePrepareToPlayLive];
	}
}

- (void) moviePlayAtRate:(float)playbackRate
{
	activePlaybackRate = playbackRate;
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
	// Does not stop movies which are supposed to stay live
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed] && ![movieSources[i] movieForceLive])
			[movieSources[i] movieStop];
	}
}

- (void) movieStopAll
{
	// Stops all movies including those which are supposed to stay live
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
		if([movieSources[i] movieDisplayed] && ![movieSources[i] movieForceLive])
			[movieSources[i] setMoviePlaying:value];
	}
}

- (void) setMoviePausedInPlace:(bool)value
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed] && ![movieSources[i] movieForceLive])
			[movieSources[i] setMoviePausedInPlace:value];
	}
}

- (void) stopPlayTimers
{
	for(int i = 0 ; i < movieSourceCount ; i++)
	{
		if([movieSources[i] movieDisplayed])
			[movieSources[i] stopPlayTimers];
	}
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

////////////////////////////////////////////////////////////////////////////
// Movie search tools
////////////////////////////////////////////////////////////////////////////

- (BasePadVideoSource *) findNextMovieForReview
{
    // Returns next movie which is not forced live, and not displayed.
    // Returns nil if none found
    if(movieSourceCount > 0)
    {
        for(int i = 0 ; i < movieSourceCount ; i++)
        {
            if(![movieSources[i] movieDisplayed] && ![movieSources[i] movieForceLive])
                return movieSources[i];
        }
    }
    
    return nil;
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
		if([movieSources[i] movieLoaded])
		{
            [movieSources[i] setMoviePausedInPlace:false];
            [movieSources[i]  setMovieActive:true];
			[registeredViewController displayMovieSource:movieSources[i]];
		}
	}
}

-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller
{
	if(registeredViewController && registeredViewController == view_controller)
	{
		[self stopPlayTimers];
		
		[self movieStopAll];	
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
	
	if(registeredViewController)
	{
		[videoSource setMoviePausedInPlace:false];
		[videoSource setMovieActive:true];
	}
	
	[[BasePadCoordinator Instance] videoServerOnConnectionChange];
	
}

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error
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
	int localMovieSourceCount = 0;
    
    NSURL * url = [NSURL URLWithString:fileName];
    NSString * fileString = [url path];
	
	FILE * listFile;
	listFile = fopen([fileString fileSystemRepresentation], "rt" );
	if ( listFile )
	{
		char keyword[128];
		char stringValue[256];
		char movieTypeString[16];
		int movieStartTime;
		int movieLoop;
		
		while(localMovieSourceCount < BPM_MAX_VIDEO_STREAMS)
		{
			if ( fscanf(listFile, "%128s", keyword ) != 1 )
				break;
			
			if ( strcmp ( keyword, "@videofile" ) != 0 )
				break;

			// File name:
			if ( fscanf(listFile, "%128s", stringValue ) != 1 )
				break;
			
			// Type:
			if ( fscanf(listFile, "%128s %128s", keyword, movieTypeString ) != 2 )
				break;
			
			bool movieIsURL = false;
			bool movieForceLive = false;
			
			if ( strcmp ( movieTypeString, "url" ) == 0 || strcmp ( movieTypeString, "url-live" ) == 0 )
				movieIsURL = true;
			
			if ( strcmp ( movieTypeString, "url-live" ) == 0 || strcmp ( movieTypeString, "file-live" ) == 0 )
				movieForceLive = true;
			
			// If it is a file name, append document path - otherwise if it is a url, leave as it is
			
			NSString * urlString;
			NSURL * url;
			
			if(!movieIsURL)
			{
				urlString = [[BasePadCoordinator Instance] getVideoArchiveRoot];
				urlString = [urlString stringByAppendingPathComponent:[NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding]];
				url = [NSURL fileURLWithPath:urlString];	// auto released
			}
			else
			{
				NSString * urlString = @"http://";
				urlString = [urlString stringByAppendingString:[NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding]];
				url = [NSURL URLWithString:urlString];	// auto released
			}

			if ( fscanf(listFile, "%128s %d", keyword, &movieStartTime ) != 2 )
				break;
			
			if ( fscanf(listFile, "%128s %d", keyword, &movieLoop ) != 2 )
				break;
			
			if ( fscanf(listFile, "%128s %128s", keyword, stringValue ) != 2 )
				break;
			
			NSString * movieTag = [NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding];
			
			if ( fscanf(listFile, "%128s %128s", keyword, stringValue ) != 2 )
				break;
            
            // Strip underscore characters from movie names
            for (int i = 0 ; i < strlen(stringValue) ; i++)
            {
                if(stringValue[i] == '_')
                    stringValue[i] = ' ';
            }
			
            // Then copy into an NSString
			NSString * movieName = [NSString stringWithCString:stringValue encoding:NSASCIIStringEncoding];
			
			if ( fscanf(listFile, "%128s", keyword ) != 1 )
				break;
			
			if ( strcmp ( keyword, "@end" ) == 0 )
			{
				[movieSources[localMovieSourceCount] setMovieURL:url] ;
				[movieSources[localMovieSourceCount] setMovieType:(movieIsURL ? MOVIE_TYPE_LIVE_STREAM_ : MOVIE_TYPE_ARCHIVE_)] ;
				[movieSources[localMovieSourceCount] setShouldAutoDisplay:(movieSourceCount == 0)];	// Displays first one
				[movieSources[localMovieSourceCount] setStartTime:movieStartTime];
				[movieSources[localMovieSourceCount] setMovieLoop:(movieLoop > 0)];
				[movieSources[localMovieSourceCount] setMovieTag:movieTag];
				[movieSources[localMovieSourceCount] setMovieName:movieName];
				[movieSources[localMovieSourceCount] setMovieForceLive:movieForceLive];
				
				if(movieSourceCount == 0 && registeredViewController && [registeredViewController firstMovieView])
					[self queueMovieLoad:movieSources[localMovieSourceCount] IntoView:[registeredViewController firstMovieView]];
				else
					[self queueMovieLoad:movieSources[localMovieSourceCount] IntoView:nil];
				
				localMovieSourceCount++;
			}
			else
			{
				break;
			}
		}
		
		fclose(listFile);
	}
}

- (void)queueMovieLoad:(BasePadVideoSource *)movieSource IntoView:(MovieView *)movieView;
{
	if(movieSourceQueueBlocked || movieSourceQueueCount > 0)
	{
		queuedMovieSource[movieSourceQueueCount] = movieSource;
		queuedMovieView[movieSourceQueueCount] = movieView;
		movieSourceQueueCount++;
	}
	else
	{
		// Only load archives and the main view to start
		// Streamed feeds will be loaded as needed - indicated by movieView being set
		if(movieView || [movieSource shouldAutoDisplay] || [movieSource movieType] == MOVIE_TYPE_ARCHIVE_)
		{
			if(movieView)
			{
				[movieSource loadMovieIntoView:movieView];
			}
			else
			{
				[movieSource loadMovie];
			}
		}
		else
		{
			[movieSource makeThumbnail];
		}
		
		// If this source is not in the counted list, increment the count
		bool sourceFound = false;
		if(movieSourceCount > 0)
		{
			for (int i = 0 ; i < movieSourceCount ; i++)
			{
				if(movieSources[i] == movieSource)
				{
					sourceFound = true;
					break;
				}
			}
		}
		
		if(!sourceFound)
			movieSourceCount++;
	}
}

- (void)blockMovieLoadQueue
{
	movieSourceQueueBlocked = true;
}

- (void)unblockMovieLoadQueue
{
	movieSourceQueueBlocked = false;
	
	if(movieSourceQueueCount > 0)
	{
		BasePadVideoSource * movieSource = queuedMovieSource[0];
		MovieView * movieView = queuedMovieView[0];
		movieSourceQueueCount --;
		
		if(movieSourceQueueCount > 0)
		{
			for (int i = 0 ; i < movieSourceQueueCount ; i++)
			{
				queuedMovieSource[i] = queuedMovieSource[i+1];
				queuedMovieView[i] = queuedMovieView[i+1];
			}
		}
				
		// If this source is not in the counted list, increment the count
		bool sourceFound = false;
		if(movieSourceCount > 0)
		{
			for (int i = 0 ; i < movieSourceCount ; i++)
			{
				if(movieSources[i] == movieSource)
				{
					sourceFound = true;
					break;
				}
			}
		}
		
		if(!sourceFound)
			movieSourceCount++;
		
		// Only load archives an the main view to start
		// Streamed feeds will be loaded as needed - indicated by movieView being set
		if(movieView || [movieSource shouldAutoDisplay] || [movieSource movieType] == MOVIE_TYPE_ARCHIVE_)
		{
			if(movieView)
				[movieSource loadMovieIntoView:movieView];
			else
				[movieSource loadMovie];
		}
		else
		{
			[movieSource makeThumbnail];
			[self unblockMovieLoadQueue];
		}
	}		
}

@end
