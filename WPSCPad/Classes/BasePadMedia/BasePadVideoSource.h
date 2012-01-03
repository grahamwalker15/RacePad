//
//  BasePadVideoSource.h
//  RacePad
//
//  Created by Gareth Griffith on 12/13/11.
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

#import "BasePadVideoViewController.h"


@class ElapsedTime;


@interface BasePadVideoSource : NSObject
{				
	AVURLAsset * moviePlayerAsset;
	AVPlayerItem * moviePlayerItem;
	AVPlayer * moviePlayer;
	AVPlayerLayer * moviePlayerLayer;
	
	id moviePlayerObserver;
	NSTimer * playStartTimer;
	NSTimer * playTimer;
	
	float movieStartTime;
	float movieSeekTime;
	float streamSeekStartTime;
	
	float liveVideoDelay;
	
	Float64 lastMoviePlayTime;
	float lastLiveVideoDelay;
	float lastResyncTime;
	bool movieRecentlyResynced;
	
	int resyncCount;
	int restartCount;
	
	ElapsedTime * moviePlayElapsedTime;
	
	NSString *currentMovie;
	NSString *currentAudio;
	
	int currentStatus;
	NSString *currentError;
	
	bool movieLoaded;
	bool moviePlayable;
	bool moviePlayAllowed;
	
	bool moviePlayPending;
	bool movieSeekable;
	bool movieSeekPending;
	bool movieGoLivePending;
	
	bool moviePausedInPlace;
	int movieResyncCountdown;
	
	bool audioPlayPending;
	bool audioSeekPending;
	
	float audioStartTime;
	
	float activePlaybackRate;
	
	int movieType;
	
	bool movieActive;
	
}

@property (readonly) AVURLAsset * moviePlayerAsset;
@property (readonly) AVPlayerItem * moviePlayerItem;
@property (readonly) AVPlayer * moviePlayer;
@property (readonly) AVPlayerLayer * moviePlayerLayer;

@property (readonly) id moviePlayerObserver;

@property (readonly) float movieStartTime;
@property (readonly) float movieSeekTime;
@property (readonly) float liveVideoDelay;
@property (readonly) int resyncCount;
@property (readonly) int restartCount;

@property (readonly) NSString *currentMovie;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) bool movieLoaded;
@property (readonly) bool moviePlayPending;
@property (readonly) bool movieSeekable;
@property (readonly) bool movieSeekPending;

@property (nonatomic) bool moviePausedInPlace;

@property (readonly) int movieType;

@property (nonatomic) bool movieActive;

- (void)onStartUp;

-(void)resetConnectionCounts;

- (void) loadMovie:(NSURL *)url;
- (void) unloadMovie;

- (void) movieSetStartTime:(float)time;

- (void) getStartTime;

- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) movieSeekToLive;
- (void) moviePrepareToPlay;
- (void) movieResyncLive;

- (void) startLivePlayTimer;
- (void) stopPlayTimers;
- (void) playStartTimerExpired: (NSTimer *)theTimer;
- (void) livePlayTimerFired: (NSTimer *)theTimer;
- (void) restartConnection;

- (bool) moviePlayable;

- (void) timeObserverCallback:(CMTime) cmTime;

@end
