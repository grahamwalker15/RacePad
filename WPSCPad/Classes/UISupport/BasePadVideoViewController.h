//
//  BasePadVideoViewController.h
//  BasePad
//
//  Created by Gareth Griffith on 5/6/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadViewController.h"

@interface BasePadVideoViewController : BasePadViewController
{
	IBOutlet UILabel * loadingLabel;
	IBOutlet UIActivityIndicatorView * loadingTwirl;	
	IBOutlet UILabel * videoDelayLabel;
}

- (void) showLoadingIndicators;
- (void) hideLoadingIndicators;

- (void) displayMovieInView;
- (void) removeMovieFromView;
- (void) notifyMovieInformation;

@end
