//
//  BasePadMedia.h
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAsynchronousKeyValueLoading.h>

#import <AVFoundation/AVAudioPlayer.h>

#import <CoreMedia/CMTime.h>

#import "BasePadVideoSource.h"
#import "BasePadAudioSource.h"

#import "MovieView.h"

#import "BasePadVideoViewController.h"

// Movie types
enum MovieTypes
{
	MOVIE_TYPE_NONE_,
	MOVIE_TYPE_ARCHIVE_,
	MOVIE_TYPE_LIVE_STREAM_,
	MOVIE_TYPE_VOD_STREAM_
} ;

// Connection status
enum MovieConnectionTypes
{
	BPM_NOT_CONNECTED_,
	BPM_CONNECTED_,
	BPM_TRYING_TO_CONNECT_,
	BPM_CONNECTION_FAILED_,
	BPM_CONNECTION_ERROR_,
	BPM_WAITING_FOR_STREAM_,
} ;

#define BPM_MAX_VIDEO_STREAMS 16

@class ElapsedTime;

@interface BasePadMedia : NSObject
{				
	BasePadVideoSource * movieSources[BPM_MAX_VIDEO_STREAMS];
	int movieSourceCount;
	
	BasePadVideoSource * queuedMovieSource[BPM_MAX_VIDEO_STREAMS];
	MovieView * queuedMovieView[BPM_MAX_VIDEO_STREAMS];
	int movieSourceQueueCount;
	bool movieSourceQueueBlocked;
	
	BasePadAudioSource * audioSource;
	
	NSString *currentMovieRoot;
	NSString *currentAudioRoot;
	int currentMovieType;
	
	NSTimer * playStartTimer;
	NSTimer * playTimer;
	
	float liveVideoDelay;
	
	Float64 lastMoviePlayTime;
	float lastResyncTime;
	
	int resyncCount;
	int restartCount;
	
	ElapsedTime * moviePlayElapsedTime;
	
	int currentStatus;
	NSString *currentError;
	
	float activePlaybackRate;
	
	int movieType;
	
	bool extendedNotification;
	
	BasePadVideoViewController * registeredViewController;
	
}

+ (BasePadMedia *)Instance;

@property (readonly) int movieSourceCount;

@property (readonly) float activePlaybackRate;

@property (readonly) float liveVideoDelay;
@property (readonly) int resyncCount;
@property (readonly) int restartCount;

@property (readonly) NSString *currentMovieRoot;
@property (readonly) NSString *currentAudioRoot;
@property (readonly) int currentMovieType;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) int movieType;

@property (nonatomic) bool extendedNotification;

- (void)onStartUp;

- (void)connectToVideoServer;
- (void)disconnectVideoServer;

-(void)resetConnectionCounts;

- (void)verifyMovieLoaded;
- (void)verifyAudioLoaded;

- (void)queueMovieLoad:(BasePadVideoSource *)movieSource IntoView:(MovieView *)movieView;
- (void)blockMovieLoadQueue;
- (void)unblockMovieLoadQueue;

- (int) getMovieType;

- (BasePadVideoSource *)movieSource:(int)index;
- (BasePadVideoSource *)findMovieSourceByTag:(NSString *)tag;

- (NSURL *) getMovieURL;
- (NSURL *) getAudioURL;

- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) movieSeekToLive;
- (void) moviePrepareToPlay;
- (void) movieResyncLive;
- (void) setMoviePlaying:(bool)value;
- (void) setMoviePausedInPlace:(bool)value;

- (void) audioPlayAtRate:(float)playbackRate;
- (void) audioPlay;
- (void) audioStop;
- (void) audioGotoTime:(float)time;
- (void) audioPrepareToPlay;

- (void) startLivePlayTimer;
- (void) stopPlayTimers;
- (void) playStartTimerExpired: (NSTimer *)theTimer;
- (void) livePlayTimerFired: (NSTimer *)theTimer;
- (void) restartConnection;

-(void)RegisterViewController:(BasePadVideoViewController *)view_controller;
-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller;

-(void)notifyNewVideoSource:(BasePadVideoSource *)videoSource ShouldDisplay:(bool)shouldDisplay;

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error;
-(void)notifyUnloadingVideoSource:(BasePadVideoSource *)videoSource;
-(void)notifyStateChangeOnVideoSource:(BasePadVideoSource *)videoSource ToState:(int)state;

-(void)notifyVideoSourceConnecting:(BasePadVideoSource *)videoSource showIndicators:(bool)showIndicators;

-(void)notifyMovieInformation;

-(void)loadVideoList:(NSString *)fileName;

@end
