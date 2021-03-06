//
//  RacePadVideoViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadVideoViewController.h"

@implementation RacePadVideoViewController

- (void) showLoadingIndicators
{
	[loadingLabel setHidden:false];
	[loadingTwirl setHidden:false];
	[loadingTwirl startAnimating];
}

- (void) hideLoadingIndicators
{
	[loadingLabel setHidden:true];
	[loadingTwirl setHidden:true];
	[loadingTwirl stopAnimating];
}

// Override to make these do something
- (void) displayMovieInView
{
}

- (void) removeMovieFromView
{
}

- (void) notifyMovieInformation
{
}

@end
