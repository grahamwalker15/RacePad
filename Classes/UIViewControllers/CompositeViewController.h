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
#import "DrawingView.h"
#import "MovieView.h"
#import "LeaderboardView.h"
#import "BackgroundView.h"

@interface CompositeViewController : RacePadViewController
{
	IBOutlet MovieView * movieView;
	IBOutlet UIView * overlayView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet BackgroundView * trackZoomContainer;
	IBOutlet TrackMapView * trackZoomView;
	IBOutlet LeaderboardView *leaderboardView;

	IBOutlet UIView *optionContainer;;
	IBOutlet UISegmentedControl *optionSwitches;

	MPMoviePlayerController * moviePlayer;
	CGSize movieSize;
	CGRect movieRect;
	float startTime;
	
	NSString *currentMovie;
	
	bool displayMap;
	bool displayLeaderboard;
}

@property (nonatomic) bool displayMap;
@property (nonatomic) bool displayLeaderboard;

- (void) movieLoad:(NSString *)movie_name;
- (void) movieSetStartTime:(float)time;

- (void) getStartTime;
- (NSString *)getVideoArchiveName;

- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;
- (void) moviePrepareToPlay;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) showZoomMap;
- (void) hideZoomMap;
- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) movieSizeCallback:(NSNotification*) aNotification;
- (void) movieFinishedCallback:(NSNotification*) aNotification;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (IBAction) optionSwitchesHit:(id)sender;

@end
