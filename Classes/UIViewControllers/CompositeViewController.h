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
	IBOutlet TrackMapView * trackMapView;
	
	MPMoviePlayerController * moviePlayer;
	float startTime;
	
	bool requiresReposition;
	float lastPosition;
}

- (void) movieLoad:(NSString *)movie_name;
- (void) movieSetStartTime:(float)time;

- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) moviePrepareToPlay;

- (void) movieFinishedCallback:(NSNotification*) aNotification;

@end
