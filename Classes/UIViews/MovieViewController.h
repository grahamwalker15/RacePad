//
//  MovieViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RacePadViewController.h"
#import "MovieView.h"


@interface MovieViewController : RacePadViewController
{
	IBOutlet MovieView * movieView;
	MPMoviePlayerController * moviePlayer;
	float startTime;
}

- (void) movieLoad:(NSString *)movie_name;
- (void) movieSetStartTime:(float)time;

- (void) moviePlay;
- (void) movieStop;
- (void) movieGotoTime:(float)time;

- (void) movieFinishedCallback:(NSNotification*) aNotification;

@end
