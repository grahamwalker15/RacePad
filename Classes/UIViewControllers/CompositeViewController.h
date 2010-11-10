//
//  CompositeViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RacePadViewController.h"
#import "TrackMapView.h"
#import "MovieView.h"


@interface CompositeViewController : RacePadViewController
{
	IBOutlet MovieView * movieView;
	IBOutlet UIView * overlayView;
	IBOutlet TrackMapView * trackMapView;
	
	MPMoviePlayerController * moviePlayer;
	CGSize movieSize;
	CGRect movieRect;
	float startTime;
}

- (void) movieLoad:(NSString *)movie_name;
- (void) movieSetStartTime:(float)time;

- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) moviePrepareToPlay;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) movieSizeCallback:(NSNotification*) aNotification;
- (void) movieFinishedCallback:(NSNotification*) aNotification;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
