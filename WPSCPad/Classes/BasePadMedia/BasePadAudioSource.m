//
//  BasePadAudioSource.m
//  RacePad
//
//  Created by Gareth Griffith on 12/13/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadAudioSource.h"

#import "BasePadMedia.h"
#import "ElapsedTime.h"

@implementation BasePadAudioSource

@synthesize audioPlayer;

@synthesize currentAudio;
@synthesize currentStatus;
@synthesize currentError;

@synthesize audioPlayPending;
@synthesize audioSeekPending;
@synthesize audioStartTime;

-(id)init
{
	if(self = [super init])
	{	
		currentAudio = nil;
		
		currentStatus = BPM_NOT_CONNECTED_;
		currentError = nil;
				
		audioPlayer = nil;
				
		audioPlayPending = false;
		audioSeekPending = false;
		
		audioStartTime = 0.0;
	}
	
	return self;
}


- (void)dealloc
{
	if(audioPlayer)
		[self unloadAudio];
	
    [super dealloc];
}

- (void) onStartUp
{
}

////////////////////////////////////////////////////////////////////////////
// Audio loading and unloading
////////////////////////////////////////////////////////////////////////////

- (void) loadAudio:(NSURL *)url
{
	[self unloadAudio];
	
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	
	if(audioPlayer)
	{
		// ONLY AVAILABLE IN IOS 5.0 : [audioPlayer setEnableRate:true];
		
		currentAudio = [[url absoluteString] retain];
		
		// Try to find a meta file
		NSString *metaFileName = [currentAudio stringByReplacingOccurrencesOfString:@".mp3" withString:@".amd"];
		FILE *metaFile = fopen([metaFileName UTF8String], "rt" );
		if ( metaFile )
		{
			char keyword[128];
			int value;
			if ( fscanf(metaFile, "%128s %d", keyword, &value ) == 2 )
				if ( strcmp ( keyword, "AudioStartTime" ) == 0 )
					audioStartTime = value;
			fclose(metaFile);
		}
		
	}
	
}

- (void) unloadAudio
{
	if(audioPlayer)
	{
		[audioPlayer release];
		
		audioPlayer = nil;
		
		audioPlayPending = false;
		audioSeekPending = false;
		
		audioStartTime = 0.0;
		
		[currentAudio release];
		currentAudio = nil;
	}
}

////////////////////////////////////////////////////////////////////////
//  Audio controls

- (void) audioPlayAtRate:(float)playbackRate
{
	if(audioPlayer)
	{
		// ONLY AVAILABLE IN IOS 5.0 : [audioPlayer setRate:playbackRate];
		[audioPlayer play];
	}
}

- (void) audioPlay
{
	if(audioPlayer)
	{
		[audioPlayer play];
	}
}

- (void) audioStop
{
	if(audioPlayer)
	{
		[audioPlayer pause];
	}
}

- (void) audioGotoTime:(float)time

{
	if(audioPlayer)
	{
		Float64 audioTime = time - audioStartTime;
		
		double duration = [audioPlayer duration];
		if(audioTime > duration)
			audioTime = duration;
		else if(audioTime < 0.0)
			audioTime = 0.0;
		
		[audioPlayer setCurrentTime:(NSTimeInterval)audioTime];
	}
}

- (void) audioPrepareToPlay
{
	if(audioPlayer)
	{
		[audioPlayer prepareToPlay];
	}
}

@end
