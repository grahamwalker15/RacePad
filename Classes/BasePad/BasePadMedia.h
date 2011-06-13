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

#import <CoreMedia/CMTime.h>

#import "BasePadVideoViewController.h"

// Movie types
enum MovieTypes
{
	MOVIE_TYPE_NONE_,
	MOVIE_TYPE_ARCHIVE_,
	MOVIE_TYPE_LIVE_STREAM_
} ;

// Connection status
enum MovieConnectionTypes
{
	BPM_NOT_CONNECTED_,
	BPM_CONNECTED_,
	BPM_TRYING_TO_CONNECT_,
	BPM_CONNECTION_FAILED_,
	BPM_CONNECTION_ERROR_,
} ;

@interface BasePadMedia : NSObject
{				
	AVURLAsset * moviePlayerAsset;
	AVPlayerItem * moviePlayerItem;
	AVPlayer * moviePlayer;
	AVPlayerLayer * moviePlayerLayer;
	
	id moviePlayerObserver;
	NSTimer * playTimer;
	
	float movieStartTime;
	float movieSeekTime;
	float streamSeekStartTime;
	float liveVideoDelay;
	
	NSString *currentMovie;
	
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
	
	float activePlaybackRate;
	
	int movieType;
	
	BasePadVideoViewController * registeredViewController;

}
	
+ (BasePadMedia *)Instance;

@property (readonly) AVURLAsset * moviePlayerAsset;
@property (readonly) AVPlayerItem * moviePlayerItem;
@property (readonly) AVPlayer * moviePlayer;
@property (readonly) AVPlayerLayer * moviePlayerLayer;

@property (readonly) id moviePlayerObserver;

@property (readonly) float movieStartTime;
@property (readonly) float movieSeekTime;
@property (readonly) float liveVideoDelay;

@property (readonly) NSString *currentMovie;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) bool movieLoaded;
@property (readonly) bool moviePlayPending;
@property (readonly) bool movieSeekable;
@property (readonly) bool movieSeekPending;

@property (nonatomic) bool moviePausedInPlace;

@property (readonly) int movieType;
	
- (void)onStartUp;

- (void)connectToVideoServer;
- (void)disconnectVideoServer;

- (void)verifyMovieLoaded;

- (void) loadMovie:(NSURL *)url;
- (void) unloadMovie;

- (void) movieSetStartTime:(float)time;

- (void) getStartTime;
- (NSURL *) getMovieURL;
- (NSString *)getVideoArchiveName;

- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) moviePrepareToPlay;

- (void) startPlayTimer;
- (void) stopPlayTimer;
- (void) playTimerExpired: (NSTimer *)theTimer;

- (bool) moviePlayable;

- (void) timeObserverCallback:(CMTime) cmTime;

-(void)RegisterViewController:(BasePadVideoViewController *)view_controller;
-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller;

@end
