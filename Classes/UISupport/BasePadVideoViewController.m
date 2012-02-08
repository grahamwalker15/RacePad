//
//  BasePadVideoViewController.m
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadVideoViewController.h"

@implementation BasePadVideoViewController

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
- (void) displayMovieSource:(BasePadVideoSource *)source
{
}

- (void) removeMovieFromView:(BasePadVideoSource *)source
{
}

- (void) removeMoviesFromView
{
}

- (void) notifyMovieInformation
{
}

@end
