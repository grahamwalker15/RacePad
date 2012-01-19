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


@interface BasePadVideoSource : NSObject
{				
	AVURLAsset * moviePlayerAsset;
	AVPlayerItem * moviePlayerItem;
	AVPlayer * moviePlayer;
	AVPlayerLayer * moviePlayerLayer;
	
	id moviePlayerObserver;
	
	float movieStartTime;
	float movieSeekTime;
	float streamSeekStartTime;
	
	bool movieLoop;
	
	float liveVideoDelay;
	
	Float64 lastMoviePlayTime;
	float lastResyncTime;
	bool movieRecentlyResynced;
	
	int resyncCount;
	
	NSString *currentMovie;
	NSString *movieTag;
	
	int currentStatus;
	NSString *currentError;
	
	bool movieLoaded;
	bool movieMarkedPlayable;
	
	bool moviePlayPending;
	bool movieSeekable;
	bool movieSeekPending;
	bool movieGoLivePending;
	
	bool moviePausedInPlace;
	bool moviePlaying;
	
	bool audioPlayPending;
	bool audioSeekPending;
	
	float audioStartTime;
	
	float activePlaybackRate;
	
	int movieType;
	
	bool movieActive;
	bool movieDisplayed;
	
}

@property (readonly) AVURLAsset * moviePlayerAsset;
@property (readonly) AVPlayerItem * moviePlayerItem;
@property (readonly) AVPlayer * moviePlayer;
@property (readonly) AVPlayerLayer * moviePlayerLayer;

@property (readonly) id moviePlayerObserver;

@property (nonatomic) float movieStartTime;
@property (nonatomic) float movieSeekTime;
@property (readonly) float liveVideoDelay;
@property (readonly) int resyncCount;

@property (nonatomic) bool movieLoop;

@property (readonly) NSString *currentMovie;
@property (nonatomic, retain) NSString *movieTag;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) bool movieLoaded;
@property (readonly) bool moviePlayPending;
@property (readonly) bool movieSeekable;
@property (readonly) bool movieSeekPending;
@property (readonly) bool movieGoLivePending;

@property (nonatomic) bool moviePausedInPlace;
@property (nonatomic) bool moviePlaying;

@property (readonly) int movieType;

@property (nonatomic) bool movieActive;
@property (nonatomic) bool movieDisplayed;
@property (nonatomic) bool movieMarkedPlayable;


- (void)onStartUp;

- (void) loadMovie:(NSURL *)url ShouldDisplay:(bool)shouldDisplay;
- (void) unloadMovie;

- (void) setStartTime:(float)time;
- (void) getStartTime;

- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) movieSeekToLive;
- (void) moviePrepareToPlay;
- (void) movieResyncLive;

- (bool) moviePlayable;
- (bool) moviePlayingRealTime: (float)timeNow;

- (void) resetConnectionCounts;

- (void) timeObserverCallback:(CMTime) cmTime;
- (void) playerItemDidReachEnd:(NSNotification *)notification;

@end
