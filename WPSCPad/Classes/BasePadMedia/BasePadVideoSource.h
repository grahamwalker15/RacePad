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

@class MovieView;
@class ElapsedTime;

@interface BasePadVideoSource : NSObject
{				
	AVURLAsset * moviePlayerAsset;
	AVPlayerItem * moviePlayerItem;
	AVPlayer * moviePlayer;
	AVPlayerLayer * moviePlayerLayer;
	
	MovieView * parentMovieView;
	
	id moviePlayerObserver;
	
	float movieStartTime;
	float movieSeekTime;
	float streamSeekStartTime;
	
	bool movieLoop;
	bool movieForceLive;
			
	NSString *currentMovie;
	NSString *movieTag;
	NSString *movieName;
	NSURL *movieURL;
	UIImage *movieThumbnail;
	
	int currentStatus;
	NSString *currentError;
	
	bool movieAttached;
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
		
	int movieType;
	
	bool movieActive;
	bool movieDisplayed;
	
	bool shouldAutoDisplay;
		
	bool loading;
	bool looping;
	
	bool movieInLiveMode;
	
	NSTimer * playStartTimer;
	NSTimer * playTimer;
	
	float liveVideoDelay;
	
	Float64 lastMoviePlayTime;
	float lastResyncTime;
	bool movieRecentlyResynced;
		
	int resyncCount;
	int restartCount;
	
	ElapsedTime * moviePlayElapsedTime;
}

@property (readonly) AVURLAsset * moviePlayerAsset;
@property (readonly) AVPlayerItem * moviePlayerItem;
@property (readonly) AVPlayer * moviePlayer;
@property (readonly) AVPlayerLayer * moviePlayerLayer;

@property (nonatomic, retain) MovieView * parentMovieView;

@property (readonly) id moviePlayerObserver;

@property (nonatomic) float movieStartTime;
@property (nonatomic) float movieSeekTime;
@property (readonly) float liveVideoDelay;
@property (readonly) int resyncCount;

@property (nonatomic) bool movieLoop;
@property (nonatomic) bool movieForceLive;
@property (nonatomic) bool shouldAutoDisplay;

@property (readonly) NSString *currentMovie;
@property (nonatomic, retain) NSURL *movieURL;
@property (nonatomic, retain) NSString *movieTag;
@property (nonatomic, retain) NSString *movieName;
@property (readonly) UIImage * movieThumbnail;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) bool movieLoaded;
@property (readonly) bool movieAttached;
@property (readonly) bool moviePlayPending;
@property (readonly) bool movieSeekable;
@property (readonly) bool movieSeekPending;
@property (readonly) bool movieGoLivePending;

@property (readonly) bool movieInLiveMode;

@property (nonatomic) bool moviePausedInPlace;
@property (nonatomic) bool moviePlaying;

@property (nonatomic) int movieType;

@property (nonatomic) bool movieActive;
@property (nonatomic) bool movieDisplayed;
@property (nonatomic) bool movieMarkedPlayable;


- (void)onStartUp;

- (void) loadMovie;
- (void) loadMovieIntoView:(MovieView *)movieView;
- (void) loadMovie:(NSURL *)url ShouldDisplay:(bool)shouldDisplay InMovieView:(MovieView *)movieView;
- (void) unloadMovie;
- (void) attachMovie;
- (void) detachMovie;
- (void) makeThumbnail;

- (void) setStartTime:(float)time;
- (void) getStartTime;

- (void) moviePrepareToPlayLive;
- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) movieSeekToLive;
- (void) movieResyncLive;

- (bool) moviePlayable;
- (bool) moviePlayingRealTime: (float)timeNow;

- (void) resetConnectionCounts;

- (void) timeObserverCallback:(CMTime) cmTime;
- (void) playerItemDidReachEnd:(NSNotification *)notification;
- (void) playerItemFailedToReachEnd:(NSNotification *)notification;

- (void) actOnReadyToPlay;
- (void) actOnPlayerError:(NSError *)error;
- (void) actOnLoopingReachedEnd;

- (void) startLivePlayTimer;
- (void) stopPlayTimers;
- (void) playStartTimerExpired: (NSTimer *)theTimer;
- (void) livePlayTimerFired: (NSTimer *)theTimer;
- (void) restartConnection;

@end
