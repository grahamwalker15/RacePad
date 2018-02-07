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

// Movie policies : set at app level - what to do with a movie file.
// Do we keep a live and a replay movie sources (so we can do picture in picture), or just one for both
// These are only used for single file sources - not vls files
enum MoviePolicies
{
	MOVIE_POLICY_SINGLE_SOURCE_,
	MOVIE_POLICY_LIVE_AND_REPLAY_,
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
	
	int currentStatus;
	NSString *currentError;
	
	float activePlaybackRate;
	
	int moviePolicy;
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

@property (nonatomic) int moviePolicy;
@property (readonly) int movieType;

@property (nonatomic) bool extendedNotification;

- (void)onStartUp;

- (void)connectToVideoServer;
- (void)disconnectVideoServer;

-(void)resetConnectionCounts;

- (void)verifyMovieLoaded;
- (void)verifyAudioLoaded;

- (void)clearMediaSources;

- (void)queueMovieLoad:(BasePadVideoSource *)movieSource IntoView:(MovieView *)movieView;
- (void)blockMovieLoadQueue;
- (void)unblockMovieLoadQueue;

- (int) getMovieType;

- (BasePadVideoSource *)movieSource:(int)index;
- (BasePadVideoSource *)findMovieSourceByTag:(NSString *)tag;

- (NSURL *) getMovieURL;
- (NSURL *) getAudioURL;

- (void) moviePrepareToPlayLive;
- (void) moviePlayAtRate:(float)playbackRate;
- (void) moviePlay;
- (void) movieStop;
- (void) movieStopAll;
- (void) movieGotoTime:(float)time;
- (void) movieGoLive;
- (void) movieSeekToLive;
- (void) movieResyncLiveWithRestart:(bool)restart;
- (void) setMoviePlaying:(bool)value;
- (void) setMoviePausedInPlace:(bool)value;
- (void) stopPlayTimers;
- (void) restartConnection;

- (void) audioPlayAtRate:(float)playbackRate;
- (void) audioPlay;
- (void) audioStop;
- (void) audioGotoTime:(float)time;
- (void) audioPrepareToPlay;

- (BasePadVideoSource *) findNextMovieForReview;

-(void)RegisterViewController:(BasePadVideoViewController *)view_controller;
-(void)ReleaseViewController:(BasePadVideoViewController *)view_controller;

-(void)notifyNewVideoSource:(BasePadVideoSource *)videoSource Status:(int)status ShouldDisplay:(bool)shouldDisplay;

-(void)notifyErrorOnVideoSource:(BasePadVideoSource *)videoSource withError:(NSString *)error AutoRetry:(bool)autoRetry;
-(void)notifyUnloadingVideoSource:(BasePadVideoSource *)videoSource;
-(void) notifyVideoSourceReadyToPlay:(BasePadVideoSource *)videoSource;

-(void)notifyVideoSourceConnecting:(BasePadVideoSource *)videoSource showIndicators:(bool)showIndicators;

-(void)notifyMovieInformation;

-(void)loadVideoList:(NSString *)fileName;

@end
