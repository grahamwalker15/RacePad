//
//  BasePadAudioSource.h
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


@interface BasePadAudioSource : NSObject
{				
	AVAudioPlayer * audioPlayer;
	
	NSString *currentAudio;
	
	int currentStatus;
	NSString *currentError;
	
	bool audioPlayPending;
	bool audioSeekPending;
	
	float audioStartTime;
	
	float activePlaybackRate;
	
}

@property (readonly) AVAudioPlayer * audioPlayer;

@property (readonly) NSString *currentAudio;

@property (readonly) int currentStatus;
@property (readonly) NSString *currentError;

@property (readonly) bool audioPlayPending;
@property (readonly) bool audioSeekPending;

@property (readonly) float audioStartTime;

- (void) loadAudio:(NSURL *)url;
- (void) unloadAudio;

- (void) audioPlayAtRate:(float)playbackRate;
- (void) audioPlay;
- (void) audioStop;
- (void) audioGotoTime:(float)time;
- (void) audioPrepareToPlay;

@end
