//
//  CompositeViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAsynchronousKeyValueLoading.h>

#import <CoreMedia/CMTime.h>

#import "BasePadVideoViewController.h"
#import "PitchView.h"
#import "DrawingView.h"
#import "MovieView.h"
#import "BackgroundView.h"

@interface CompositeViewController : BasePadVideoViewController
{
	IBOutlet MovieView * movieView;
	IBOutlet UIView * overlayView;
	IBOutlet PitchView * pitchView;
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet UIView *optionContainer;;
	IBOutlet UISegmentedControl *optionSwitches;

	CGSize movieSize;
	CGRect movieRect;
	
	bool moviePlayerLayerAdded;
		
	bool displayVideo;
	bool displayPitch;
	
}

@property (nonatomic) bool displayVideo;
@property (nonatomic) bool displayPitch;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionViews;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (IBAction) optionSwitchesHit:(id)sender;

@end
