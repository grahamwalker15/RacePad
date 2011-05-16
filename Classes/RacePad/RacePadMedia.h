//
//  RacePadMedia.h
//  RacePad
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

#import "RacePadVideoViewController.h"

// Movie types
enum MovieTypes
{
	MOVIE_TYPE_NONE_,
	MOVIE_TYPE_ARCHIVE_,
	MOVIE_TYPE_LIVE_STREAM_
} ;

@interface RacePadMedia : NSObject
{				
	AVURLAsset * moviePlayerAsset;
	AVPlayerItem * moviePlayerItem;
	AVPlayer * moviePlayer;
	AVPlayerLayer * moviePlayerLayer;
	
	id moviePlayerObserver;
	
	float movieStartTime;
	float movieSeekTime;
	float streamSeekStartTime;
	
	NSString *currentMovie;
	
	bool movieLoaded;
	bool moviePlayable;
	bool moviePlayPending;
	bool movieSeekable;
	bool movieSeekPending;
	
	bool moviePausedInPlace;
	
	float activePlaybackRate;
	
	int movieType;
	
	RacePadVideoViewController * registeredViewController;

}
	
+ (RacePadMedia *)Instance;

@property (readonly) AVURLAsset * moviePlayerAsset;
@property (readonly) AVPlayerItem * moviePlayerItem;
@property (readonly) AVPlayer * moviePlayer;
@property (readonly) AVPlayerLayer * moviePlayerLayer;

@property (readonly) id moviePlayerObserver;

@property (readonly) float movieStartTime;
@property (readonly) float movieSeekTime;

@property (readonly) NSString *currentMovie;

@property (readonly) bool movieLoaded;
@property (readonly) bool moviePlayable;
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

- (void) timeObserverCallback:(CMTime) cmTime;

-(void)RegisterViewController:(RacePadVideoViewController *)view_controller;
-(void)ReleaseViewController:(RacePadVideoViewController *)view_controller;

@end
